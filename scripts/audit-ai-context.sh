#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TARGET_DIR" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

target_dir=$1
if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

errors=0
warnings=0
canonical_dir=$target_dir/.agents/skills
legacy_dir=$target_dir/.codex/skills

error() {
  echo "ERROR: $*" >&2
  errors=$((errors + 1))
}

warn() {
  echo "WARN: $*" >&2
  warnings=$((warnings + 1))
}

if [ ! -f "$target_dir/AGENTS.md" ]; then
  warn "missing repository AGENTS.md"
else
  if grep -En '\{\{[A-Z0-9_]+\}\}' "$target_dir/AGENTS.md" >/dev/null 2>&1; then
    error "AGENTS.md contains unresolved template placeholders"
    grep -En '\{\{[A-Z0-9_]+\}\}' "$target_dir/AGENTS.md" >&2
  fi
fi

if [ ! -d "$canonical_dir" ]; then
  if [ -d "$legacy_dir" ]; then
    error "skills exist only under legacy .codex/skills; install or link them under .agents/skills"
  else
    warn "no repository skills installed"
  fi
else
  skill_count=0
  for skill_dir in "$canonical_dir"/*; do
    if [ ! -e "$skill_dir" ] && [ ! -L "$skill_dir" ]; then
      continue
    fi
    skill_count=$((skill_count + 1))
    if [ -L "$skill_dir" ] && [ ! -e "$skill_dir" ]; then
      error "broken canonical skill link: $skill_dir"
    elif [ ! -f "$skill_dir/SKILL.md" ]; then
      error "canonical skill is missing SKILL.md: $skill_dir"
    fi
  done

  if [ "$skill_count" -gt 40 ]; then
    warn "$skill_count repository skills may exceed practical discovery budget; prefer smaller bundles"
  fi
fi

if [ -d "$legacy_dir" ]; then
  for legacy_entry in "$legacy_dir"/*; do
    if [ ! -e "$legacy_entry" ] && [ ! -L "$legacy_entry" ]; then
      continue
    fi
    if [ -L "$legacy_entry" ] && [ ! -e "$legacy_entry" ]; then
      error "broken legacy compatibility link: $legacy_entry"
    elif [ ! -L "$legacy_entry" ]; then
      warn "legacy skill is a real directory, not a compatibility symlink: $legacy_entry"
    fi
  done
fi

echo "AI context audit: errors=$errors warnings=$warnings"
test "$errors" -eq 0
