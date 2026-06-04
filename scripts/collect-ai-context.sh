#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 [SOURCE_ROOT]" >&2
}

source_root=${1:-/Users/dsteele/repos}

if [ "$#" -gt 1 ]; then
  usage
  exit 2
fi

if [ ! -d "$source_root" ]; then
  echo "Source root does not exist: $source_root" >&2
  exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
collected_root=$repo_root/collected

mkdir -p "$collected_root"

copy_file() {
  src=$1
  rel=${src#"$source_root"/}
  dest=$collected_root/misc/"$rel"
  mkdir -p "$(dirname -- "$dest")"
  cp "$src" "$dest"
  echo "collected $rel"
}

find "$source_root" \
  -path '*/node_modules' -prune -o \
  -path '*/.git' -prune -o \
  -path '*/dist' -prune -o \
  -path '*/build' -prune -o \
  \( \
    -name 'AGENTS.md' -o \
    -name 'CLAUDE.md' -o \
    -name 'GEMINI.md' -o \
    -name '.cursorrules' -o \
    -name 'copilot-instructions.md' -o \
    -name '*.mdc' -o \
    -path '*/.codex/steering/*' -o \
    -path '*/.codex/skills/*/SKILL.md' -o \
    -path '*/.cursor/rules/*' \
  \) -type f -print | while IFS= read -r file; do
    copy_file "$file"
  done

"$repo_root/scripts/refresh-source-manifest.sh"
