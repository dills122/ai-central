"""Shared installer for the independent context and CCE post-checkout blocks."""
import argparse
import os
from pathlib import Path
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile


START = "# ai-central cce worktree hook v1"
END = "# /ai-central cce worktree hook"
CONTEXT_START = "# ai-central context worktree hook v1"
CONTEXT_END = "# /ai-central context worktree hook"


def updated_context_hook(existing, block):
    if CONTEXT_START in existing or CONTEXT_END in existing:
        if existing.count(CONTEXT_START) != 1 or existing.count(CONTEXT_END) != 1:
            raise ValueError("Malformed AI Central context hook markers")
        pattern = re.compile(r"^" + re.escape(CONTEXT_START) + r"\n.*?^" + re.escape(CONTEXT_END) + r"\n?", re.M | re.S)
        existing, count = pattern.subn("", existing)
        if count != 1:
            raise ValueError("Malformed AI Central context hook block")
    # Guidance must exist before CCE indexes the worktree and before any early
    # exit in the existing hook. Preserve its remaining bytes.
    shebang, body = existing.split("\n", 1)
    return shebang + "\n" + block + body


def place_cce_block(existing, block):
    shebang, body = existing.split("\n", 1)
    if CONTEXT_START in body or CONTEXT_END in body:
        context = re.match(re.escape(CONTEXT_START) + r"\n.*?^" + re.escape(CONTEXT_END) + r"\n",
                           body, flags=re.M | re.S)
        if context is None or body.count(CONTEXT_START) != 1 or body.count(CONTEXT_END) != 1:
            raise ValueError("Reinstall the context hook before composing a relocated or malformed context block")
        return shebang + "\n" + context[0] + block + body[context.end():]
    return shebang + "\n" + block + body


def updated_hook(existing, block):
    if START in existing or END in existing:
        if existing.count(START) != 1 or existing.count(END) != 1:
            raise ValueError("Malformed AI Central hook markers; review the hook manually")
        pattern = re.compile(r"^" + re.escape(START) + r"\n.*?^" + re.escape(END) + r"\n?", re.M | re.S)
        remaining, count = pattern.subn("", existing)
        if count != 1:
            raise ValueError("Malformed AI Central hook block")
        return place_cce_block(remaining, block)
    lines = existing.splitlines(keepends=True)
    markers = [i for i, line in enumerate(lines) if line.strip() == "# cce hook"]
    if markers:
        if len(markers) != 1 or markers[0] + 1 == len(lines):
            raise ValueError("Unexpected CCE hook block; review it manually")
        i = markers[0]
        command = lines[i + 1].strip()
        suffix = " index >/dev/null 2>&1 &"
        if not command.endswith(suffix):
            raise ValueError("CCE hook differs from the reviewed 0.4.26 template")
        binary = shlex.split(command[:-len(suffix)])
        if len(binary) != 1 or Path(binary[0]).name not in ("cce", "code-context-engine"):
            raise ValueError("Unrecognized CCE hook command")
        lines[i:i + 2] = []
        return place_cce_block("".join(lines), block)
    # Do not append a second index command behind a custom unmarked CCE hook.
    unmanaged = re.sub(r"^" + re.escape(CONTEXT_START) + r"\n.*?^" + re.escape(CONTEXT_END) + r"\n?",
                       "", existing, flags=re.M | re.S)
    if re.search(r"\bcce\b|code-context-engine", unmanaged):
        raise ValueError("Unmarked CCE command found; review the hook manually")
    return place_cce_block(existing, block)


def main(context=False):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source")
    parser.add_argument("--replace-hook" if context else "--replace-cce-hook", dest="replace_hook", action="store_true",
                        help="Allow updating an existing hook, with backup and other commands preserved")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    source = Path(args.source).resolve(strict=True)

    def git(*options):
        return subprocess.check_output(["git", "-C", str(source), *options], text=True).strip()

    if Path(git("rev-parse", "--show-toplevel")).resolve() != source:
        raise ValueError("Source must be a Git checkout root")
    common = Path(git("rev-parse", "--path-format=absolute", "--git-common-dir")).resolve()
    hooks_config = subprocess.run(["git", "-C", str(source), "config", "--get", "core.hooksPath"],
                                  text=True, capture_output=True)
    if hooks_config.returncode == 0 and not Path(hooks_config.stdout.strip()).is_absolute():
        raise ValueError("Relative core.hooksPath is checkout-local; integrate the template through that hook manager")
    hooks = Path(git("rev-parse", "--path-format=absolute", "--git-path", "hooks")).resolve()
    if not (hooks.is_relative_to(common) or hooks.is_relative_to(source)):
        raise ValueError("Shared external core.hooksPath: integrate the template manually in that hook manager")
    hook = hooks / "post-checkout"
    if hook.is_symlink():
        raise ValueError("Refusing to replace a symlinked post-checkout hook")
    repo = Path(__file__).resolve().parent.parent
    if context:
        block = (repo / "templates/worktree/context-post-checkout.sh").read_text()
        block = block.replace("{{CONTEXT_SETUP_COMMAND}}", shlex.quote(str(repo / "scripts/setup-codex-worktree.sh")))
        block = block.replace("{{CONTEXT_SOURCE_DIR}}", shlex.quote(str(source)))
    else:
        binary = shutil.which("cce")
        if not binary:
            raise ValueError("cce must be on PATH when installing the hook")
        # which() can return a relative PATH entry. Anchor it at installation,
        # retaining any alias/.. traversal rather than normalizing components.
        binary = os.path.join(os.getcwd(), binary)
        block = (repo / "templates/worktree/cce-post-checkout.sh").read_text()
        block = block.replace("{{CCE_COMMAND}}", shlex.quote(binary))
        block = block.replace("{{CCE_SEED_COMMAND}}", shlex.quote(str(repo / "scripts/seed-cce-worktree.sh")))
        block = block.replace("{{CCE_SOURCE_DIR}}", shlex.quote(str(source)))
    existing = hook.read_text() if hook.exists() else "#!/bin/sh\n"
    if not re.match(r"^#![^\n]*\b(?:sh|bash|dash|zsh)(?:[ \t][^\n]*)?\n", existing):
        raise ValueError("Non-shell post-checkout hook; integrate the template through its hook manager")
    updated = updated_context_hook(existing, block) if context else updated_hook(existing, block)
    if updated == existing and os.access(hook, os.X_OK):
        print(f"Worktree hook already current: {hook}")
        return
    if hook.exists() and not args.replace_hook:
        flag = "--replace-hook" if context else "--replace-cce-hook"
        raise ValueError(f"Hook exists; use {flag} to opt into replacement (preview with --dry-run)")
    print(f"Worktree post-checkout hook: {hook}\n{updated}")
    if args.dry_run:
        return
    hooks.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(hook.stat().st_mode) if hook.exists() else 0o755
    with tempfile.NamedTemporaryFile(dir=hooks, prefix=".cce-hook-", delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(updated.encode())
            stream.flush()
            temporary.chmod(mode | stat.S_IXUSR)
            if hook.exists():
                if hook.read_text() != existing:
                    raise ValueError("Hook changed during installation; retry")
                with tempfile.NamedTemporaryFile(dir=hooks, prefix="post-checkout.before-cce-", delete=False) as backup:
                    backup.write(existing.encode())
                    print(f"Original hook backed up to {backup.name}")
                os.replace(temporary, hook)
            else:
                os.link(temporary, hook)
        finally:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"CCE hook installation failed: {exc}", file=sys.stderr)
        sys.exit(1)
