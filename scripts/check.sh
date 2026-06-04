#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$repo_root"

for script in scripts/*.sh; do
  sh -n "$script"
done

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-check.XXXXXX")

./scripts/scaffold-ai-context.sh "$tmp_dir" --profile angular >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile angular >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile payload >/dev/null

test -f "$tmp_dir/AGENTS.md"
test -f "$tmp_dir/.codex/steering/repository-steering.md"
test -f "$tmp_dir/.codex/steering/angular-steering.md"
test -f "$tmp_dir/.cursor/rules/payload-overview.md"

echo "checks passed"
