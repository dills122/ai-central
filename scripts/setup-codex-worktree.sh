#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: setup-codex-worktree.sh TARGET_DIR [--source SOURCE_DIR] [--dry-run]

Discover a managed worktree's primary checkout, capture its locally ignored
Codex context, and seed that context into the new worktree without overwriting.
Use this command as a Codex Local Environment setup script.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift
source_dir=
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --source)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      source_dir=$2
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

target_dir=$(CDPATH= cd -- "$target_dir" && pwd -P)
target_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null) || {
  echo "Target directory is not inside a Git worktree: $target_dir" >&2
  exit 1
}

if [ "$target_root" != "$target_dir" ]; then
  echo "Target must be the Git worktree root: $target_dir" >&2
  exit 1
fi

target_common_dir=$(git -C "$target_dir" rev-parse --path-format=absolute --git-common-dir)

if [ -z "$source_dir" ]; then
  if [ "$(basename "$target_common_dir")" != ".git" ]; then
    echo "Cannot infer a primary checkout from Git common directory: $target_common_dir" >&2
    echo "Pass --source explicitly." >&2
    exit 1
  fi
  source_dir=$(dirname "$target_common_dir")
fi

if [ ! -d "$source_dir" ]; then
  echo "Source directory does not exist: $source_dir" >&2
  exit 1
fi

source_dir=$(CDPATH= cd -- "$source_dir" && pwd -P)
source_root=$(git -C "$source_dir" rev-parse --show-toplevel 2>/dev/null) || {
  echo "Source directory is not inside a Git worktree: $source_dir" >&2
  exit 1
}

if [ "$source_root" != "$source_dir" ]; then
  echo "Source must be the Git worktree root: $source_dir" >&2
  exit 1
fi

source_common_dir=$(git -C "$source_dir" rev-parse --path-format=absolute --git-common-dir)
if [ "$source_common_dir" != "$target_common_dir" ]; then
  echo "Source and target do not belong to the same Git repository" >&2
  exit 1
fi

if [ "$source_dir" = "$target_dir" ]; then
  echo "Target is the primary checkout; no worktree context seeding is needed"
  exit 0
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
manifest=$(mktemp "${TMPDIR:-/tmp}/ai-central-worktree-context.XXXXXX")
trap 'rm -f "$manifest"' EXIT HUP INT TERM

"$repo_root/scripts/create-worktree-context-manifest.sh" "$source_dir" --output "$manifest"

if [ "$dry_run" -eq 1 ]; then
  "$repo_root/scripts/seed-worktree-context.sh" "$target_dir" --manifest "$manifest" --dry-run
else
  "$repo_root/scripts/seed-worktree-context.sh" "$target_dir" --manifest "$manifest"
  "$repo_root/scripts/audit-ai-context.sh" "$target_dir"
fi
