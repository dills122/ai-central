"""Seed reusable CCE embeddings; rebuild checkout-specific data with CCE.

Python is used for SQLite online backup and CCE's configuration/pipeline API.
The public entry point remains POSIX sh. No extra Python packages are installed.
"""
import argparse
import asyncio
from contextlib import closing
import importlib.metadata
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time


SUPPORTED_VERSION = "0.4.26"
CONFIG_FILES = (".context-engine.yaml", ".cceignore")


def git(root, *args):
    return subprocess.check_output(
        ["git", "-C", str(root), *args], text=True, stderr=subprocess.PIPE
    ).strip()


def checkout_pair(target, source=None):
    target = Path(target).resolve(strict=True)
    if Path(git(target, "rev-parse", "--show-toplevel")).resolve() != target:
        raise ValueError("Target must be a Git worktree root")
    common = Path(git(target, "rev-parse", "--path-format=absolute", "--git-common-dir")).resolve()
    if source is None:
        if common.name != ".git":
            raise ValueError("Cannot infer primary checkout; pass --source")
        source = common.parent
    source = Path(source).resolve(strict=True)
    if Path(git(source, "rev-parse", "--show-toplevel")).resolve() != source:
        raise ValueError("Source must be a Git worktree root")
    other = Path(git(source, "rev-parse", "--path-format=absolute", "--git-common-dir")).resolve()
    if common != other:
        raise ValueError("Source and target must belong to the same Git repository")
    return target, source


def use_cce_python():
    # uv/pipx launchers are symlinks into a venv. Preserve the venv's Python
    # path (resolving that final symlink would lose site-packages).
    if not os.environ.get("CCE_PYTHON") and not os.environ.get("AI_CENTRAL_CCE_REEXEC"):
        launcher = os.environ.get("CCE_BIN") or shutil.which("cce")
        if launcher:
            candidate = Path(launcher).resolve().parent / "python"
            if candidate.is_file() and str(candidate) != sys.executable:
                env = dict(os.environ, AI_CENTRAL_CCE_REEXEC="1")
                os.execve(str(candidate), [str(candidate), "-B", *sys.argv], env)
    try:
        version = importlib.metadata.version("code-context-engine")
    except importlib.metadata.PackageNotFoundError as exc:
        raise ValueError("CCE is unavailable. Set CCE_PYTHON to its virtualenv's Python") from exc
    if version != SUPPORTED_VERSION:
        raise ValueError(f"CCE {version} is not validated; this adapter supports {SUPPORTED_VERSION}")


def storage_dir(config, root, slug):
    # Do not call project_storage_dir: even during a dry run it can rename
    # legacy stores. Refuse ambiguous legacy state instead.
    base = Path(config.storage_path)
    if not base.is_absolute():
        base = root / base
    dest = base / slug(root)
    legacy = base / root.name
    if not dest.exists() and legacy.exists():
        raise ValueError(f"Legacy CCE store needs migration with CCE first: {legacy}")
    if dest.is_symlink():
        raise ValueError(f"Refusing a symlinked CCE store: {dest}")
    return dest.resolve()


def config_plan(source, target):
    plan = []
    for name in CONFIG_FILES:
        src, dst = source / name, target / name
        if os.path.lexists(dst) or not src.is_file():
            continue
        ignored = subprocess.run(
            ["git", "-C", str(source), "check-ignore", "-q", "--", name],
            check=False,
        )
        # Only inherit local ignored config. Branch-specific tracked config
        # (including intentional deletions) belongs to the target branch.
        if ignored.returncode == 0 and not git(target, "ls-files", "--", name):
            plan.append((src, dst))
        elif ignored.returncode not in (0, 1):
            raise ValueError(f"Cannot check CCE config exclusions: {src}")
    return plan


def copy_new_file(src, dst):
    with tempfile.NamedTemporaryFile(dir=dst.parent, prefix=".cce-config-", delete=False) as tmp:
        temp = Path(tmp.name)
        try:
            with src.open("rb") as source:
                shutil.copyfileobj(source, tmp)
            tmp.flush()
            os.link(temp, dst)  # Atomic no-replace publication; independent source bytes.
        finally:
            temp.unlink()


def snapshot_cache(source, destination):
    started = time.monotonic()

    def progress(status, remaining, total):
        if time.monotonic() - started > 60:
            raise TimeoutError("CCE cache backup exceeded 60 seconds; retry when source is quieter")

    with closing(sqlite3.connect(source.as_uri() + "?mode=ro", uri=True)) as src:
        columns = [(row[1], row[2], row[5]) for row in src.execute("PRAGMA table_info(embedding_cache)")]
        if columns != [("content_hash", "TEXT", 1), ("dim", "INTEGER", 0), ("embedding", "BLOB", 0)]:
            raise ValueError("Unsupported CCE embedding cache schema")
        with closing(sqlite3.connect(destination)) as dst:
            src.backup(dst, pages=1024, progress=progress, sleep=0.05)
            if dst.execute("PRAGMA quick_check").fetchone() != ("ok",):
                raise ValueError("CCE cache snapshot failed SQLite integrity check")
            count = dst.execute("SELECT count(*) FROM embedding_cache").fetchone()[0]
            if not count:
                raise ValueError("Source CCE embedding cache is empty; index the source first")
            dst.execute("PRAGMA journal_mode=DELETE")
    return count


