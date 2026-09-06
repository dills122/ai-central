"""Check policy installation and optional matching with the installed CCE runtime."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent
SEED = ROOT / "scripts/seed-cce-ignore.sh"
TEMPLATE = ROOT / "templates/cce/default.cceignore"


class IgnoreTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="cce ignore check ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "project"
        self.repo.mkdir()
        self.git("init", "-q")

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], text=True).strip()

    def seed(self, *args, success=True):
        result = subprocess.run([str(SEED), str(self.repo), *args], capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_preview_install_and_preserve_customization(self):
        exclude = self.repo / ".git/info/exclude"
        exclude.write_bytes(b"# existing without newline")
        self.seed("--dry-run")
        self.assertEqual(exclude.read_bytes(), b"# existing without newline")
        self.assertFalse((self.repo / ".cceignore").exists())
        self.seed()
        dest = self.repo / ".cceignore"
        self.assertEqual(dest.read_bytes(), TEMPLATE.read_bytes())
        self.assertFalse(dest.is_symlink())
        self.assertEqual(self.git("check-ignore", ".cceignore"), ".cceignore")
        self.assertTrue(exclude.read_bytes().startswith(b"# existing without newline\n"))
        installed_exclude = exclude.read_bytes()
        dest.write_text("project-owned/\n")
        self.seed()
        self.assertEqual(dest.read_text(), "project-owned/\n")
        self.assertEqual(exclude.read_bytes(), installed_exclude)

    def test_trackable_policy_and_tracked_deletion(self):
        exclude = self.repo / ".git/info/exclude"
        original = exclude.read_bytes()
        self.seed("--trackable")
        self.assertEqual(exclude.read_bytes(), original)
        self.assertIn(".cceignore", self.git("ls-files", "--others", "--exclude-standard"))
        self.git("add", ".cceignore")
        (self.repo / ".cceignore").unlink()
        self.seed()
        self.assertFalse((self.repo / ".cceignore").exists())
        self.assertEqual(exclude.read_bytes(), original)

    def test_existing_links_and_invalid_targets(self):
        policy = self.root / "custom-ignore"
        policy.write_text("custom/\n")
        dest = self.repo / ".cceignore"
        dest.symlink_to(policy)
        self.seed()
        self.assertTrue(dest.is_symlink())
        self.assertEqual(policy.read_text(), "custom/\n")
        policy.unlink()
        self.seed(success=False)
        self.assertTrue(dest.is_symlink())
        dest.unlink()
        dest.mkdir()
        self.seed(success=False)
        (dest / "tracked.txt").write_text("invalid policy directory\n")
        self.git("add", ".cceignore")
        self.seed(success=False)

    def test_conflicting_git_policy_does_not_publish(self):
        (self.repo / ".gitignore").write_text("!.cceignore\n")
        self.seed(success=False)
        self.assertFalse((self.repo / ".cceignore").exists())
        self.seed("--trackable")
        self.assertTrue((self.repo / ".cceignore").is_file())

    def test_root_dot_alias_collision_preserves_source(self):
        source = self.repo / "astro"
        source.mkdir()
        (source / "source.ts").write_text("export const source = true;\n")
        self.seed(success=False)
        self.seed("--dry-run", success=False)
        self.assertFalse((self.repo / ".cceignore").exists())
        self.assertTrue((source / "source.ts").is_file())

    def test_worktree_inheritance_uses_existing_cce_seeder(self):
        self.seed()
        (self.repo / "source.py").write_text("print('source')\n")
        self.git("add", "source.py")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com",
                 "-c", "commit.gpgsign=false", "commit", "-qm", "fixture")
        target = self.root / "deep" / "worktree"
        self.git("worktree", "add", "-q", "--detach", str(target), "HEAD")
        import importlib.util
        spec = importlib.util.spec_from_file_location("cce_seed", ROOT / "scripts/seed-cce-worktree.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        plan = module.config_plan(self.repo, target)
        self.assertEqual(plan, [(self.repo / ".cceignore", target / ".cceignore")])
        module.copy_new_file(*plan[0])
        self.assertEqual((target / ".cceignore").read_bytes(), TEMPLATE.read_bytes())
        # Installing directly into a worktree resolves the common exclude file.
        (target / ".cceignore").unlink()
        self.repo = target
        self.seed()
        self.assertEqual(self.git("check-ignore", ".cceignore"), ".cceignore")

    def test_guided_setup_is_opt_in_and_dry_run_aware(self):
        command = [str(ROOT / "scripts/setup-ai-context.sh"), str(self.repo),
                   "--yes", "--profiles", "base", "--bundles", "none"]
        subprocess.run(command, check=True, capture_output=True)
        self.assertFalse((self.repo / ".cceignore").exists())
        subprocess.run(command + ["--cce-ignore", "--dry-run"], check=True, capture_output=True)
        self.assertFalse((self.repo / ".cceignore").exists())
        subprocess.run(command + ["--cce-ignore"], check=True, capture_output=True)
        self.assertEqual((self.repo / ".cceignore").read_bytes(), TEMPLATE.read_bytes())

    @unittest.skipUnless(os.environ.get("CCE_TEST_PYTHON"), "set CCE_TEST_PYTHON for CCE matching")
    def test_actual_cce_matcher_keeps_source_and_prunes_nested_artifacts(self):
        # Load CCE's implementation rather than duplicating glob semantics here.
        probe = r'''
import sys
from pathlib import Path
from context_engine.indexer.ignorefile import load_ignore_patterns, matches_any
root = Path(sys.argv[1])
patterns = load_ignore_patterns(root)
def ignored(path):
    parts = path.split('/')
    return matches_any(path, False, patterns) or any(
        matches_any('/'.join(parts[:i]), True, patterns) for i in range(1, len(parts)))
for path in ['apps/web/.astro/types.d.ts', '.astro/types.d.ts',
             'apps/admin/.angular/cache/19/bundle.js', 'common/temp/cache.json',
             'nested/common/temp/cache.json', 'apps/site/.svelte-kit/types.d.ts',
             'extension/.wxt/tsconfig.json', 'apps/api/.heft/state.json',
             'apps/ui/.nx/workspace-data/projects.json', 'src/Service/Obj/Debug/code.cs',
             'tests/TestResults/results.xml', 'test-results/run/trace.json',
             '.cce/store/meta.json', '.claude/worktrees/copy/source.ts',
             'experiments/swift/.build/checkouts/dependency/Package.swift',
             '.build/checkouts/dependency/Package.swift', '.wxt/tsconfig.json',
             'apps/ui/dist-storybook/index.html', 'app.js.map', 'app.min.js']:
    assert ignored(path), path
for path in ['lib/sdk/src/index.ts', 'types/public.d.ts', 'src/client.generated.ts',
             'generated/contracts.ts', 'artifacts/specification.json', 'pkg/server/main.go',
             'docs/architecture.md', 'fixtures/input.json', 'tests/__snapshots__/test.snap',
             'migrations/001.sql', 'src/schema.proto', '.codex/steering/repository-steering.md',
             '.github/workflows/build.yml', 'Cargo.lock', 'src/styles.css',
             'geo/city.map', 'playwright.config.ts', '.nx/generators/custom.ts']:
    assert not ignored(path), path
# Exercise the actual traversal too, including root hidden-directory behavior.
from context_engine.config import Config
from context_engine.indexer.pipeline import _iter_project_files, _SKIP_EXTENSIONS
for name in ['.astro/types.d.ts', '.cce/store/meta.json', 'nested/.build/cache.json',
             '.claude/worktrees/old/src/index.ts', 'src/index.ts', 'generated/contracts.ts']:
    p = root / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text('sample source\n')
found = {p.relative_to(root).as_posix() for p in _iter_project_files(
    root, set(Config().indexer_ignore), _SKIP_EXTENSIONS, cceignore_patterns=patterns)}
assert {'src/index.ts', 'generated/contracts.ts'} <= found, found
assert not any(p.startswith(('.astro/', '.cce/', 'nested/.build/', '.claude/worktrees/')) for p in found), found
'''
        self.seed()
        subprocess.run([os.environ["CCE_TEST_PYTHON"], "-c", probe, str(self.repo)], check=True)


if __name__ == "__main__":
    unittest.main()
