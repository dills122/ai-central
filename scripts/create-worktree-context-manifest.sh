#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: create-worktree-context-manifest.sh SOURCE_DIR [--output PATH]

Describe locally ignored Codex context from a primary checkout. Only allowlisted
agent instructions, skills, steering, and Codex agent definitions are included.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

source_dir=$1
shift
output=-

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      output=$2
      shift 2
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

tab=$(printf '\t')

validate_field() {
  value=$1
  label=$2
  case "$value" in
    *"$tab"*|*'
'*)
      echo "$label contains a tab or newline and cannot be represented safely: $value" >&2
      exit 1
      ;;
  esac
}

emit_entry() {
  rel=$1
  abs=$source_dir/$rel

  if ! git -C "$source_dir" check-ignore -q -- "$rel"; then
    return 0
  fi

  validate_field "$rel" "Context path"

  if [ -L "$abs" ]; then
    link_target=$(readlink "$abs")
    validate_field "$link_target" "Symlink target"
    printf 'link\t%s\t%s\n' "$rel" "$link_target"
  elif [ -f "$abs" ]; then
    printf 'file\t%s\n' "$rel"
  elif [ -d "$abs" ]; then
    printf 'dir\t%s\n' "$rel"
  fi
}

emit_directory_entries() {
  rel_dir=$1
  abs_dir=$source_dir/$rel_dir

  if [ -L "$abs_dir" ]; then
    emit_entry "$rel_dir"
    return 0
  fi

  if [ ! -d "$abs_dir" ]; then
    return 0
  fi

  for entry in "$abs_dir"/*; do
    if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then
      continue
    fi
    name=$(basename "$entry")
    emit_entry "$rel_dir/$name"
  done
}

write_manifest() {
  printf 'version\t1\n'
  validate_field "$source_dir" "Source directory"
  printf 'source\t%s\n' "$source_dir"

  emit_entry "AGENTS.md"
  emit_entry "AGENTS.override.md"
  emit_directory_entries ".agents/skills"
  emit_directory_entries ".codex/skills"
  emit_directory_entries ".codex/steering"
  emit_directory_entries ".codex/agents"
}

if [ "$output" = "-" ]; then
  write_manifest
else
  output_dir=$(dirname "$output")
  if [ ! -d "$output_dir" ]; then
    echo "Manifest output directory does not exist: $output_dir" >&2
    exit 1
  fi
  write_manifest >"$output"
fi
