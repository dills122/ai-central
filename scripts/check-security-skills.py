#!/usr/bin/env python3
"""Exercise security bundle distribution, ownership preservation and review drift."""

import copy
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent
DATA = json.loads((ROOT / "docs/security-skill-provenance.json").read_text())
NAMES = {entry["name"] for entry in DATA["skills"]}
SPEC = importlib.util.spec_from_file_location("security_manifest", ROOT / "scripts/security-skill-manifest.py")
MANIFEST = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MANIFEST)


class SecuritySkillChecks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="security skill check ")
        self.addCleanup(self.temp.cleanup)
        self.target = Path(self.temp.name).resolve()

    def run_installer(self, *args):
        return subprocess.run(
            [str(ROOT / "scripts/install-skill-bundle.sh"), str(self.target), *args],
            check=True, capture_output=True, text=True,
        ).stdout

    def skill_names(self):
        return {path.name for path in (self.target / ".agents/skills").iterdir()}

    def test_preview_copy_and_preserve_project_edits(self):
        self.run_installer("--bundle", "security-testing", "--dry-run")
        self.assertEqual(list(self.target.iterdir()), [])
        self.run_installer("--bundle", "security-testing")
        self.assertEqual(self.skill_names(), NAMES)
        for entry in DATA["skills"]:
            installed = self.target / ".agents/skills" / entry["name"]
            self.assertFalse(installed.is_symlink())
            for relative in entry["files"]:
                self.assertEqual((installed / relative).read_bytes(), (ROOT / entry["path"] / relative).read_bytes())
            self.assertEqual((self.target / ".codex/skills" / entry["name"]).resolve(), installed)
        owned = self.target / ".agents/skills/security-state-recovery/SKILL.md"
        owned.write_text("Project-owned replacement\n")
        self.run_installer("--bundle", "security-testing", "--mode", "link")
        self.assertEqual(owned.read_text(), "Project-owned replacement\n")
        self.assertFalse(owned.parent.is_symlink())

    def test_exact_selection_and_safe_link_sync(self):
        self.run_installer("--bundle", "none", "--skills", "security-state-recovery", "--mode", "link")
        self.assertEqual(self.skill_names(), {"security-state-recovery"})
        self.run_installer("--bundle", "security-testing", "--mode", "link")
        for entry in DATA["skills"]:
            self.assertEqual((self.target / ".agents/skills" / entry["name"]).resolve(), ROOT / entry["path"])
        owned = self.target / ".agents/skills/project-owned"
        owned.mkdir()
        (owned / "SKILL.md").write_text("keep me\n")
        self.run_installer("--bundle", "security-testing", "--skip-skills", "security-protocol-fuzzing", "--mode", "link", "--sync", "--dry-run")
        self.assertTrue((self.target / ".agents/skills/security-protocol-fuzzing").is_symlink())
        self.run_installer("--bundle", "security-testing", "--skip-skills", "security-protocol-fuzzing", "--mode", "link", "--sync")
        self.assertEqual(self.skill_names(), (NAMES - {"security-protocol-fuzzing"}) | {"project-owned"})
        self.assertFalse((self.target / ".codex/skills/security-protocol-fuzzing").is_symlink())
        self.assertEqual((owned / "SKILL.md").read_text(), "keep me\n")

    def test_bundle_is_opt_in_and_included_in_all(self):
        (self.target / "SECURITY.md").write_text("Security policy\n")
        subprocess.run([str(ROOT / "scripts/setup-ai-context.sh"), str(self.target), "--yes"], check=True, capture_output=True)
        self.assertFalse(self.skill_names() & NAMES)
        self.run_installer("--bundle", "all", "--mode", "link")
        self.assertTrue(NAMES <= self.skill_names())

    def test_guided_explicit_bundle_and_apm_selection(self):
        subprocess.run([
            str(ROOT / "scripts/setup-ai-context.sh"), str(self.target), "--yes",
            "--profiles", "base", "--bundles", "security-testing", "--mode", "link",
        ], check=True, capture_output=True)
        self.assertEqual(self.skill_names(), NAMES)
        output = self.target / "apm.yml"
        subprocess.run([
            str(ROOT / "scripts/generate-apm-selection.sh"), "--bundle", "security-testing",
            "--name", "security-fixture", "--ref", "fixture-reviewed-ref", "--output", str(output),
        ], check=True, capture_output=True)
        text = output.read_text()
        for entry in DATA["skills"]:
            self.assertIn("path: " + entry["path"], text)

    def test_manifest_detects_content_addition_deletion_and_links(self):
        for entry in DATA["skills"]:
            shutil.copytree(ROOT / entry["path"], self.target / entry["path"])
        MANIFEST.verify(self.target, DATA)
        skill = self.target / DATA["skills"][0]["path"]
        asset = skill / "assets/recovery-matrix.md"
        original = asset.read_bytes()
        asset.write_bytes(original + b"Changed contract\n")
        with self.assertRaisesRegex(ValueError, "drift"):
            MANIFEST.verify(self.target, DATA)
        asset.write_bytes(original)
        extra = skill / "unreviewed.md"
        extra.write_text("new instructions\n")
        with self.assertRaisesRegex(ValueError, "drift"):
            MANIFEST.verify(self.target, DATA)
        extra.unlink()
        asset.unlink()
        with self.assertRaisesRegex(ValueError, "resource"):
            MANIFEST.verify(self.target, DATA)
        asset.symlink_to(ROOT / DATA["skills"][0]["path"] / "assets/recovery-matrix.md")
        with self.assertRaisesRegex(ValueError, "Linked"):
            MANIFEST.verify(self.target, DATA)
        asset.unlink()
        asset.write_bytes(original)
        # Refresh fingerprints must not change the review date or provenance.
        updated = copy.deepcopy(DATA)
        updated["skills"][0]["files"] = {}
        MANIFEST.verify(self.target, updated, refresh=True)
        self.assertEqual(updated, DATA)

    def test_retained_forward_test_reproduces_model_evidence(self):
        fixtures = ROOT / "scripts/fixtures/security-skills"
        for name in ("fixture.py", "CONTRACT.md", "forward_test.py"):
            shutil.copyfile(fixtures / name, self.target / name)
        subprocess.run(
            ["python3", "-B", str(self.target / "forward_test.py")],
            check=True, capture_output=True, timeout=10,
        )
        evidence = json.loads((self.target / "evidence.json").read_text())
        self.assertTrue(evidence["fixture_unchanged"])
        self.assertEqual(evidence["race"]["overlap"]["effects"], 2)
        self.assertEqual(evidence["secrets"]["scan"], "fail")
        self.assertEqual(evidence["protocol"]["minimum_violating_payload"], 129)
        self.assertTrue(any(not row["invariant_holds"] for row in evidence["recovery"]["cases"]))


if __name__ == "__main__":
    unittest.main()
