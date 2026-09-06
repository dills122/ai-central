"""Offline seeder checks; set CCE_TEST_PYTHON for real CCE pipeline checks."""
import importlib.util
import json
import os
from pathlib import Path
import sqlite3
import struct
import shutil
import shlex
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).with_name("seed-cce-worktree.py")
spec = importlib.util.spec_from_file_location("seed_cce", SCRIPT)
seed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(seed)


class SeederTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="cce worktree check ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.source = self.root / "primary"
        self.target = self.root / "worktree"
        self.source.mkdir()
        seed.git(self.source, "init", "-q")
        (self.source / "sample.py").write_text("def add(a, b):\n    return a + b\n")
        (self.source / "removed.py").write_text("def removed():\n    return 'source only'\n")
        seed.git(self.source, "add", ".")
        seed.git(self.source, "-c", "user.name=Test", "-c", "user.email=test@example.com",
                 "-c", "commit.gpgsign=false", "commit", "-qm", "fixture")
        seed.git(self.source, "worktree", "add", "-q", "--detach", str(self.target), "HEAD")
        self.source_store = self.root / "source store"
        self.target_store = self.root / "target store"
        self.source_store.mkdir()

    def cache(self):
        path = self.source_store / "embedding_cache.db"
        conn = sqlite3.connect(path)
        self.addCleanup(conn.close)
        conn.execute("PRAGMA journal_mode=WAL")
        conn.execute("PRAGMA wal_autocheckpoint=0")
        conn.execute("CREATE TABLE embedding_cache (content_hash TEXT PRIMARY KEY, "
                     "dim INTEGER NOT NULL, embedding BLOB NOT NULL)")
        conn.execute("INSERT INTO embedding_cache VALUES (?, ?, ?)", ("hash", 1, struct.pack("f", 0.5)))
        conn.commit()
        return path, conn

    def test_git_discovery_and_repository_boundary(self):
        self.assertEqual(seed.checkout_pair(self.target), (self.target, self.source))
        self.assertEqual(seed.checkout_pair(self.source), (self.source, self.source))
        unrelated = self.root / "unrelated"
        unrelated.mkdir()
        seed.git(unrelated, "init", "-q")
        with self.assertRaisesRegex(ValueError, "same Git"):
            seed.checkout_pair(self.target, unrelated)
        (self.target / "subdir").mkdir()
        with self.assertRaisesRegex(ValueError, "root"):
            seed.checkout_pair(self.target / "subdir")

    def test_live_wal_snapshot_and_independent_writes(self):
        path, source = self.cache()
        self.assertTrue(Path(str(path) + "-wal").exists())
        (self.source_store / "memory.db").write_text("not copied")
        seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        with sqlite3.connect(self.target_store / "embedding_cache.db") as target:
            self.assertEqual(target.execute("SELECT dim FROM embedding_cache").fetchall(), [(1,)])
            target.execute("DELETE FROM embedding_cache")
        self.assertEqual(source.execute("SELECT count(*) FROM embedding_cache").fetchone(), (1,))
        self.assertFalse((self.target_store / "memory.db").exists())
        self.assertFalse((self.target_store / "manifest.json").exists())
        self.assertEqual(json.loads((self.target_store / "meta.json").read_text()),
                         {"project_dir": str(self.target)})
        # Running again must not replace the independently modified cache.
        seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        with sqlite3.connect(self.target_store / "embedding_cache.db") as target:
            self.assertEqual(target.execute("SELECT count(*) FROM embedding_cache").fetchone(), (0,))

    def test_corrupt_cache_does_not_publish_store(self):
        (self.source_store / "embedding_cache.db").write_text("not sqlite")
        with self.assertRaises(sqlite3.Error):
            seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        self.assertFalse(self.target_store.exists())
        self.assertEqual(list(self.root.glob(".cce-seed-*")), [])

    def test_missing_empty_or_wrong_schema_cache(self):
        with self.assertRaisesRegex(ValueError, "No source"):
            seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        path, conn = self.cache()
        conn.execute("DELETE FROM embedding_cache")
        conn.commit()
        with self.assertRaisesRegex(ValueError, "empty"):
            seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        self.assertFalse(self.target_store.exists())
        conn.execute("ALTER TABLE embedding_cache ADD COLUMN unexpected TEXT")
        conn.commit()
        with self.assertRaisesRegex(ValueError, "schema"):
            seed.snapshot_cache(path, self.root / "snapshot.db")

    def test_ignored_config_only_and_no_overwrite(self):
        (self.source / ".git/info/exclude").write_text(".context-engine.yaml\n.cceignore\n")
        config = self.source / ".context-engine.yaml"
        config.write_text("embedding:\n  model: example\n")
        (self.source / ".cceignore").write_text("private/\n")
        (self.target / ".cceignore").write_text("target-owned/\n")
        plan = seed.config_plan(self.source, self.target)
        self.assertEqual(plan, [(config, self.target / config.name)])
        seed.copy_new_file(*plan[0])
        with self.assertRaises(FileExistsError):
            seed.copy_new_file(*plan[0])
        self.assertEqual((self.target / ".cceignore").read_text(), "target-owned/\n")
        self.assertEqual(seed.config_plan(self.source, self.target), [])

    def test_legacy_and_symlink_stores_refused(self):
        config = SimpleNamespace(storage_path=str(self.root))
        with self.assertRaisesRegex(ValueError, "Legacy"):
            seed.storage_dir(config, self.source, lambda root: "new-slug")
        (self.root / "new-slug").symlink_to(self.source_store)
        with self.assertRaisesRegex(ValueError, "symlink"):
            seed.storage_dir(config, self.source, lambda root: "new-slug")

    def test_index_errors_are_failures(self):
        async def failing(*args, **kwargs):
            return SimpleNamespace(indexed_files=[], total_chunks=0, cache_hits=0,
                                   cache_misses=0, errors=["embedding unavailable"])
        module = SimpleNamespace(run_indexing=failing)
        with patch.dict(sys.modules, {"context_engine.indexer.pipeline": module}):
            with self.assertRaisesRegex(ValueError, "embedding unavailable"):
                seed.reconcile(None, self.target)

    @unittest.skipUnless(os.environ.get("CCE_TEST_PYTHON"), "optional installed CCE integration")
    def test_real_cce_cache_reuse_and_worktree_content(self):
        python = os.environ["CCE_TEST_PYTHON"]
        store = self.root / "cce stores"
        (self.source / ".git/info/exclude").write_text(".context-engine.yaml\n.cceignore\n")
        (self.source / ".context-engine.yaml").write_text(
            "storage:\n  path: " + json.dumps(str(store)) + "\n")
        # An installed runtime dependency creates this scratch file in cwd.
        # Also exercise inheritance and enforcement of a local .cceignore.
        (self.source / ".cceignore").write_text(":memory:.ses\n")
        env = dict(os.environ, CCE_PYTHON=python, HF_HUB_OFFLINE="1", CCE_EMBED_PARALLEL="0",
                   CCE_EMBED_BACKEND="fastembed", PYTHONDONTWRITEBYTECODE="1")
        # Build a real source cache with the already downloaded local model.
        build = """
import asyncio
from pathlib import Path
from context_engine.config import load_config
from context_engine.indexer.pipeline import run_indexing
result = asyncio.run(run_indexing(load_config(project_path=Path('.context-engine.yaml')), str(Path.cwd())))
assert not result.errors, result.errors
"""
        subprocess.run([python, "-B", "-c", build], cwd=self.source, env=env, check=True)
        from hashlib import sha256
        target_store = store / (self.target.name + "-" + sha256(str(self.target).encode()).hexdigest()[:6])
        before = sorted(str(p.relative_to(store)) for p in store.rglob("*"))
        wrapper = SCRIPT.with_name("setup-codex-worktree.sh")
        subprocess.run([str(wrapper), str(self.target), "--cce", "--dry-run"], env=env, check=True)
        self.assertEqual(before, sorted(str(p.relative_to(store)) for p in store.rglob("*")))
        self.assertFalse((self.target / ".context-engine.yaml").exists())
        # Source-only content must never appear in the worktree's new index.
        (self.target / "removed.py").unlink()
        (self.target / "new.py").write_text("def worktree_only():\n    return 'fresh worktree'\n")
        result = subprocess.run([str(wrapper), str(self.target), "--cce"],
                                env=env, text=True, capture_output=True, check=True)
        self.assertRegex(result.stdout, r"cache_hits=[1-9][0-9]*")
        self.assertRegex(result.stdout, r"cache_misses=[1-9][0-9]*")
        manifest = json.loads((target_store / "manifest.json").read_text())
        self.assertIn("sample.py", manifest["files"])
        self.assertIn("new.py", manifest["files"])
        self.assertNotIn("removed.py", manifest["files"])
        self.assertFalse((target_store / "memory.db").exists())
        verify_search = """
import asyncio, sys
from context_engine.storage.local_backend import LocalBackend
backend = LocalBackend(sys.argv[1])
hits = asyncio.run(backend.fts_search('worktree_only'))
assert hits, 'worktree symbol missing from FTS'
chunks = [asyncio.run(backend.get_chunk_by_id(chunk_id)) for chunk_id, score in hits]
assert any(chunk.file_path == 'new.py' for chunk in chunks), chunks
assert not asyncio.run(backend.fts_search('removed')), 'source-only symbol leaked'
"""
        subprocess.run([python, "-B", "-c", verify_search, str(target_store)],
                       cwd=self.target, env=env, check=True)
        # Second run should skip unchanged files through CCE's manifest.
        result = subprocess.run([python, "-B", str(SCRIPT), str(self.target)],
                                env=env, text=True, capture_output=True, check=True)
        after = json.loads((target_store / "manifest.json").read_text())
        changed = {key: (manifest["files"].get(key), after["files"].get(key))
                   for key in set(manifest["files"]) | set(after["files"])
                   if after["files"].get(key) != manifest["files"].get(key)}
        self.assertIn("cache_hits=0 cache_misses=0", result.stdout, repr(changed))
        # Exercise the complete installed hook with CCE, including Git's hook
        # environment and source/target discovery during worktree creation.
        hook_env = dict(env, PATH=str(Path(python).parent) + os.pathsep + env["PATH"])
        with (self.source / ".git/info/exclude").open("a") as excludes:
            excludes.write("AGENTS.md\n")
        (self.source / "AGENTS.md").write_text("# Local AI Central guidance\n")
        subprocess.run([str(SCRIPT.with_name("install-worktree-context-hook.sh")), str(self.source)],
                       env=hook_env, capture_output=True, check=True)
        subprocess.run([str(SCRIPT.with_name("install-cce-worktree-hook.sh")), str(self.source), "--replace-cce-hook"],
                       env=hook_env, capture_output=True, check=True)
        created = subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                                  str(self.root / "hook-created"), "HEAD"],
                                 env=hook_env, text=True, capture_output=True, check=True)
        self.assertRegex(created.stdout + created.stderr, r"cache_hits=[1-9][0-9]*")
        self.assertEqual((self.root / "hook-created/AGENTS.md").read_text(), "# Local AI Central guidance\n")
        # Installation captured CCE's absolute launcher. A GUI-like PATH must
        # not make synchronous seeding rediscover it through the user's shell.
        minimal_env = dict(hook_env, PATH="/usr/bin:/bin:/usr/sbin:/sbin")
        for name in ("CCE_PYTHON", "CCE_BIN", "AI_CENTRAL_CCE_REEXEC"):
            minimal_env.pop(name, None)
        minimal = subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                                  str(self.root / "minimal-path"), "HEAD"],
                                 env=minimal_env, text=True, capture_output=True, check=True)
        self.assertRegex(minimal.stdout + minimal.stderr, r"cache_hits=[1-9][0-9]*")
        relative_launcher = self.source / ".venv/bin/cce"
        relative_launcher.parent.mkdir(parents=True)
        relative_launcher.symlink_to(Path(python).parent / "cce")
        relative_env = dict(minimal_env, PATH=".venv/bin:" + minimal_env["PATH"])
        subprocess.run([str(SCRIPT.with_name("install-cce-worktree-hook.sh")), str(self.source),
                        "--replace-cce-hook"], cwd=self.source, env=relative_env,
                       text=True, capture_output=True, check=True)
        relative = subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                                   str(self.root / "relative-install-path"), "HEAD"],
                                  env=minimal_env, text=True, capture_output=True, check=True)
        self.assertRegex(relative.stdout + relative.stderr, r"cache_hits=[1-9][0-9]*")

    def test_metadata_collision_is_refused(self):
        self.cache()
        (self.source_store / "meta.json").write_text(json.dumps({"project_dir": str(self.target)}))
        with self.assertRaisesRegex(ValueError, "different checkout"):
            seed.seed_store(self.source, self.target, self.source_store, self.target_store)
        self.assertFalse(self.target_store.exists())

    def test_version_gate(self):
        with patch.dict(os.environ, {"CCE_PYTHON": sys.executable}):
            with patch.object(seed.importlib.metadata, "version", return_value="0.4.27"):
                with self.assertRaisesRegex(ValueError, "not validated"):
                    seed.use_cce_python()

    def test_hook_installer_orders_seed_before_index_and_preserves_commands(self):
        # Run Git's real post-checkout dispatch with stub CCE commands, so the
        # all-zero old HEAD behavior is tested without embedding dependencies.
        fixture = self.root / "ai central"
        (fixture / "scripts").mkdir(parents=True)
        (fixture / "templates/worktree").mkdir(parents=True)
        installer = fixture / "scripts/install-cce-worktree-hook.py"
        shutil.copyfile(SCRIPT.with_name(installer.name), installer)
        shutil.copyfile(SCRIPT.with_name("worktree_hooks.py"), fixture / "scripts/worktree_hooks.py")
        shutil.copyfile(SCRIPT.parent.parent / "templates/worktree/cce-post-checkout.sh",
                        fixture / "templates/worktree/cce-post-checkout.sh")
        command_dir = self.root / "command bin"
        command_dir.mkdir()
        binary = command_dir / "cce"
        binary.write_text('#!/bin/sh\nprintf "index\\n" >> "$CCE_HOOK_LOG"\n')
        binary.chmod(0o755)
        seeder = fixture / "scripts/seed-cce-worktree.sh"
        seeder.write_text('#!/bin/sh\n[ -x "$CCE_BIN" ] || exit 1\nprintf "seed\\n" >> "$CCE_HOOK_LOG"\n')
        seeder.chmod(0o755)
        hook = self.source / ".git/hooks/post-checkout"
        original = ('#!/bin/sh\nprintf "before\\n" >> "$CCE_HOOK_LOG"\n# cce hook\n' +
                    shlex.quote(str(binary)) + ' index >/dev/null 2>&1 &\n' +
                    'printf "after\\n" >> "$CCE_HOOK_LOG"\n')
        hook.write_text(original)
        hook.chmod(0o755)
        log = self.root / "hook.log"
        env = dict(os.environ, PATH=str(command_dir) + os.pathsep + os.environ["PATH"],
                   CCE_HOOK_LOG=str(log))
        command = [sys.executable, "-B", str(installer), str(self.source)]
        result = subprocess.run(command, env=env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(hook.read_text(), original)
        subprocess.run(command + ["--replace-cce-hook", "--dry-run"], env=env,
                       capture_output=True, check=True)
        self.assertEqual(hook.read_text(), original)
        subprocess.run(command + ["--replace-cce-hook"], env=env, capture_output=True, check=True)
        installed = hook.read_text()
        backups = list(hook.parent.glob("post-checkout.before-cce-*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), original)
        subprocess.run(command, env=env, capture_output=True, check=True)
        self.assertEqual(hook.read_text(), installed)
        subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                        str(self.root / "new worktree"), "HEAD"], env=env, check=True)
        self.assertEqual(log.read_text().splitlines(), ["seed", "before", "after"])
        # Both installations must remain reachable before a pre-existing exit.
        context_installer = fixture / "scripts/install-worktree-context-hook.py"
        shutil.copyfile(SCRIPT.with_name(context_installer.name), context_installer)
        shutil.copyfile(SCRIPT.parent.parent / "templates/worktree/context-post-checkout.sh",
                        fixture / "templates/worktree/context-post-checkout.sh")
        context_setup = fixture / "scripts/setup-codex-worktree.sh"
        context_setup.write_text('#!/bin/sh\nprintf "context\\n" >> "$CCE_HOOK_LOG"\n')
        context_setup.chmod(0o755)
        for order in ("cce-only", "context-first", "cce-first"):
            with self.subTest(order=order):
                hook.write_text('#!/bin/sh\nprintf "unrelated\\n" >> "$CCE_HOOK_LOG"\nexit 0\n')
                log.write_text("")
                context_command = [sys.executable, "-B", str(context_installer), str(self.source), "--replace-hook"]
                if order == "context-first":
                    subprocess.run(context_command, env=env, capture_output=True, check=True)
                subprocess.run(command + ["--replace-cce-hook"], env=env, capture_output=True, check=True)
                if order == "cce-first":
                    subprocess.run(context_command, env=env, capture_output=True, check=True)
                subprocess.run(command, env=env, capture_output=True, check=True)
                subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                                str(self.root / order), "HEAD"], env=env, check=True)
                expected = ["seed", "unrelated"] if order == "cce-only" else ["context", "seed", "unrelated"]
                self.assertEqual(log.read_text().splitlines(), expected)
        # Dependency-free coverage of the relative-PATH installation contract.
        launcher = self.source / ".venv/bin/cce"
        launcher.parent.mkdir(parents=True)
        launcher.symlink_to(binary)
        hook.write_text("#!/bin/sh\n")
        relative_env = dict(env, PATH=".venv/bin:" + os.environ["PATH"])
        subprocess.run(command + ["--replace-cce-hook"], cwd=self.source, env=relative_env,
                       capture_output=True, check=True)
        log.write_text("")
        subprocess.run(["git", "-C", str(self.source), "worktree", "add", "-q", "--detach",
                        str(self.root / "relative-launcher"), "HEAD"], env=env, check=True)
        self.assertEqual(log.read_text().splitlines(), ["seed"])


if __name__ == "__main__":
    unittest.main()
