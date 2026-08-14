#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$repo_root"

for script in scripts/*.sh; do
  sh -n "$script"
done

./scripts/generate-apm-bundles.sh --check >/dev/null

catalog_bundle_count=$(
  sed -n '/^[[:space:]]*"bundles": \[/,/^[[:space:]]*\]/p' templates/catalog.json |
    sed -n 's/^[[:space:]]*"id": "\([^"]*\)",[[:space:]]*$/\1/p' |
    wc -l | tr -d ' '
)
apm_manifest_count=$(find packages/apm -mindepth 2 -maxdepth 2 -name apm.yml | wc -l | tr -d ' ')
test "$catalog_bundle_count" -eq 18
test "$apm_manifest_count" -eq "$catalog_bundle_count"

for apm_manifest in packages/apm/*/apm.yml; do
  bundle_name=$(basename "$(dirname "$apm_manifest")")
  grep -q "^name: ai-central-$bundle_name$" "$apm_manifest"
  grep -Eq '^version: [0-9]+\.[0-9]+\.[0-9]+$' "$apm_manifest"
  grep -q '^type: skill$' "$apm_manifest"
  grep -q '^includes: auto$' "$apm_manifest"

  apm_dir=$(dirname "$apm_manifest")
  while IFS= read -r dependency_path; do
    test -f "$apm_dir/$dependency_path/SKILL.md"
  done <<EOF
$(sed -n 's/^[[:space:]]*- path: \(.*\)$/\1/p' "$apm_manifest")
EOF
done

test "$(sed -n 's/^[[:space:]]*- path: /x/p' packages/apm/all/apm.yml | wc -l | tr -d ' ')" -eq 129
grep -q '^      alias: claude-playwright-review$' packages/apm/all/apm.yml
test "$(grep -c 'playwright-pro/skills/review' packages/apm/all/apm.yml)" -eq 1
grep -q '^apm_modules/$' .gitignore

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

