#!/usr/bin/env python3
"""Check or refresh reviewed security-skill file inventories; never fetch upstream."""

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "docs/security-skill-provenance.json"


def inventory(root, entry):
    """Validate a declared skill and return hashes of every distributable file."""
    name = entry["name"]
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) >= 64:
        raise ValueError(f"Invalid skill name: {name}")
    if entry["kind"] not in {"first-party", "adapted"}:
        raise ValueError(f"Invalid kind: {name}")
    expected = f"templates/skills/{entry['kind']}/{name}"
    if entry["path"] != expected or entry["status"] != "reviewed":
        raise ValueError(f"Only explicitly reviewed canonical skill paths are allowed: {name}")
    datetime.date.fromisoformat(entry["reviewDate"])
    if not entry["reviewNotes"].strip() or not entry["sources"]:
        raise ValueError(f"Missing review/provenance: {name}")
    for source in entry["sources"]:
        if not source["url"].startswith("https://") or not re.fullmatch(r"[0-9a-f]{40}", source["commit"]):
            raise ValueError(f"Source must have URL and immutable commit: {name}")
        if not source["files"] or not source["use"].strip():
            raise ValueError(f"Missing source files or use: {name}")
        if source["use"] == "adapted" and not source.get("license"):
            raise ValueError(f"Adapted source needs a license: {name}")
    directory = root / expected
    if directory.is_symlink() or not directory.is_dir():
        raise ValueError(f"Missing or linked skill directory: {name}")
    if any(parent.is_symlink() for parent in directory.parents if parent != root and root in parent.parents):
        raise ValueError(f"Linked skill parent: {name}")
    files = {}
    for path in sorted(directory.rglob("*")):
        if path.is_symlink():
            raise ValueError(f"Linked distributable resource: {path}")
        if path.is_file():
            files[path.relative_to(directory).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    if not {"SKILL.md", "LICENSE"} <= files.keys():
        raise ValueError(f"Skill and installed license required: {name}")
    text = (directory / "SKILL.md").read_text()
    if not text.startswith(f"---\nname: {name}\n") or "\nlicense: MIT\n---\n" not in text:
        raise ValueError(f"Unexpected entrypoint metadata: {name}")
    # These four skills use plain relative Markdown links. Check installed resources
    # without depending on the ignored upstream clone or another skill directory.
    for path in directory.rglob("*.md"):
        for link in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if link.startswith(("https://", "http://", "#")):
                continue
            target = (path.parent / link.split("#", 1)[0]).resolve()
            if not target.is_relative_to(directory.resolve()) or not target.is_file():
                raise ValueError(f"Missing or external local resource: {path}: {link}")
    return files


def verify(root, data, refresh=False):
    if data["schemaVersion"] != 1 or data["bundle"] != "security-testing":
        raise ValueError("Unsupported security provenance schema/bundle")
    names = [entry["name"] for entry in data["skills"]]
    if not names or len(names) != len(set(names)):
        raise ValueError("Empty or duplicate security skill inventory")
    for entry in data["skills"]:
        actual = inventory(root, entry)
        if refresh:
            entry["files"] = actual
        elif entry["files"] != actual:
            raise ValueError(f"Unreviewed inventory drift: {entry['name']}; review changes before --refresh")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--check", action="store_true")
    group.add_argument("--refresh", action="store_true", help="refresh hashes after content review; does not approve or update review metadata")
    args = parser.parse_args()
    try:
        data = json.loads(MANIFEST.read_text())
        verify(ROOT, data, refresh=args.refresh)
        if args.refresh:
            MANIFEST.write_text(json.dumps(data, indent=2) + "\n")
            print("Refreshed security skill inventories; review metadata and diff before delivery")
        else:
            print("Security skill provenance and file inventories match")
    except (KeyError, TypeError, ValueError, OSError) as error:
        print(f"Security manifest check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
