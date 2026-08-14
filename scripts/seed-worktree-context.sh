#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: seed-worktree-context.sh TARGET_DIR --manifest PATH [--dry-run]

Seed allowlisted Codex context into a Git worktree from a manifest produced by
create-worktree-context-manifest.sh. Existing target paths are never replaced.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift
manifest=
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --manifest)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      manifest=$2
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

if [ -z "$manifest" ] || [ ! -f "$manifest" ]; then
  echo "A readable --manifest file is required" >&2
  exit 1
fi

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

tab=$(printf '\t')
version=
source_dir=
created=0
skipped=0
adopted=0

validate_relative_path() {
  rel=$1
  case "$rel" in
    ""|/*|..|../*|*/../*|*/..)
      echo "Manifest contains an unsafe relative path: $rel" >&2
      exit 1
      ;;
  esac

  case "$rel" in
    AGENTS.md|AGENTS.override.md|.agents/skills/*|.codex/skills/*|.codex/steering/*|.codex/agents/*)
      ;;
    *)
      echo "Manifest contains a path outside the Codex context allowlist: $rel" >&2
      exit 1
      ;;
  esac
}

ensure_parent() {
  dest=$1
  parent=$(dirname "$dest")
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$parent"
  fi
}

seed_entry() {
  kind=$1
  rel=$2
  link_target=${3:-}

  if [ -z "$source_dir" ]; then
    echo "Manifest entry appeared before the source record" >&2
    exit 1
  fi

  validate_relative_path "$rel"
  src=$source_dir/$rel
  dest=$target_dir/$rel

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing $dest"
    skipped=$((skipped + 1))
    return 0
  fi

  case "$kind" in
    file)
      if [ ! -f "$src" ] || [ -L "$src" ]; then
        echo "Manifest source is no longer a regular file: $src" >&2
        exit 1
      fi
      echo "copy file $src -> $dest"
      ensure_parent "$dest"
      if [ "$dry_run" -eq 0 ]; then
        cp -p "$src" "$dest"
      fi
      ;;
    dir)
      if [ ! -d "$src" ] || [ -L "$src" ]; then
        echo "Manifest source is no longer a regular directory: $src" >&2
        exit 1
      fi
      echo "copy directory $src -> $dest"
      ensure_parent "$dest"
      if [ "$dry_run" -eq 0 ]; then
        cp -Rp "$src" "$dest"
      fi
      ;;
    link)
      if [ ! -L "$src" ]; then
        echo "Manifest source is no longer a symlink: $src" >&2
        exit 1
      fi
      current_target=$(readlink "$src")
      if [ "$current_target" != "$link_target" ]; then
        echo "Manifest symlink target is stale for $src" >&2
        exit 1
      fi
      echo "link $dest -> $link_target"
      ensure_parent "$dest"
      if [ "$dry_run" -eq 0 ]; then
        ln -s "$link_target" "$dest"
      fi
      ;;
    *)
      echo "Unknown manifest entry type: $kind" >&2
      exit 1
      ;;
  esac

  created=$((created + 1))
}

adopt_legacy_skills() {
  legacy_dir=$target_dir/.codex/skills
  canonical_dir=$target_dir/.agents/skills
  canonical_source_dir=

  if [ "$dry_run" -eq 1 ]; then
    legacy_dir=$source_dir/.codex/skills
    canonical_source_dir=$source_dir/.agents/skills
  fi

  if [ ! -d "$legacy_dir" ]; then
    return 0
  fi

  for legacy_entry in "$legacy_dir"/*; do
    if [ ! -e "$legacy_entry" ] && [ ! -L "$legacy_entry" ]; then
      continue
    fi

    name=$(basename "$legacy_entry")
    canonical_entry=$canonical_dir/$name
    if [ -e "$canonical_entry" ] || [ -L "$canonical_entry" ]; then
      continue
    fi
    if [ -n "$canonical_source_dir" ] && {
      [ -e "$canonical_source_dir/$name" ] || [ -L "$canonical_source_dir/$name" ];
    }; then
      continue
    fi

    echo "adopt legacy skill $canonical_entry -> ../../.codex/skills/$name"
    if [ "$dry_run" -eq 0 ]; then
      mkdir -p "$canonical_dir"
      ln -s "../../.codex/skills/$name" "$canonical_entry"
    fi
    adopted=$((adopted + 1))
  done
}

while IFS="$tab" read -r kind field extra; do
  case "$kind" in
    version)
      version=$field
      if [ "$version" != "1" ]; then
        echo "Unsupported worktree context manifest version: $version" >&2
        exit 1
      fi
      ;;
    source)
      if [ -z "$version" ]; then
        echo "Manifest source appeared before the version record" >&2
        exit 1
      fi
      source_dir=$field
      if [ ! -d "$source_dir" ]; then
        echo "Manifest source directory does not exist: $source_dir" >&2
        exit 1
      fi
      source_dir=$(CDPATH= cd -- "$source_dir" && pwd -P)
      ;;
    file|dir|link)
      seed_entry "$kind" "$field" "$extra"
      ;;
    "")
      ;;
    *)
      echo "Unknown manifest record: $kind" >&2
      exit 1
      ;;
  esac
done <"$manifest"

if [ "$version" != "1" ] || [ -z "$source_dir" ]; then
  echo "Manifest is missing required version or source records" >&2
  exit 1
fi

adopt_legacy_skills

echo "Worktree context seed: created=$created skipped=$skipped adopted=$adopted dry_run=$dry_run"
