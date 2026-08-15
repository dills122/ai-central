#!/usr/bin/env sh
set -eu

if ! command -v apm >/dev/null 2>&1; then
  echo "APM is not installed; see docs/apm.md" >&2
  exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-apm-check.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

"$repo_root/scripts/generate-apm-bundles.sh" --check >/dev/null

expected_names=$(
  awk '
    /^[[:space:]]*- path: / {
      if (name != "") print name
      path = $0
      sub(/^[[:space:]]*- path: /, "", path)
      count = split(path, parts, "/")
      name = parts[count]
      next
    }
    /^[[:space:]]+alias: / {
      alias = $0
      sub(/^[[:space:]]+alias: /, "", alias)
      name = alias
      next
    }
    END {
      if (name != "") print name
    }
  ' "$repo_root/packages/apm/all/apm.yml" | sort
)

all_consumer_dir=$tmp_dir/all-consumer
mkdir -p "$all_consumer_dir"
cd "$all_consumer_dir"
apm install "$repo_root/packages/apm/all" \
  --target agent-skills --no-policy >"$tmp_dir/install.log"

actual_names=$(
  find .agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; |
    sort
)
test "$actual_names" = "$expected_names"
test "$(printf '%s\n' "$actual_names" | wc -l | tr -d ' ')" -eq 137
test -f .agents/skills/claude-playwright-review/SKILL.md
test ! -e .agents/skills/claude-review
test -f .agents/skills/technical-blog-writer/SKILL.md
test -f .agents/skills/orchestrated-delivery/SKILL.md
test -f .agents/skills/dotnet-run-tests/SKILL.md
test -f .agents/skills/dotnet-run-tests/LICENSE
test -f apm.yml
test -f apm.lock.yaml
grep -q '^apm_modules/$' .gitignore

# APM 0.28.0 does not preserve local dependency aliases during frozen replay.
# Exercise replay and drift detection with the alias-free core package while
# still checking the complete alias-rich package above through a fresh install.
core_consumer_dir=$tmp_dir/core-consumer
mkdir -p "$core_consumer_dir"
cd "$core_consumer_dir"
apm install "$repo_root/packages/apm/core" \
  --target agent-skills --no-policy >"$tmp_dir/core-install.log"
apm install --frozen --no-policy >"$tmp_dir/frozen.log"
apm audit --no-policy >"$tmp_dir/audit.log"
if grep -q 'Drift detected' "$tmp_dir/audit.log"; then
  cat "$tmp_dir/audit.log" >&2
  exit 1
fi

if apm audit --ci --no-policy >"$tmp_dir/audit-ci.log" 2>&1; then
  echo "APM CI audit passed"
elif grep -q 'config-consistency' "$tmp_dir/audit-ci.log"; then
  echo "WARN: APM CI audit hit the documented local SKILL.md config-consistency limitation" >&2
else
  cat "$tmp_dir/audit-ci.log" >&2
  exit 1
fi

echo "APM checks passed: 20 bundles, 137 unique skills, and alias-free frozen replay/audit"
