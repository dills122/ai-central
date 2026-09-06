"""Exercise context seeding via actual Git hook dispatch, without CCE."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parent.parent


class ContextHookTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="context hook ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.source = self.root / "primary"
        self.source.mkdir()
        self.run_command("git", "init", "-q", str(self.source))
        (self.source / "README.md").write_text("fixture\n")
        self.git("add", ".")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com",
                 "-c", "commit.gpgsign=false", "commit", "-qm", "fixture")
        (self.source / ".git/info/exclude").write_text("AGENTS.md\n.agents/\n.codex/\n.env\n")
        (self.source / "AGENTS.md").write_text("# Local instructions\n")
        (self.source / ".env").write_text("do not seed\n")
        self.hook = self.source / ".git/hooks/post-checkout"
        self.installer = REPO / "scripts/install-worktree-context-hook.sh"

    def run_command(self, *args, check=True, env=None, cwd=None):
        return subprocess.run([str(arg) for arg in args], text=True, capture_output=True,
                              check=check, env=env, cwd=cwd)

    def git(self, *args, **kwargs):
        return self.run_command("git", "-C", self.source, *args, **kwargs)

    def worktree(self, name="deep/nested/task", **kwargs):
        target = self.root / name
        self.git("worktree", "add", "-q", "--detach", target, "HEAD", **kwargs)
        return target

    def test_context_only_creation_links_and_rerun(self):
        shared = self.root / "shared/skill"
        shared.mkdir(parents=True)
        (shared / "SKILL.md").write_text("---\nname: shared\ndescription: fixture\n---\n")
        skills = self.source / ".agents/skills"
        skills.mkdir(parents=True)
        (skills / "external").symlink_to("../../../shared/skill")
        legacy = self.source / ".codex/skills"
        legacy.mkdir(parents=True)
        (legacy / "internal").symlink_to("../../.agents/skills/external")
        steering = self.source / ".codex/steering"
        steering.mkdir()
        (steering / "local.md").write_text("local steering\n")
        self.run_command(self.installer, self.source, "--dry-run")
        self.assertFalse(self.hook.exists())
        self.run_command(self.installer, self.source)
        # The installer must never ask for CCE just to seed context.
        self.assertNotIn("seed-cce-worktree", self.hook.read_text())
        original_hook = self.hook.read_bytes()
        self.run_command(self.installer, self.source)
        self.assertEqual(original_hook, self.hook.read_bytes())
        self.hook.chmod(0o644)
        result = self.run_command(self.installer, self.source, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.run_command(self.installer, self.source, "--replace-hook")
        self.assertTrue(os.access(self.hook, os.X_OK))
        target = self.worktree()
        self.assertEqual((target / "AGENTS.md").read_text(), "# Local instructions\n")
        self.assertTrue((target / ".agents/skills/external/SKILL.md").is_file())
        self.assertEqual(os.readlink(target / ".codex/skills/internal"), "../../.agents/skills/external")
        self.assertTrue((target / ".agents/skills/internal/SKILL.md").is_file())
        self.assertFalse((target / ".env").exists())
        (target / "AGENTS.md").write_text("target-owned\n")
        self.run_command(REPO / "scripts/setup-codex-worktree.sh", target)
        self.assertEqual((target / "AGENTS.md").read_text(), "target-owned\n")
        # Ordinary checkout must not seed again, even if a local file vanished.
        (target / "AGENTS.md").unlink()
        self.run_command("git", "-C", target, "checkout", "--detach", "HEAD")
        self.assertFalse((target / "AGENTS.md").exists())

    def test_whole_skills_directory_link(self):
        shared = self.root / "skills"
        (shared / "example").mkdir(parents=True)
        (shared / "example/SKILL.md").write_text("---\nname: example\ndescription: fixture\n---\n")
        (self.source / ".agents").mkdir()
        (self.source / ".agents/skills").symlink_to("../../skills")
        self.run_command(self.installer, self.source)
        target = self.worktree()
        self.assertTrue((target / ".agents/skills/example/SKILL.md").is_file())

    def test_external_link_keeps_intermediate_symlink_parent_traversal(self):
        shared = self.root / "shared"
        (shared / "actual/deep").mkdir(parents=True)
        (shared / "actual/skill").mkdir()
        (shared / "actual/skill/SKILL.md").write_text("---\nname: intended\ndescription: fixture\n---\n")
        # A wrong but valid skill makes this catch silent target substitution,
        # as well as the broken-link case found by the independent reviewer.
        (shared / "skill").mkdir()
        (shared / "skill/SKILL.md").write_text("---\nname: wrong\ndescription: fixture\n---\n")
        (shared / "alias").symlink_to("actual/deep")
        skills = self.source / ".agents/skills"
        skills.mkdir(parents=True)
        (skills / "external").symlink_to("../../../shared/alias/../skill")
        intended = (skills / "external/SKILL.md").read_text()
        self.run_command(self.installer, self.source)
        target = self.worktree()
        self.assertEqual((target / ".agents/skills/external/SKILL.md").read_text(), intended)

    def test_existing_hook_preserved_and_failure_visible(self):
        original = '#!/bin/sh\nprintf "other hook\\n"\n'
        self.hook.write_text(original)
        self.hook.chmod(0o755)
        result = self.run_command(self.installer, self.source, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.hook.read_text(), original)
        self.run_command(self.installer, self.source, "--replace-hook")
        self.assertTrue(self.hook.read_text().endswith(original.split("\n", 1)[1]))
        self.assertEqual(next(self.hook.parent.glob("post-checkout.before-cce-*")).read_text(), original)
        # A broken source skill link makes the audit fail visibly in Git.
        (self.source / ".agents/skills").mkdir(parents=True)
        (self.source / ".agents/skills/broken").symlink_to("/nonexistent/context-hook-fixture")
        result = self.git("worktree", "add", "-q", "--detach", self.root / "broken", "HEAD", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("broken", result.stdout + result.stderr)

    def test_unusable_whole_directory_links_fail_git_setup(self):
        self.run_command(self.installer, self.source)
        wrong_type = self.root / "regular-file"
        wrong_type.write_text("not a directory\n")
        for number, name in enumerate((".agents/skills", ".codex/skills", ".codex/steering", ".codex/agents")):
            link = self.source / name
            link.parent.mkdir(parents=True, exist_ok=True)
            for kind, dest in (("dangling", self.root / "missing"), ("wrong-type", wrong_type)):
                with self.subTest(name=name, kind=kind):
                    link.symlink_to(dest)
                    result = self.git("worktree", "add", "-q", "--detach", self.root / f"invalid-{number}-{kind}",
                                      "HEAD", check=False)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("context directory is dangling or not a directory", result.stdout + result.stderr)
                    link.unlink()

    def test_whole_canonical_link_remains_authoritative_with_legacy_skills(self):
        shared = self.root / "canonical-shared"
        (shared / "canonical").mkdir(parents=True)
        (shared / "canonical/SKILL.md").write_text("---\nname: canonical\ndescription: fixture\n---\n")
        (self.source / ".agents").mkdir()
        (self.source / ".agents/skills").symlink_to(shared)
        legacy = self.source / ".codex/skills/legacy"
        legacy.mkdir(parents=True)
        (legacy / "SKILL.md").write_text("---\nname: legacy\ndescription: fixture\n---\n")
        before = sorted(str(path.relative_to(shared)) for path in shared.rglob("*"))
        self.run_command(self.installer, self.source)
        target = self.worktree()
        self.assertTrue((target / ".agents/skills/canonical/SKILL.md").is_file())
        self.assertTrue((target / ".codex/skills/legacy/SKILL.md").is_file())
        self.assertFalse((shared / "legacy").exists())
        self.assertEqual(before, sorted(str(path.relative_to(shared)) for path in shared.rglob("*")))
        rerun = self.run_command(REPO / "scripts/setup-codex-worktree.sh", target)
        self.assertIn("skip legacy alias adoption", rerun.stdout + rerun.stderr)

    def test_context_precedes_cce_in_both_install_orders(self):
        binary_dir = self.root / "bin"
        binary_dir.mkdir()
        cce = binary_dir / "cce"
        cce.write_text("#!/bin/sh\nexit 0\n")
        cce.chmod(0o755)
        env = dict(os.environ, PATH=str(binary_dir) + os.pathsep + os.environ["PATH"])
        cce_installer = REPO / "scripts/install-cce-worktree-hook.sh"
        for context_first in (True, False):
            with self.subTest(context_first=context_first):
                self.hook.unlink(missing_ok=True)
                if context_first:
                    self.run_command(self.installer, self.source)
                    self.run_command(cce_installer, self.source, "--replace-cce-hook", env=env)
                else:
                    self.run_command(cce_installer, self.source, env=env)
                    self.run_command(self.installer, self.source, "--replace-hook")
                text = self.hook.read_text()
                self.assertLess(text.index("# ai-central context"), text.index("# ai-central cce"))
                self.run_command(self.installer, self.source)
                self.run_command(cce_installer, self.source, env=env)
                self.assertEqual(text, self.hook.read_text())

    def test_hook_manager_and_non_shell_refusals(self):
        self.git("config", "core.hooksPath", ".githooks")
        result = self.run_command(self.installer, self.source, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Relative core.hooksPath", result.stderr)
        self.git("config", "--unset", "core.hooksPath")
        self.hook.write_text("#!/usr/bin/python3\nprint('hello')\n")
        result = self.run_command(self.installer, self.source, "--replace-hook", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Non-shell", result.stderr)

    def test_target_parent_symlink_is_not_followed(self):
        (self.source / ".codex/steering").mkdir(parents=True)
        (self.source / ".codex/steering/local.md").write_text("instructions\n")
        target = self.worktree()
        external = self.root / "external"
        external.mkdir()
        (target / ".codex").symlink_to(external)
        result = self.run_command(REPO / "scripts/setup-codex-worktree.sh", target, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlinked target parent", result.stderr)
        self.assertFalse((external / "steering").exists())


if __name__ == "__main__":
    unittest.main()