if grep -Eiq '(^|[^[:alpha:]])(reef|wap|waves|forage|capsule|liars.?dice)([^[:alpha:]]|$)' \
  templates/skills/first-party/project-story-miner/SKILL.md \
  templates/skills/first-party/project-story-miner/references/evidence-brief.md \
  templates/skills/first-party/technical-blog-writer/SKILL.md \
  templates/skills/first-party/technical-blog-writer/references/*.md; then
  echo "Reusable writing guidance contains source-project terminology" >&2
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
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle orchestration >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle documentation >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle delivery >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle brevity >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle jvm >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle frontend-vue >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle frontend-tooling >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle hallmark >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle infra >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle writing >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle writing >/dev/null
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
test -f "$tmp_dir/.agents/skills/planning-files-lite/SKILL.md"
test -f "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md"
test -f "$tmp_dir/.agents/skills/github-keychain-auth/agents/openai.yaml"
test -L "$tmp_dir/.codex/skills/github-keychain-auth"
test -f "$tmp_dir/.codex/skills/github-keychain-auth/SKILL.md"
grep -q 'env -u GH_TOKEN -u GITHUB_TOKEN gh auth status' \
  "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md"
test "$(grep -c 'gh auth token' "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md")" -eq 1
test "$(grep -c 'find-generic-password -w' "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md")" -eq 1
grep -q 'Never run `gh auth token`, `security find-generic-password -w`' \
  "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md"
test -f "$tmp_dir/.agents/skills/context-engineering/SKILL.md"
test -f "$tmp_dir/.agents/skills/independent-review/SKILL.md"
test -f "$tmp_dir/.agents/skills/independent-review/agents/openai.yaml"
test -f "$tmp_dir/.agents/skills/orchestrated-delivery/SKILL.md"
test -f "$tmp_dir/.agents/skills/spec-traceability/SKILL.md"
test -f "$tmp_dir/.agents/skills/session-handoff/SKILL.md"
test -f "$tmp_dir/.agents/skills/research-to-decision/SKILL.md"
test -f "$tmp_dir/.agents/skills/repository-doc-drift/SKILL.md"
test -f "$tmp_dir/.agents/skills/caveman/SKILL.md"
test -f "$tmp_dir/.agents/skills/caveman-compress/SKILL.md"
test -f "$tmp_dir/.agents/skills/kotlin-jvm-engineering/SKILL.md"
test -f "$tmp_dir/.agents/skills/kotlin-jvm-engineering/agents/openai.yaml"
test -f "$tmp_dir/.agents/skills/vue/SKILL.md"
test -f "$tmp_dir/.agents/skills/hallmark-design/SKILL.md"
test -f "$tmp_dir/.agents/skills/terraform-skill/SKILL.md"
test -f "$tmp_dir/.agents/skills/terraform-skill/LICENSE"
test -f "$tmp_dir/.agents/skills/project-story-miner/SKILL.md"
test -f "$tmp_dir/.agents/skills/project-story-miner/agents/openai.yaml"
test -f "$tmp_dir/.agents/skills/technical-blog-writer/SKILL.md"
test -f "$tmp_dir/.agents/skills/technical-blog-writer/assets/article-brief.md"
test -f "$tmp_dir/.agents/skills/humanizer/SKILL.md"
test -f "$tmp_dir/.agents/skills/humanizer/references/pattern-catalog.md"
test -f "$tmp_dir/.agents/skills/toolkit-c4-architecture/SKILL.md"

frontend_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-frontend-check.XXXXXX")
./scripts/install-skill-bundle.sh "$frontend_dir" --bundle frontend >/dev/null
test -f "$frontend_dir/.agents/skills/frontend-design-review/SKILL.md"
test ! -e "$frontend_dir/.agents/skills/vite"

core_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-core-check.XXXXXX")
touch "$core_dir/AGENTS.md"
./scripts/install-skill-bundle.sh "$core_dir" --bundle core >/dev/null
test "$(find "$core_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 9
test ! -e "$core_dir/.agents/skills/frontend-design-review"
test ! -e "$core_dir/.agents/skills/orchestrated-delivery"
./scripts/audit-ai-context.sh "$core_dir" >/dev/null

all_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-all-check.XXXXXX")
./scripts/install-skill-bundle.sh "$all_dir" --bundle all >/dev/null
test "$(find "$all_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 135
test "$(find "$all_dir/.codex/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')" -eq 135

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
test -f "$setup_dir/.agents/skills/frontend-design-review/SKILL.md"
test -f "$setup_dir/.agents/skills/kotlin-jvm-engineering/SKILL.md"
test -f "$setup_dir/.agents/skills/rust-rust-core/SKILL.md"
test ! -e "$setup_dir/.agents/skills/caveman"
test ! -e "$setup_dir/.agents/skills/api-and-interface-design"
test -f "$setup_dir/.agents/skills/web-web-quality-audit/SKILL.md"
test -f "$setup_dir/.agents/skills/vue/SKILL.md"
test -f "$setup_dir/.agents/skills/terraform-skill/SKILL.md"

rust_setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-rust-setup-check.XXXXXX")
touch "$rust_setup_dir/Cargo.toml"
./scripts/setup-ai-context.sh "$rust_setup_dir" --yes >/dev/null
test -f "$rust_setup_dir/.codex/steering/rust-steering.md"
test ! -e "$rust_setup_dir/.codex/steering/javascript-typescript-steering.md"

detection_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-detection-check.XXXXXX")
mkdir -p "$detection_dir/docs/product" "$detection_dir/apps/legacy-admin"
touch "$detection_dir/apps/legacy-admin/angular.json"
detection_output=$(./scripts/setup-ai-context.sh "$detection_dir" --yes --dry-run)
echo "$detection_output" | grep -q '^Detected profiles: base$'
echo "$detection_output" | grep -q '^Detected bundles: core$'

vendor_detection_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-vendor-detection-check.XXXXXX")
mkdir -p "$vendor_detection_dir/node_modules/example"
touch "$vendor_detection_dir/package.json" "$vendor_detection_dir/node_modules/example/page.astro"
vendor_detection_output=$(./scripts/setup-ai-context.sh "$vendor_detection_dir" --yes --dry-run)
echo "$vendor_detection_output" | grep -q '^Detected profiles: base,javascript-typescript$'
echo "$vendor_detection_output" | grep -q '^Detected bundles: core$'

legacy_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-legacy-check.XXXXXX")
mkdir -p "$legacy_dir/.codex/skills/planning-files-lite"
printf '%s\n' 'legacy project-owned skill' >"$legacy_dir/.codex/skills/planning-files-lite/SKILL.md"
legacy_hash=$(shasum -a 256 "$legacy_dir/.codex/skills/planning-files-lite/SKILL.md")
./scripts/install-skill-bundle.sh "$legacy_dir" --bundle core >/dev/null
test -L "$legacy_dir/.agents/skills/planning-files-lite"
test -f "$legacy_dir/.agents/skills/planning-files-lite/SKILL.md"
test "$legacy_hash" = "$(shasum -a 256 "$legacy_dir/.codex/skills/planning-files-lite/SKILL.md")"

link_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-link-check.XXXXXX")
touch "$link_dir/package.json"
./scripts/setup-ai-context.sh "$link_dir" --profiles base,frontend-design --bundles core --mode link --yes >/dev/null
test -f "$link_dir/AGENTS.md"
test ! -L "$link_dir/AGENTS.md"
test -L "$link_dir/.codex/steering/javascript-typescript-steering.md"
test -L "$link_dir/.codex/steering/frontend-design-steering.md"
test -L "$link_dir/.agents/skills/context-engineering"
test -f "$link_dir/.agents/skills/context-engineering/SKILL.md"
test -L "$link_dir/.agents/skills/github-keychain-auth"
test -f "$link_dir/.agents/skills/github-keychain-auth/SKILL.md"
test -L "$link_dir/.codex/skills/context-engineering"
test -f "$link_dir/.codex/skills/context-engineering/SKILL.md"
./scripts/install-skill-bundle.sh "$link_dir" --bundle infra --mode link >/dev/null
test -L "$link_dir/.agents/skills/terraform-skill"
test -f "$link_dir/.agents/skills/terraform-skill/SKILL.md"
./scripts/install-skill-bundle.sh "$link_dir" --bundle jvm --mode link >/dev/null
test -L "$link_dir/.agents/skills/kotlin-jvm-engineering"
test -f "$link_dir/.agents/skills/kotlin-jvm-engineering/SKILL.md"
./scripts/install-skill-bundle.sh "$link_dir" --bundle writing --mode link >/dev/null
test -L "$link_dir/.agents/skills/technical-blog-writer"
test -f "$link_dir/.agents/skills/technical-blog-writer/SKILL.md"
test -L "$link_dir/.codex/skills/technical-blog-writer"

existing_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-existing-check.XXXXXX")
mkdir -p "$existing_dir/.codex/steering"
printf '%s\n' 'project-owned infrastructure steering' >"$existing_dir/.codex/steering/infrastructure-opentofu-steering.md"
existing_hash=$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
test "$existing_hash" = "$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")"

placeholder_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-placeholder-check.XXXXXX")
printf '%s\n' '# {{PROJECT_NAME}}' >"$placeholder_dir/AGENTS.md"
if ./scripts/audit-ai-context.sh "$placeholder_dir" >/dev/null 2>&1; then
  echo "audit accepted an unresolved AGENTS.md placeholder" >&2
  exit 1
fi

legacy_only_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-legacy-only-check.XXXXXX")
mkdir -p "$legacy_only_dir/.codex/skills/example"
touch "$legacy_only_dir/.codex/skills/example/SKILL.md"
if ./scripts/audit-ai-context.sh "$legacy_only_dir" >/dev/null 2>&1; then
  echo "audit accepted a legacy-only skill layout" >&2
  exit 1
fi

echo "checks passed"
