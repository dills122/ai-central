#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$repo_root"

for script in scripts/*.sh; do
  sh -n "$script"
done

./scripts/install-skill-bundle.sh --help >/dev/null 2>&1
./scripts/setup-ai-context.sh --help >/dev/null 2>&1
./scripts/generate-apm-selection.sh --help >/dev/null 2>&1

./scripts/check-node-package-api.sh >/dev/null

./scripts/generate-apm-bundles.sh --check >/dev/null

catalog_bundle_count=$(
  sed -n '/^[[:space:]]*"bundles": \[/,/^[[:space:]]*\]/p' templates/catalog.json |
    sed -n 's/^[[:space:]]*"id": "\([^"]*\)",[[:space:]]*$/\1/p' |
    wc -l | tr -d ' '
)
apm_manifest_count=$(find packages/apm -mindepth 2 -maxdepth 2 -name apm.yml | wc -l | tr -d ' ')
test "$catalog_bundle_count" -eq 20
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

test "$(sed -n 's/^[[:space:]]*- path: /x/p' packages/apm/all/apm.yml | wc -l | tr -d ' ')" -eq 137
grep -q '^      alias: claude-playwright-review$' packages/apm/all/apm.yml
test "$(grep -c 'playwright-pro/skills/review' packages/apm/all/apm.yml)" -eq 1
grep -q '^apm_modules/$' .gitignore

apm_selection_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-apm-selection-check.XXXXXX")
apm_selection_file=$apm_selection_dir/apm.yml
./scripts/generate-apm-selection.sh \
  --bundle core,frontend-tooling \
  --skills hallmark-design,claude-a11y-audit \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --name test-ai-context \
  --ref test-ref \
  --output "$apm_selection_file" >/dev/null 2>&1
test "$(grep -c '^    - git:' "$apm_selection_file")" -eq 12
grep -q '^name: test-ai-context$' "$apm_selection_file"
grep -q '^      path: templates/skills/imported/antfu-skills/pnpm$' "$apm_selection_file"
grep -q '^      path: templates/skills/adapted/hallmark-design$' "$apm_selection_file"
grep -q '^      alias: claude-a11y-audit$' "$apm_selection_file"
grep -q '^      ref: test-ref$' "$apm_selection_file"
if grep -q 'antfu-skills/vite$' "$apm_selection_file"; then
  echo "exact APM selection retained an excluded skill" >&2
  exit 1
fi
apm_selection_hash=$(shasum -a 256 "$apm_selection_file")
if ./scripts/generate-apm-selection.sh --output "$apm_selection_file" >/dev/null 2>&1; then
  echo "APM selection generator overwrote an existing manifest" >&2
  exit 1
fi
test "$apm_selection_hash" = "$(shasum -a 256 "$apm_selection_file")"

empty_apm_selection=$(./scripts/generate-apm-selection.sh --bundle none --name empty-ai-context)
echo "$empty_apm_selection" | grep -q '^  apm: \[\]$'

dotnet_apm_selection=$(./scripts/generate-apm-selection.sh \
  --bundle dotnet \
  --skip-skills dotnet-binlog-generation \
  --name dotnet-ai-context)
test "$(echo "$dotnet_apm_selection" | grep -c '^    - git:')" -eq 6
echo "$dotnet_apm_selection" | grep -q '^      path: templates/skills/imported/dotnet-skills/run-tests$'
echo "$dotnet_apm_selection" | grep -q '^      alias: dotnet-run-tests$'
if echo "$dotnet_apm_selection" | grep -q 'dotnet-skills/binlog-generation$'; then
  echo ".NET APM selection retained an excluded skill" >&2
  exit 1
fi

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
  templates/steering/dotnet-csharp-steering.md \
  templates/steering/dotnet-aspnetcore-steering.md \
  templates/steering/dotnet-efcore-steering.md \
  templates/steering/dotnet-orleans-steering.md \
  templates/steering/dotnet-aspire-steering.md \
  templates/steering/dotnet-opentelemetry-steering.md \
  templates/steering/dotnet-grpc-steering.md \
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
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-csharp >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-aspnetcore >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-efcore >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-orleans >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-aspire >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-opentelemetry >/dev/null
./scripts/scaffold-ai-context.sh "$tmp_dir" --profile dotnet-grpc >/dev/null
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
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle node >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle orchestration >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle documentation >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle delivery >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle brevity >/dev/null
./scripts/install-skill-bundle.sh "$tmp_dir" --bundle dotnet >/dev/null
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
test -f "$tmp_dir/.codex/steering/dotnet-csharp-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-aspnetcore-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-efcore-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-orleans-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-aspire-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-opentelemetry-steering.md"
test -f "$tmp_dir/.codex/steering/dotnet-grpc-steering.md"
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
grep -q 'Run every credential-dependent.*outside the sandbox' \
  "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md"
grep -q 'Never run `gh auth token`, `security find-generic-password -w`' \
  "$tmp_dir/.agents/skills/github-keychain-auth/SKILL.md"
test -f "$tmp_dir/.agents/skills/context-engineering/SKILL.md"
test -f "$tmp_dir/.agents/skills/independent-review/SKILL.md"
test -f "$tmp_dir/.agents/skills/independent-review/agents/openai.yaml"
grep -q 'Default to at most three review instances' \
  "$tmp_dir/.agents/skills/independent-review/SKILL.md"
grep -q 'Hard-stop the flow when a review concludes' \
  "$tmp_dir/.agents/skills/independent-review/SKILL.md"
test -f "$tmp_dir/.agents/skills/inspect-node-package-api/SKILL.md"
test -f "$tmp_dir/.agents/skills/inspect-node-package-api/scripts/inspect-package-api.mjs"
test -f "$tmp_dir/.agents/skills/orchestrated-delivery/SKILL.md"
test -f "$tmp_dir/.agents/skills/spec-traceability/SKILL.md"
test -f "$tmp_dir/.agents/skills/session-handoff/SKILL.md"
test -f "$tmp_dir/.agents/skills/research-to-decision/SKILL.md"
test -f "$tmp_dir/.agents/skills/repository-doc-drift/SKILL.md"
test -f "$tmp_dir/.agents/skills/caveman/SKILL.md"
test -f "$tmp_dir/.agents/skills/caveman-compress/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-run-tests/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-test-platform-detection/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-test-filter-syntax/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-directory-build-organization/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-msbuild-antipatterns/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-binlog-generation/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-binlog-failure-analysis/SKILL.md"
test -f "$tmp_dir/.agents/skills/dotnet-run-tests/LICENSE"
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

for direct_profile in \
  dotnet-aspnetcore dotnet-efcore dotnet-orleans dotnet-aspire dotnet-opentelemetry dotnet-grpc; do
  direct_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-$direct_profile-check.XXXXXX")
  ./scripts/scaffold-ai-context.sh "$direct_dir" --profile "$direct_profile" >/dev/null
  ./scripts/scaffold-ai-context.sh "$direct_dir" --profile "$direct_profile" >/dev/null
  test -f "$direct_dir/.codex/steering/dotnet-csharp-steering.md"
  test -f "$direct_dir/.codex/steering/$direct_profile-steering.md"
  for sibling_profile in aspnetcore efcore orleans aspire opentelemetry grpc; do
    if [ "$direct_profile" != "dotnet-$sibling_profile" ]; then
      test ! -e "$direct_dir/.codex/steering/dotnet-$sibling_profile-steering.md"
    fi
  done
done

dotnet_composed_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-dotnet-composed-check.XXXXXX")
./scripts/scaffold-ai-context.sh "$dotnet_composed_dir" \
  --profile dotnet-orleans,dotnet-grpc >/dev/null
test -f "$dotnet_composed_dir/.codex/steering/dotnet-csharp-steering.md"
test -f "$dotnet_composed_dir/.codex/steering/dotnet-orleans-steering.md"
test -f "$dotnet_composed_dir/.codex/steering/dotnet-grpc-steering.md"
test ! -e "$dotnet_composed_dir/.codex/steering/dotnet-aspnetcore-steering.md"

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
test "$(find "$all_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 143
test "$(find "$all_dir/.codex/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')" -eq 143

selector_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-selector-check.XXXXXX")
./scripts/install-skill-bundle.sh "$selector_dir" \
  --bundle core,frontend-tooling \
  --skills hallmark-design \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --mode link >/dev/null
test "$(find "$selector_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 11
test -L "$selector_dir/.agents/skills/pnpm"
test -L "$selector_dir/.agents/skills/hallmark-design"
test ! -e "$selector_dir/.agents/skills/vite"
test ! -e "$selector_dir/.agents/skills/vitest"
test ! -e "$selector_dir/.agents/skills/turborepo"
test ! -e "$selector_dir/.agents/skills/vitepress"
test ! -e "$selector_dir/.agents/skills/slidev"

dotnet_selector_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-dotnet-selector-check.XXXXXX")
./scripts/install-skill-bundle.sh "$dotnet_selector_dir" \
  --bundle dotnet \
  --skills pnpm \
  --skip-skills dotnet-binlog-generation \
  --mode link >/dev/null
test "$(find "$dotnet_selector_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 7
test -L "$dotnet_selector_dir/.agents/skills/dotnet-run-tests"
test -L "$dotnet_selector_dir/.agents/skills/pnpm"
test ! -e "$dotnet_selector_dir/.agents/skills/dotnet-binlog-generation"

exact_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-exact-check.XXXXXX")
./scripts/install-skill-bundle.sh "$exact_dir" --bundle none --skills pnpm >/dev/null
test "$(find "$exact_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 1
test -f "$exact_dir/.agents/skills/pnpm/SKILL.md"

if ./scripts/install-skill-bundle.sh "$exact_dir" --bundle core --skills not-a-skill >/dev/null 2>&1; then
  echo "skill installer accepted an unknown exact inclusion" >&2
  exit 1
fi
if ./scripts/install-skill-bundle.sh "$exact_dir" --bundle core --skip-skills not-a-skill >/dev/null 2>&1; then
  echo "skill installer accepted an unknown exact exclusion" >&2
  exit 1
fi
if ./scripts/install-skill-bundle.sh "$exact_dir" --bundle core --sync >/dev/null 2>&1; then
  echo "skill installer accepted --sync in copy mode" >&2
  exit 1
fi

invalid_setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-invalid-setup-check.XXXXXX")
if ./scripts/setup-ai-context.sh "$invalid_setup_dir" \
  --yes \
  --profiles base \
  --bundles core \
  --skills not-a-skill >/dev/null 2>&1; then
  echo "setup accepted an unknown exact inclusion" >&2
  exit 1
fi
test ! -e "$invalid_setup_dir/AGENTS.md"
test ! -e "$invalid_setup_dir/.agents"
test ! -e "$invalid_setup_dir/.codex"

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
test -f "$setup_dir/.agents/skills/inspect-node-package-api/SKILL.md"
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

dotnet_setup_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-dotnet-setup-check.XXXXXX")
mkdir -p "$dotnet_setup_dir/src/Protos"
printf '%s\n' \
  '<Project Sdk="Microsoft.NET.Sdk.Web">' \
  '  <PropertyGroup><IsAspireHost>true</IsAspireHost></PropertyGroup>' \
  '  <ItemGroup>' \
  '    <PackageReference Include="Microsoft.EntityFrameworkCore" />' \
  '    <PackageReference Include="Microsoft.Orleans.Server" />' \
  '    <PackageReference Include="Aspire.Hosting" />' \
  '    <PackageReference Include="OpenTelemetry.Extensions.Hosting" />' \
  '    <PackageReference Include="Grpc.AspNetCore" />' \
  '    <Protobuf Include="src/Protos/service.proto" />' \
  '  </ItemGroup>' \
  '</Project>' >"$dotnet_setup_dir/App.csproj"
touch "$dotnet_setup_dir/src/Program.cs" "$dotnet_setup_dir/src/Protos/service.proto"
dotnet_detection_output=$(./scripts/setup-ai-context.sh "$dotnet_setup_dir" --yes --dry-run)
echo "$dotnet_detection_output" | grep -q '^Detected profiles: base,dotnet-csharp,dotnet-aspnetcore,dotnet-efcore,dotnet-orleans,dotnet-aspire,dotnet-opentelemetry,dotnet-grpc$'
echo "$dotnet_detection_output" | grep -q '^Detected bundles: core,dotnet$'
./scripts/setup-ai-context.sh "$dotnet_setup_dir" --yes >/dev/null
test -f "$dotnet_setup_dir/.codex/steering/dotnet-csharp-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-aspnetcore-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-efcore-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-orleans-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-aspire-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-opentelemetry-steering.md"
test -f "$dotnet_setup_dir/.codex/steering/dotnet-grpc-steering.md"
test -f "$dotnet_setup_dir/.agents/skills/dotnet-run-tests/SKILL.md"
test -f "$dotnet_setup_dir/.agents/skills/dotnet-run-tests/LICENSE"

proto_only_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-proto-only-check.XXXXXX")
mkdir -p "$proto_only_dir/obj"
touch "$proto_only_dir/service.proto" "$proto_only_dir/obj/Generated.cs"
proto_only_output=$(./scripts/setup-ai-context.sh "$proto_only_dir" --yes --dry-run)
echo "$proto_only_output" | grep -q '^Detected profiles: base$'
echo "$proto_only_output" | grep -q '^Detected bundles: core$'

detection_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-detection-check.XXXXXX")
mkdir -p "$detection_dir/docs/product" "$detection_dir/apps/legacy-admin"
touch "$detection_dir/apps/legacy-admin/angular.json"
detection_output=$(./scripts/setup-ai-context.sh "$detection_dir" --yes --dry-run)
echo "$detection_output" | grep -q '^Detected profiles: base$'
echo "$detection_output" | grep -q '^Detected bundles: core$'

vendor_detection_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-vendor-detection-check.XXXXXX")
mkdir -p "$vendor_detection_dir/node_modules/example"
touch "$vendor_detection_dir/package.json" "$vendor_detection_dir/node_modules/example/page.astro" "$vendor_detection_dir/node_modules/example/Generated.cs"
vendor_detection_output=$(./scripts/setup-ai-context.sh "$vendor_detection_dir" --yes --dry-run)
echo "$vendor_detection_output" | grep -q '^Detected profiles: base,javascript-typescript$'
echo "$vendor_detection_output" | grep -q '^Detected bundles: core,node$'

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
./scripts/install-skill-bundle.sh "$link_dir" --bundle dotnet --mode link >/dev/null
test -L "$link_dir/.agents/skills/dotnet-run-tests"
test -f "$link_dir/.agents/skills/dotnet-run-tests/SKILL.md"
test -f "$link_dir/.agents/skills/dotnet-run-tests/LICENSE"
./scripts/install-skill-bundle.sh "$link_dir" --bundle writing --mode link >/dev/null
test -L "$link_dir/.agents/skills/technical-blog-writer"
test -f "$link_dir/.agents/skills/technical-blog-writer/SKILL.md"
test -L "$link_dir/.codex/skills/technical-blog-writer"

sync_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-sync-check.XXXXXX")
./scripts/install-skill-bundle.sh "$sync_dir" --bundle core,frontend-tooling --mode link >/dev/null
mkdir -p "$sync_dir/.agents/skills/project-owned" "$sync_dir/foreign-source"
printf '%s\n' '# Project-owned skill' >"$sync_dir/.agents/skills/project-owned/SKILL.md"
printf '%s\n' '# Foreign skill source' >"$sync_dir/foreign-source/SKILL.md"
ln -s "$sync_dir/foreign-source" "$sync_dir/.agents/skills/foreign-link"
rm "$sync_dir/.agents/skills/vite"
ln -s "$sync_dir/foreign-source" "$sync_dir/.agents/skills/vite"
rm "$sync_dir/.agents/skills/slidev"
mkdir -p "$sync_dir/.agents/skills/slidev"
printf '%s\n' '# Project-owned replacement' >"$sync_dir/.agents/skills/slidev/SKILL.md"
slidev_hash=$(shasum -a 256 "$sync_dir/.agents/skills/slidev/SKILL.md")

sync_dry_output=$(./scripts/install-skill-bundle.sh "$sync_dir" \
  --bundle core \
  --skills pnpm \
  --mode link \
  --sync \
  --dry-run)
echo "$sync_dry_output" | grep -q "would remove managed link $sync_dir/.agents/skills/vitest"
echo "$sync_dry_output" | grep -q "would remove managed link $sync_dir/.codex/skills/vitest"
test -L "$sync_dir/.agents/skills/vitest"
test -L "$sync_dir/.codex/skills/vitest"

./scripts/install-skill-bundle.sh "$sync_dir" \
  --bundle core \
  --skills pnpm \
  --mode link \
  --sync >/dev/null
test -L "$sync_dir/.agents/skills/pnpm"
test ! -e "$sync_dir/.agents/skills/vitest"
test ! -L "$sync_dir/.agents/skills/vitest"
test ! -e "$sync_dir/.codex/skills/vitest"
test ! -L "$sync_dir/.codex/skills/vitest"
test -d "$sync_dir/.agents/skills/project-owned"
test -f "$sync_dir/.agents/skills/project-owned/SKILL.md"
test -L "$sync_dir/.agents/skills/foreign-link"
test -L "$sync_dir/.agents/skills/vite"
test "$(readlink "$sync_dir/.agents/skills/vite")" = "$sync_dir/foreign-source"
test -L "$sync_dir/.codex/skills/vite"
test -d "$sync_dir/.agents/skills/slidev"
test ! -L "$sync_dir/.agents/skills/slidev"
test "$slidev_hash" = "$(shasum -a 256 "$sync_dir/.agents/skills/slidev/SKILL.md")"
test -L "$sync_dir/.codex/skills/slidev"

dotnet_sync_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-dotnet-sync-check.XXXXXX")
./scripts/install-skill-bundle.sh "$dotnet_sync_dir" --bundle dotnet --mode link >/dev/null
./scripts/install-skill-bundle.sh "$dotnet_sync_dir" \
  --bundle dotnet \
  --skip-skills dotnet-binlog-generation \
  --mode link \
  --sync >/dev/null
test -L "$dotnet_sync_dir/.agents/skills/dotnet-run-tests"
test ! -e "$dotnet_sync_dir/.agents/skills/dotnet-binlog-generation"
test ! -e "$dotnet_sync_dir/.codex/skills/dotnet-binlog-generation"

setup_dry_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-setup-dry-check.XXXXXX")
touch "$setup_dry_dir/package.json" "$setup_dry_dir/angular.json"
setup_dry_output=$(./scripts/setup-ai-context.sh "$setup_dry_dir" \
  --yes \
  --profiles base,angular,frontend-design \
  --bundles core,frontend-tooling \
  --skills hallmark-design \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --mode link \
  --sync \
  --dry-run)
test "$(echo "$setup_dry_output" | grep -c "would create $setup_dry_dir/AGENTS.md")" -eq 1
test "$(echo "$setup_dry_output" | grep -c "would link $setup_dry_dir/.codex/steering/javascript-typescript-steering.md")" -eq 1
echo "$setup_dry_output" | grep -q "would link $setup_dry_dir/.agents/skills/pnpm"
echo "$setup_dry_output" | grep -q "would link $setup_dry_dir/.agents/skills/hallmark-design"
test ! -e "$setup_dry_dir/AGENTS.md"
test ! -e "$setup_dry_dir/.agents"
test ! -e "$setup_dry_dir/.codex"

setup_exact_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-setup-exact-check.XXXXXX")
./scripts/setup-ai-context.sh "$setup_exact_dir" \
  --yes \
  --profiles base \
  --bundles none \
  --skills pnpm >/dev/null
test "$(find "$setup_exact_dir/.agents/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" -eq 1
test -f "$setup_exact_dir/.agents/skills/pnpm/SKILL.md"

existing_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-existing-check.XXXXXX")
mkdir -p "$existing_dir/.codex/steering"
printf '%s\n' 'project-owned infrastructure steering' >"$existing_dir/.codex/steering/infrastructure-opentofu-steering.md"
existing_hash=$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
./scripts/scaffold-ai-context.sh "$existing_dir" --profile infrastructure-opentofu >/dev/null
test "$existing_hash" = "$(shasum -a 256 "$existing_dir/.codex/steering/infrastructure-opentofu-steering.md")"

grpc_existing_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-grpc-existing-check.XXXXXX")
mkdir -p "$grpc_existing_dir/.codex/steering"
printf '%s\n' 'project-owned gRPC steering' >"$grpc_existing_dir/.codex/steering/dotnet-grpc-steering.md"
grpc_existing_hash=$(shasum -a 256 "$grpc_existing_dir/.codex/steering/dotnet-grpc-steering.md")
./scripts/scaffold-ai-context.sh "$grpc_existing_dir" --profile dotnet-grpc >/dev/null
test "$grpc_existing_hash" = "$(shasum -a 256 "$grpc_existing_dir/.codex/steering/dotnet-grpc-steering.md")"

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

worktree_context_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-worktree-context-check.XXXXXX")
worktree_context_dir=$(CDPATH= cd -- "$worktree_context_dir" && pwd -P)
worktree_primary=$worktree_context_dir/primary
worktree_target=$worktree_context_dir/target
shared_skills=$worktree_context_dir/shared-skills
mkdir -p "$worktree_primary" "$shared_skills/canonical" "$shared_skills/legacy"
printf '%s\n' '# Canonical skill' >"$shared_skills/canonical/SKILL.md"
printf '%s\n' '# Legacy skill' >"$shared_skills/legacy/SKILL.md"

git -C "$worktree_primary" init -q
printf '%s\n' 'tracked project file' >"$worktree_primary/README.md"
git -C "$worktree_primary" add README.md
git -C "$worktree_primary" \
  -c user.name='AI Central Test' \
  -c user.email='ai-central@example.invalid' \
  -c commit.gpgsign=false \
  commit -qm 'Initial test fixture'
git -C "$worktree_primary" worktree add -q --detach "$worktree_target" HEAD

exclude_file=$(git -C "$worktree_primary" rev-parse --path-format=absolute --git-path info/exclude)
printf '%s\n' \
  '/AGENTS.md' \
  '/.agents/skills/' \
  '/.codex/skills/' \
  '/.codex/steering/' \
  '/.codex/agents/' \
  '/.env' >>"$exclude_file"

mkdir -p \
  "$worktree_primary/.agents/skills" \
  "$worktree_primary/.codex/skills" \
  "$worktree_primary/.codex/steering" \
  "$worktree_primary/.codex/agents" \
  "$worktree_target/.codex/steering"
printf '%s\n' '# Primary instructions' >"$worktree_primary/AGENTS.md"
printf '%s\n' 'primary steering' >"$worktree_primary/.codex/steering/repository-steering.md"
printf '%s\n' 'reviewer definition' >"$worktree_primary/.codex/agents/reviewer.toml"
printf '%s\n' 'do not copy this secret' >"$worktree_primary/.env"
ln -s "$shared_skills/canonical" "$worktree_primary/.agents/skills/canonical"
ln -s '../../.agents/skills/canonical' "$worktree_primary/.codex/skills/canonical"
ln -s "$shared_skills/legacy" "$worktree_primary/.codex/skills/legacy"
printf '%s\n' 'target-owned steering' >"$worktree_target/.codex/steering/repository-steering.md"

worktree_manifest=$worktree_context_dir/context.tsv
./scripts/create-worktree-context-manifest.sh "$worktree_primary" --output "$worktree_manifest"
grep -q "^source$(printf '\t')$worktree_primary$" "$worktree_manifest"
grep -q "^link$(printf '\t').agents/skills/canonical$(printf '\t')$shared_skills/canonical$" "$worktree_manifest"
if grep -q '\.env' "$worktree_manifest"; then
  echo "worktree context manifest included a non-allowlisted secret" >&2
  exit 1
fi

worktree_dry_run=$(./scripts/setup-codex-worktree.sh "$worktree_target" --dry-run)
echo "$worktree_dry_run" | grep -q 'adopt legacy skill .*\.agents/skills/legacy'
test ! -e "$worktree_target/AGENTS.md"

./scripts/setup-codex-worktree.sh "$worktree_target" >/dev/null
test -f "$worktree_target/AGENTS.md"
grep -q '^target-owned steering$' "$worktree_target/.codex/steering/repository-steering.md"
test -f "$worktree_target/.codex/agents/reviewer.toml"
test -L "$worktree_target/.agents/skills/canonical"
test -f "$worktree_target/.agents/skills/canonical/SKILL.md"
test -L "$worktree_target/.codex/skills/canonical"
test -f "$worktree_target/.codex/skills/canonical/SKILL.md"
test -L "$worktree_target/.codex/skills/legacy"
test -L "$worktree_target/.agents/skills/legacy"
test -f "$worktree_target/.agents/skills/legacy/SKILL.md"
test ! -e "$worktree_target/.env"

./scripts/setup-codex-worktree.sh "$worktree_target" >/dev/null
grep -q '^target-owned steering$' "$worktree_target/.codex/steering/repository-steering.md"

echo "checks passed"
