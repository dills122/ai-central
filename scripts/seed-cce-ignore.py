"""Install an editable CCE ignore baseline without replacing project policy."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile


TEMPLATE = Path(__file__).resolve().parent.parent / "templates/cce/default.cceignore"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", help="Git checkout root")
    parser.add_argument("--dry-run", action="store_true", help="Preview without writing")
    parser.add_argument("--trackable", action="store_true",
                        help="Do not add a local Git exclusion (for team-owned policy)")
    args = parser.parse_args()
    root = Path(args.target).resolve(strict=True)

    def git(*options):
        return subprocess.check_output(["git", "-C", str(root), *options], text=True).strip()

    if Path(git("rev-parse", "--show-toplevel")).resolve() != root:
        raise ValueError("Target must be a Git checkout root")
    dest = root / ".cceignore"
    if os.path.lexists(dest) and not dest.is_file():
        raise ValueError(f"Existing CCE policy is not a readable file: {dest}")
    # A tracked deletion is project policy too; do not resurrect it.
    if git("ls-files", "--", ".cceignore"):
        print(f"Preserve tracked CCE policy (including any deletion): {dest}")
        return
    if os.path.lexists(dest):
        print(f"Preserve existing CCE policy: {dest}")
        return

    content = TEMPLATE.read_bytes()
    aliases = content.decode().split("# BEGIN root-dot aliases\n", 1)[1].split("# END root-dot aliases", 1)[0]
    collisions = [line.rstrip("/*") for line in aliases.splitlines()
                  if line and os.path.lexists(root / line.rstrip("/*"))]
    if collisions:
        raise ValueError("CCE root-dot compatibility rules overlap existing paths: "
                         + ", ".join(collisions) + "; tailor the template manually")
    exclude = None
    if not args.trackable:
        exclude = Path(git("rev-parse", "--path-format=absolute", "--git-path", "info/exclude"))
        if exclude.is_symlink() or (exclude.exists() and not exclude.is_file()):
            raise ValueError(f"Refusing non-regular Git exclude file: {exclude}")
        existing = exclude.read_bytes() if exclude.exists() else b""
        ignored = subprocess.run(["git", "-C", str(root), "check-ignore", "-q", "--", ".cceignore"])
        if ignored.returncode not in (0, 1):
            raise ValueError("Cannot inspect Git exclusions for .cceignore")
        needs_exclusion = ignored.returncode == 1
        if needs_exclusion:
            print(f"Append /.cceignore to local Git exclusions: {exclude}")
    print(f"Create editable copy: {TEMPLATE} -> {dest}")
    if args.dry_run:
        return

    # Establish local inheritance before publishing. A higher-priority .gitignore
    # negation can defeat info/exclude; report it instead of claiming local setup.
    if exclude is not None:
        if needs_exclusion:
            exclude.parent.mkdir(parents=True, exist_ok=True)
            with exclude.open("ab") as stream:
                if existing and not existing.endswith(b"\n"):
                    stream.write(b"\n")
                stream.write(b"\n# AI Central local CCE policy\n/.cceignore\n")
        if subprocess.run(["git", "-C", str(root), "check-ignore", "-q", "--", ".cceignore"]).returncode != 0:
            raise ValueError("Git policy overrides the local exclusion; use --trackable or review .gitignore")

    # Publish a complete file with no-replace semantics, including symlink races.
    with tempfile.NamedTemporaryFile(dir=root, prefix=".cce-ignore-", delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(content)
            stream.flush()
            temporary.chmod(0o644)
            os.link(temporary, dest)
        finally:
            temporary.unlink(missing_ok=True)
    print("CCE ignore ready; review project-specific paths before indexing.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"CCE ignore seeding failed: {exc}", file=sys.stderr)
        sys.exit(1)