def validate_stores(source, target, source_store, target_store):
    for root, store in ((source, source_store), (target, target_store)):
        meta = store / "meta.json"
        if meta.exists() and Path(json.loads(meta.read_text())["project_dir"]).resolve() != root:
            raise ValueError(f"CCE store metadata points to a different checkout: {store}")
    if not target_store.exists() and not (source_store / "embedding_cache.db").is_file():
        raise ValueError(f"No source embedding cache at {source_store}; run cce index in the source first")


def seed_store(source, target, source_store, target_store):
    validate_stores(source, target, source_store, target_store)
    if os.path.lexists(target_store):
        print(f"Preserving existing CCE store: {target_store}", flush=True)
        return
    cache = source_store / "embedding_cache.db"
    target_store.parent.mkdir(parents=True, exist_ok=True)
    # Reserve the final directory before copying; other seeders cannot replace it.
    target_store.mkdir(mode=0o700)
    try:
        with tempfile.TemporaryDirectory(prefix=".cce-seed-", dir=target_store.parent) as staging:
            snapshot = Path(staging) / "embedding_cache.db"
            count = snapshot_cache(cache, snapshot)
            os.link(snapshot, target_store / "embedding_cache.db")
        with (target_store / "meta.json").open("x") as stream:
            json.dump({"project_dir": str(target)}, stream)
        with (target_store / "ai-central-seed.json").open("x") as stream:
            json.dump({"cce_version": SUPPORTED_VERSION, "source": str(source),
                       "source_head": git(source, "rev-parse", "HEAD"),
                       "target_head": git(target, "rev-parse", "HEAD"),
                       "embeddings": count}, stream)
        print(f"Seeded {count} cached embeddings into {target_store}", flush=True)
    except BaseException:
        # Never recursively delete: an independently launched CCE may have
        # written here. Remove only an empty reservation, otherwise preserve it.
        try:
            target_store.rmdir()
        except OSError:
            pass
        raise


def reconcile(config, target):
    from context_engine.indexer.pipeline import run_indexing

    result = asyncio.run(run_indexing(config, str(target), phase_fn=lambda msg: print(msg, flush=True)))
    print(f"CCE: files={len(result.indexed_files)} chunks={result.total_chunks} "
          f"cache_hits={result.cache_hits} cache_misses={result.cache_misses}", flush=True)
    # CCE 0.4.26's CLI prints pipeline errors but does not return a failure
    # status. Inspect the result directly so setup cannot report false success.
    if result.errors:
        raise ValueError("CCE indexing failed: " + "; ".join(result.errors))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target")
    parser.add_argument("--source")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--seed-only", action="store_true", help="Copy cache only; index is not search-ready")
    args = parser.parse_args()
    target, source = checkout_pair(args.target, args.source)
    if target == source:
        print("Target is the primary checkout; no CCE seeding needed")
        return
    use_cce_python()
    from context_engine.config import load_config
    from context_engine.utils import _project_slug

    plan = config_plan(source, target)
    source_config = load_config(project_path=source / CONFIG_FILES[0])
    target_config_path = next((src for src, dst in plan if dst.name == CONFIG_FILES[0]), target / CONFIG_FILES[0])
    config = load_config(project_path=target_config_path)
    source_store = storage_dir(source_config, source, _project_slug)
    target_store = storage_dir(config, target, _project_slug)
    if source_store == target_store:
        raise ValueError("Source and target resolve to the same CCE store")
    validate_stores(source, target, source_store, target_store)
    for src, dst in plan:
        print(f"Copy ignored CCE config: {src} -> {dst}", flush=True)
    print(f"CCE cache source: {source_store}\nCCE worktree store: {target_store}", flush=True)
    if args.dry_run:
        print("Dry run: preserve existing store or seed cache; " +
              ("leave indexing pending" if args.seed_only else "index the target worktree"))
        return
    # Run before the worktree's MCP starts. This lock serializes our setup
    # processes only; CCE itself does not participate in it.
    import fcntl

    target_store.parent.mkdir(parents=True, exist_ok=True)
    with (target_store.parent / ("." + target_store.name + ".seed.lock")).open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        seed_store(source, target, source_store, target_store)
        for src, dst in plan:
            copy_new_file(src, dst)
        os.chdir(target)  # Matches CCE CLI resolution of relative storage paths.
        if args.seed_only:
            print("Cache seeded; run cce index in the worktree before searching")
        else:
            reconcile(config, target)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, sqlite3.Error, subprocess.CalledProcessError) as exc:
        print(f"CCE worktree setup failed: {exc}", file=sys.stderr)
        sys.exit(1)
