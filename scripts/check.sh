#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$repo_root"

for script in scripts/*.sh; do
  sh -n "$script"
done

if grep -Eiq 'reef|order book|matching engine|trading|market data|settlement' \
  templates/steering/kotlin-jvm-steering.md \
  templates/skills/adapted/kotlin-jvm-engineering/SKILL.md; then
  echo "Kotlin/JVM reusable guidance contains project-domain terminology" >&2
  exit 1
fi

if grep -Eiq 'wap|waves|wml|wsp|wtp|lowband|forage|capsule|liars.?dice' \
  templates/steering/javascript-typescript-steering.md \
  templates/steering/rust-steering.md \
  templates/steering/shell-scripting-steering.md; then
  echo "Reusable language guidance contains source-project terminology" >&2
  exit 1
fi

for language_template in \
  templates/steering/javascript-typescript-steering.md \
  templates/steering/kotlin-jvm-steering.md \
  templates/steering/rust-steering.md \
  templates/steering/shell-scripting-steering.md; do
  grep -q '^## Scope And Enforcement$' "$language_template"
  grep -q '^## Testing And Quality Gates$' "$language_template"
  grep -q '^## Verification$' "$language_template"
done

base_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-base-check.XXXXXX")
./scripts/scaffold-ai-context.sh "$base_dir" --profile base >/dev/null
test -f "$base_dir/.codex/steering/repository-steering.md"
test ! -e "$base_dir/.codex/steering/javascript-typescript-steering.md"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-check.XXXXXX")

./scripts/scaffold-ai-context.sh "$tmp_dir" --profile javascript-typescript >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile javascript-typescript >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile angular >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile angular >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile kotlin-jvm >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile kotlin-jvm >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile rust >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile shell-scripting >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile payload >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile infrastructure-opentofu >/dev/null
infrastructure_hash=$(shasum -a 256 "$tmp_dir/.codex/steering/infrastructure-opentofu-steering.md")
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile infrastructure-opentofu >/dev/null
test "$infrastructure_hash" = "$(shasum -a 256 "$tmp_dir/.codex/steering/infrastructure-opentofu-steering.md")"
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle core >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle core >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle brevity >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle jvm >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle frontend-vue >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle frontend-tooling >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle hallmark >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle infra >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle workflow >/dev/null
./scripts/setup-ai-context.sh "$tmp_dir" --yes --dry-run >/dev/null
./scripts/setup-ai-context.sh "$tmp_dir" --yes --mode link --dry-run >/dev/null

test -f "$tmp_dir/AGENTS.md"
test -f "$tmp_dir/.codex/steering/repository-steering.md"
test -f "$tmp_dir/.codex/steering/javascript-typescript-steering.md"
test -f "$tmp_dir/.codex/steering/angular-steering.md"
test -f "$tmp_dir/.codex/steering/kotlin-jvm-steering.md"
test -f "$tmp_dir/.codex/steering/rust-steering.md"
test -f "$tmp_dir/.codex/steering/shell-scripting-steering.md"
test -f "$tmp_dir/.cursor/rules/payload-overview.md"
test -f "$tmp_dir/.codex/steering/infrastructure-opentofu-steering.md"
test -f "$tmp_dir/.codex/skills/planning-files-lite/SKILL.md"
test -f "$tmp_dir/.codex/skills/frontend-design-review/SKILL.md"
test -f "$tmp_dir/.codex/skills/context-engineering/SKILL.md"
test -f "$tmp_dir/.codex/skills/caveman/SKILL.md"
test -f "$tmp_dir/.codex/skills/caveman-compress/SKILL.md"
test -f "$tmp_dir/.codex/skills/kotlin-jvm-engineering/SKILL.md"
test -f "$tmp_dir/.codex/skills/kotlin-jvm-engineering/agents/openai.yaml"
test -f "$tmp_dir/.codex/skills/vue/SKILL.md"
test -f "$tmp_dir/.codex/skills/hallmark-design/SKILL.md"
test -f "$tmp_dir/.codex/skills/terraform-skill/SKILL.md"
test -f "$tmp_dir/.codex/skills/terraform-skill/LICENSE"
test -f "$tmp_dir/.codex/skills/toolkit-c4-architecture/SKILL.md"

frontend_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-frontend-check.XXXXXX")
./scripts/install-skill-bundle.sh "$frontend_dir" --bundle frontend >/dev/null
test -f "$frontend_dir/.codex/skills/frontend-design-review/SKILL.md"
test ! -e "$frontend_dir/.codex/skills/vite"

setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-setup-check.XXXXXX")
mkdir -p "$setup_dir/src"
touch "$setup_dir/package.json" "$setup_dir/angular.json" "$setup_dir/Cargo.toml" "$setup_dir/main.tf" "$setup_dir/src/app.component.ts" "$setup_dir/src/App.vue" "$setup_dir/src/App.kt"
./scripts/setup-ai-context.sh "$setup_dir" --yes >/dev/null
test -f "$setup_dir/AGENTS.md"
test -f "$setup_dir/.codex/steering/javascript-typescript-steering.md"
test -f "$setup_dir/.codex/steering/angular-steering.md"
test -f "$setup_dir/.codex/steering/kotlin-jvm-steering.md"
test -f "$setup_dir/.codex/steering/rust-steering.md"
test -f "$setup_dir/.codex/steering/infrastructure-opentofu-steering.md"
test -f "$setup_dir/.codex/skills/frontend-design-review/SKILL.md"
test -f "$setup_dir/.codex/skills/kotlin-jvm-engineering/SKILL.md"
test -f "$setup_dir/.codex/skills/rust-rust-core/SKILL.md"
test ! -e "$setup_dir/.codex/skills/caveman"
test ! -e "$setup_dir/.codex/skills/api-and-interface-design"
test -f "$setup_dir/.codex/skills/web-web-quality-audit/SKILL.md"
test -f "$setup_dir/.codex/skills/vue/SKILL.md"
test -f "$setup_dir/.codex/skills/terraform-skill/SKILL.md"

rust_setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-rust-setup-check.XXXXXX")
touch "$rust_setup_dir/Cargo.toml"
./scripts/setup-ai-context.sh "$rust_setup_dir" --yes >/dev/null
test -f "$rust_setup_dir/.codex/steering/rust-steering.md"
test ! -e "$rust_setup_dir/.codex/steering/javascript-typescript-steering.md"

link_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-link-check.XXXXXX")
touch "$link_dir/package.json"
./scripts/setup-ai-context.sh "$link_dir" --profiles base,frontend-design --bundles core --mode link --yes >/dev/null
test -f "$link_dir/AGENTS.md"
test ! -L "$link_dir/AGENTS.md"
test -L "$link_dir/.codex/steering/javascript-typescript-steering.md"
test -L "$link_dir/.codex/steering/frontend-design-steering.md"
test -L "$link_dir/.codex/skills/context-engineering"
test -f "$link_dir/.codex/skills/context-engineering/SKILL.md"
./scripts/install-skill-bundle.sh "$link_dir" --bundle infra --mode link >/dev/null
test -L "$link_dir/.codex/skills/terraform-skill"
test -f "$link_dir/.codex/skills/terraform-skill/SKILL.md"
./scripts/install-skill-bundle.sh "$link_dir" --bundle jvm --mode link >/dev/null
test -L "$link_dir/.codex/skills/kotlin-jvm-engineering"
test -f "$link_dir/.codex/skills/kotlin-jvm-engineering/SKILL.md"

existing_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-existing-check.XXXXXX")
mkdir -p "$existing_dir/.codex/steering"
printf '%s\n' 'project-owned infrastructure steering' >"$existing_dir/.codex/steering/infrastructure-opentofu-steering.md"
existing_hash=$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
test "$existing_hash" = "$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")"

echo "checks passed"
