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
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle core >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle core >/dev/null
./scripts/setup-ai-context.sh "$tmp_dir" --yes --dry-run >/dev/null

test -f "$tmp_dir/AGENTS.md"
test -f "$tmp_dir/.codex/steering/repository-steering.md"
test -f "$tmp_dir/.codex/steering/angular-steering.md"
test -f "$tmp_dir/.cursor/rules/payload-overview.md"
test -f "$tmp_dir/.codex/skills/planning-files-lite/SKILL.md"
test -f "$tmp_dir/.codex/skills/frontend-design-review/SKILL.md"
test -f "$tmp_dir/.codex/skills/context-engineering/SKILL.md"

setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-setup-check.XXXXXX")
mkdir -p "$setup_dir/src"
touch "$setup_dir/package.json" "$setup_dir/angular.json" "$setup_dir/src/app.component.ts"
./scripts/setup-ai-context.sh "$setup_dir" --yes >/dev/null
test -f "$setup_dir/AGENTS.md"
test -f "$setup_dir/.codex/steering/angular-steering.md"
test -f "$setup_dir/.codex/skills/frontend-design-review/SKILL.md"
test -f "$setup_dir/.codex/skills/api-and-interface-design/SKILL.md"

echo "checks passed"
