#!/usr/bin/env sh
set -eu

if ! command -v apm >/dev/null 2>&1; then
  echo "APM is not installed; see docs/apm.md" >&2
  exit 2
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-apm-check.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

consumer_dir=$tmp_dir/consumer
mkdir -p "$consumer_dir"

expected_names=$(
  for bundle in core orchestration documentation delivery; do
    sed -n 's#^[[:space:]]*- path: ../../../\(.*\)$#\1#p' "$repo_root/packages/apm/$bundle/apm.yml"
  done |
    while IFS= read -r dependency_path; do
      basename "$dependency_path"
    done |
    sort -u
)

cd "$consumer_dir"
apm install \
  "$repo_root/packages/apm/core" \
  "$repo_root/packages/apm/orchestration" \
  "$repo_root/packages/apm/documentation" \
  "$repo_root/packages/apm/delivery" \
  --target agent-skills \
  --no-policy >"$tmp_dir/install.log"

actual_names=$(
  find .agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; |
    sort
)
test "$actual_names" = "$expected_names"
test "$(printf '%s\n' "$actual_names" | wc -l | tr -d ' ')" -eq 27
test -f apm.yml
test -f apm.lock.yaml
grep -q '^apm_modules/$' .gitignore

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

echo "APM checks passed: 4 bundles, 27 skills, frozen replay, and drift audit"
