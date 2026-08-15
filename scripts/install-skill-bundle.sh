#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: install-skill-bundle.sh TARGET_DIR [options]

Options:
  --bundle LIST       Comma-separated bundles; repeatable. Defaults to core.
                      Use none with --skills or --sync to select no bundle.
  --skills LIST       Comma-separated installed skill names to add.
  --skip-skills LIST  Comma-separated installed skill names to exclude.
  --mode copy|link    Copy skills or link them to AI Central. Defaults to copy.
  --sync              In link mode, prune deselected AI Central-managed links.
  --dry-run           Show exact creates, links, skips, and removals.
  --help              Show this help.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

case "$1" in
  --help|-h)
    usage
    exit 0
    ;;
esac

target_dir=$1
shift

bundles=
bundle_supplied=0
skills=
skip_skills=
mode=copy
sync=0
dry_run=0

append_csv() {
  current=$1
  addition=$2
  if [ -z "$current" ]; then
    printf "%s" "$addition"
  elif [ -z "$addition" ]; then
    printf "%s" "$current"
  else
    printf "%s,%s" "$current" "$addition"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --bundle)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      bundles=$(append_csv "$bundles" "$2")
      bundle_supplied=1
      shift 2
      ;;
    --skills)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      skills=$(append_csv "$skills" "$2")
      shift 2
      ;;
    --skip-skills)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      skip_skills=$(append_csv "$skip_skills" "$2")
      shift 2
      ;;
    --mode)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      mode=$2
      shift 2
      ;;
    --sync)
      sync=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [ "$bundle_supplied" -eq 0 ]; then
  bundles=core
fi

case "$mode" in
  copy|link) ;;
  *)
    echo "Unknown mode: $mode" >&2
    usage
    exit 2
    ;;
esac

if [ "$sync" -eq 1 ] && [ "$mode" != "link" ]; then
  echo "--sync requires --mode link because copied or project-owned directories cannot be proven safe to prune" >&2
  exit 2
fi

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skills_dir=$target_dir/.agents/skills
legacy_skills_dir=$target_dir/.codex/skills
plan_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-skill-plan.XXXXXX")
trap 'rm -rf "$plan_dir"' EXIT HUP INT TERM
catalog_file=$plan_dir/catalog.tsv
selected_file=$plan_dir/selected.tsv
desired_file=$plan_dir/desired.tsv
: >"$catalog_file"
: >"$selected_file"
: >"$desired_file"
tab=$(printf '\t')
phase=catalog

lookup_source() {
  lookup_name=$1
  awk -F '\t' -v name="$lookup_name" '$1 == name { print $2; exit }' "$catalog_file"
}

record_skill() {
  record_file=$1
  record_name=$2
  record_src=$3
  existing_src=$(awk -F '\t' -v name="$record_name" '$1 == name { print $2; exit }' "$record_file")
  if [ -n "$existing_src" ]; then
    if [ "$existing_src" != "$record_src" ]; then
      echo "Installed skill name collision: $record_name maps to both $existing_src and $record_src" >&2
      exit 1
    fi
    return 0
  fi
  printf '%s\t%s\n' "$record_name" "$record_src" >>"$record_file"
}

install_skill() {
  src=$1
  dest_name=$2

  if [ ! -f "$src/SKILL.md" ]; then
    echo "missing SKILL.md: $src" >&2
    exit 1
  fi

  if [ "$phase" = "catalog" ]; then
    record_skill "$catalog_file" "$dest_name" "$src"
  else
    record_skill "$selected_file" "$dest_name" "$src"
  fi
}

install_find_skills() {
  root=$1
  prefix=$2
  find "$root" -name SKILL.md -type f | sort | while IFS= read -r skill_file; do
    src=$(dirname "$skill_file")
    leaf=$(basename "$src")
    install_skill "$src" "$prefix$leaf"
  done
}

install_core() {
  install_skill "$repo_root/templates/skills/first-party/github-keychain-auth" "github-keychain-auth"
  install_skill "$repo_root/templates/skills/adapted/planning-files-lite" "planning-files-lite"
  install_skill "$repo_root/templates/skills/imported/agent-skills/context-engineering" "context-engineering"
  install_skill "$repo_root/templates/skills/imported/agent-skills/spec-driven-development" "spec-driven-development"
  install_skill "$repo_root/templates/skills/imported/agent-skills/planning-and-task-breakdown" "planning-and-task-breakdown"
  install_skill "$repo_root/templates/skills/imported/agent-skills/test-driven-development" "test-driven-development"
  install_skill "$repo_root/templates/skills/imported/agent-skills/code-review-and-quality" "code-review-and-quality"
  install_skill "$repo_root/templates/skills/imported/agent-skills/debugging-and-error-recovery" "debugging-and-error-recovery"
  install_skill "$repo_root/templates/skills/imported/agent-skills/source-driven-development" "source-driven-development"
}

install_node() {
  install_skill "$repo_root/templates/skills/first-party/inspect-node-package-api" "inspect-node-package-api"
}

install_orchestration() {
  install_skill "$repo_root/templates/skills/first-party/independent-review" "independent-review"
  install_skill "$repo_root/templates/skills/first-party/orchestrated-delivery" "orchestrated-delivery"
  install_skill "$repo_root/templates/skills/first-party/spec-traceability" "spec-traceability"
  install_skill "$repo_root/templates/skills/first-party/session-handoff" "session-handoff"
  install_skill "$repo_root/templates/skills/first-party/research-to-decision" "research-to-decision"
  install_skill "$repo_root/templates/skills/imported/planning-with-files/planning-with-files" "planning-with-files"
  install_skill "$repo_root/templates/skills/imported/agent-skills/doubt-driven-development" "doubt-driven-development"
}

install_documentation() {
  install_skill "$repo_root/templates/skills/first-party/repository-doc-drift" "repository-doc-drift"
  install_skill "$repo_root/templates/skills/imported/agent-skills/documentation-and-adrs" "documentation-and-adrs"
  install_skill "$repo_root/templates/skills/imported/agent-toolkit/crafting-effective-readmes" "crafting-effective-readmes"
  install_skill "$repo_root/templates/skills/imported/agent-toolkit/mermaid-diagrams" "mermaid-diagrams"
  install_skill "$repo_root/templates/skills/imported/agent-toolkit/c4-architecture" "c4-architecture"
}

install_delivery() {
  install_skill "$repo_root/templates/skills/imported/agent-skills/incremental-implementation" "incremental-implementation"
  install_skill "$repo_root/templates/skills/imported/agent-skills/git-workflow-and-versioning" "git-workflow-and-versioning"
  install_skill "$repo_root/templates/skills/imported/agent-skills/code-simplification" "code-simplification"
  install_skill "$repo_root/templates/skills/imported/agent-skills/ci-cd-and-automation" "ci-cd-and-automation"
  install_skill "$repo_root/templates/skills/imported/agent-skills/shipping-and-launch" "shipping-and-launch"
  install_skill "$repo_root/templates/skills/imported/claude-skills/engineering/skills/self-eval" "self-eval"
  install_skill "$repo_root/templates/skills/imported/claude-skills/engineering/skills/ship-gate" "ship-gate"
}

install_brevity() {
  install_skill "$repo_root/templates/skills/imported/caveman/skills/caveman" "caveman"
  install_skill "$repo_root/templates/skills/imported/caveman/skills/caveman-help" "caveman-help"
  install_skill "$repo_root/templates/skills/imported/caveman/skills/caveman-commit" "caveman-commit"
  install_skill "$repo_root/templates/skills/imported/caveman/skills/caveman-review" "caveman-review"
  install_skill "$repo_root/templates/skills/imported/caveman/skills/caveman-compress" "caveman-compress"
}

install_engineering() {
  install_node
  install_find_skills "$repo_root/templates/skills/imported/agent-skills" ""
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering" "claude-"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team" "claude-"
}

install_dotnet() {
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/run-tests" "dotnet-run-tests"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/platform-detection" "dotnet-test-platform-detection"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/filter-syntax" "dotnet-test-filter-syntax"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/directory-build-organization" "dotnet-directory-build-organization"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/msbuild-antipatterns" "dotnet-msbuild-antipatterns"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/binlog-generation" "dotnet-binlog-generation"
  install_skill "$repo_root/templates/skills/imported/dotnet-skills/binlog-failure-analysis" "dotnet-binlog-failure-analysis"
}

install_jvm() {
  install_skill "$repo_root/templates/skills/adapted/kotlin-jvm-engineering" "kotlin-jvm-engineering"
}

install_rust() {
  install_find_skills "$repo_root/templates/skills/imported/rust-agentic-skills" "rust-"
}

install_product() {
  install_find_skills "$repo_root/templates/skills/imported/pm-skills" "pm-"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/product-team" "claude-"
}

install_planning() {
  install_skill "$repo_root/templates/skills/adapted/planning-files-lite" "planning-files-lite"
  install_skill "$repo_root/templates/skills/imported/planning-with-files/planning-with-files" "planning-with-files"
}

install_frontend() {
  install_skill "$repo_root/templates/skills/adapted/frontend-design-review" "frontend-design-review"
  install_skill "$repo_root/templates/skills/imported/agent-skills/frontend-ui-engineering" "frontend-ui-engineering"
  install_skill "$repo_root/templates/skills/imported/agent-skills/browser-testing-with-devtools" "browser-testing-with-devtools"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team/a11y-audit" "claude-"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team/playwright-pro" "claude-playwright-"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/product-team/skills/ui-design-system" "claude-"
  install_find_skills "$repo_root/templates/skills/imported/web-quality-skills" "web-"
}

install_frontend_tooling() {
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vite" "vite"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vitest" "vitest"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/pnpm" "pnpm"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/turborepo" "turborepo"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vitepress" "vitepress"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/slidev" "slidev"
}

install_hallmark() {
  install_skill "$repo_root/templates/skills/adapted/hallmark-design" "hallmark-design"
}

install_frontend_vue() {
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vue" "vue"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vue-best-practices" "vue-best-practices"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vue-router-best-practices" "vue-router-best-practices"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vue-testing-best-practices" "vue-testing-best-practices"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/nuxt" "nuxt"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/pinia" "pinia"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/vueuse-functions" "vueuse-functions"
  install_skill "$repo_root/templates/skills/imported/antfu-skills/unocss" "unocss"
}

install_infra() {
  install_skill "$repo_root/templates/skills/imported/terraform-skill/terraform-skill" "terraform-skill"
}

install_writing() {
  install_skill "$repo_root/templates/skills/first-party/project-story-miner" "project-story-miner"
  install_skill "$repo_root/templates/skills/first-party/technical-blog-writer" "technical-blog-writer"
  install_skill "$repo_root/templates/skills/adapted/humanizer" "humanizer"
}

install_workflow() {
  install_find_skills "$repo_root/templates/skills/imported/agent-toolkit" "toolkit-"
}

select_bundle() {
  selected_bundle=$1
  case "$selected_bundle" in
    none) ;;
    core) install_core ;;
    node) install_node ;;
    orchestration) install_orchestration ;;
    documentation) install_documentation ;;
    delivery) install_delivery ;;
    brevity) install_brevity ;;
    engineering) install_engineering ;;
    dotnet) install_dotnet ;;
    jvm) install_jvm ;;
    rust) install_rust ;;
    product) install_product ;;
    planning) install_planning ;;
    frontend) install_frontend ;;
    frontend-tooling) install_frontend_tooling ;;
    frontend-vue) install_frontend_vue ;;
    hallmark) install_hallmark ;;
    infra) install_infra ;;
    writing) install_writing ;;
    workflow) install_workflow ;;
    all)
      install_core
      install_node
      install_orchestration
      install_documentation
      install_delivery
      install_brevity
      install_engineering
      install_dotnet
      install_jvm
      install_rust
      install_product
      install_planning
      install_frontend
      install_frontend_tooling
      install_frontend_vue
      install_hallmark
      install_infra
      install_writing
      install_workflow
      ;;
    *)
      echo "Unknown bundle: $selected_bundle" >&2
      usage
      exit 2
      ;;
  esac
}

csv_contains() {
  csv_list=$1
  csv_item=$2
  case ",$csv_list," in
    *,"$csv_item",*) return 0 ;;
    *) return 1 ;;
  esac
}

validate_skill_csv() {
  skill_csv=$1
  option_name=$2
  old_ifs=$IFS
  IFS=,
  for skill_name in $skill_csv; do
    [ -n "$skill_name" ] || continue
    if [ -z "$(lookup_source "$skill_name")" ]; then
      echo "Unknown skill for $option_name: $skill_name" >&2
      exit 2
    fi
  done
  IFS=$old_ifs
}

# Exact selectors and sync need the authoritative installed-name-to-source
# catalog. Ordinary additive bundle installs retain the smaller legacy scan.
if [ -n "$skills" ] || [ -n "$skip_skills" ] || [ "$sync" -eq 1 ]; then
  phase=catalog
  select_bundle all
  validate_skill_csv "$skills" "--skills"
  validate_skill_csv "$skip_skills" "--skip-skills"
fi

if csv_contains "$bundles" "none" && [ "$bundles" != "none" ]; then
  echo "Bundle 'none' cannot be combined with other bundles" >&2
  exit 2
fi

phase=select
old_ifs=$IFS
IFS=,
for selected_bundle in $bundles; do
  [ -n "$selected_bundle" ] || continue
  select_bundle "$selected_bundle"
done
for skill_name in $skills; do
  [ -n "$skill_name" ] || continue
  install_skill "$(lookup_source "$skill_name")" "$skill_name"
done
IFS=$old_ifs

while IFS="$tab" read -r skill_name skill_src; do
  [ -n "$skill_name" ] || continue
  if ! csv_contains "$skip_skills" "$skill_name"; then
    record_skill "$desired_file" "$skill_name" "$skill_src"
  fi
done <"$selected_file"

if [ "$dry_run" -eq 0 ]; then
  mkdir -p "$skills_dir" "$legacy_skills_dir"
fi

install_legacy_link() {
  dest_name=$1
  legacy_dest=$legacy_skills_dir/$dest_name
  compatibility_target=../../.agents/skills/$dest_name

  if [ -e "$legacy_dest" ] || [ -L "$legacy_dest" ]; then
    echo "skip existing $legacy_dest"
  elif [ "$dry_run" -eq 1 ]; then
    echo "would link compatibility path $legacy_dest -> $compatibility_target"
  else
    ln -s "$compatibility_target" "$legacy_dest"
    echo "linked compatibility path $legacy_dest -> $compatibility_target"
  fi
}

apply_skill() {
  dest_name=$1
  src=$2
  dest=$skills_dir/$dest_name
  legacy_dest=$legacy_skills_dir/$dest_name

  if [ ! -e "$dest" ] && [ ! -L "$dest" ] && { [ -e "$legacy_dest" ] || [ -L "$legacy_dest" ]; }; then
    if [ "$dry_run" -eq 1 ]; then
      echo "would adopt legacy skill $legacy_dest at canonical path $dest"
    else
      ln -s "../../.codex/skills/$dest_name" "$dest"
      echo "adopted legacy skill $legacy_dest at canonical path $dest"
    fi
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing $dest"
  elif [ "$mode" = "link" ]; then
    if [ "$dry_run" -eq 1 ]; then
      echo "would link $dest -> $src"
    else
      ln -s "$src" "$dest"
      echo "linked $dest -> $src"
    fi
  elif [ "$dry_run" -eq 1 ]; then
    echo "would create $dest"
  else
    cp -R "$src" "$dest"
    echo "created $dest"
  fi

  install_legacy_link "$dest_name"
}

while IFS="$tab" read -r skill_name skill_src; do
  [ -n "$skill_name" ] || continue
  apply_skill "$skill_name" "$skill_src"
done <"$desired_file"

is_desired_skill() {
  desired_name=$1
  awk -F '\t' -v name="$desired_name" '$1 == name { found = 1 } END { exit !found }' "$desired_file"
}

remove_managed_link() {
  managed_path=$1
  if [ "$dry_run" -eq 1 ]; then
    echo "would remove managed link $managed_path"
  else
    rm "$managed_path"
    echo "removed managed link $managed_path"
  fi
}

if [ "$sync" -eq 1 ] && [ -d "$skills_dir" ]; then
  for canonical_dest in "$skills_dir"/*; do
    [ -L "$canonical_dest" ] || continue
    dest_name=$(basename "$canonical_dest")
    if is_desired_skill "$dest_name"; then
      continue
    fi

    known_src=$(lookup_source "$dest_name")
    [ -n "$known_src" ] || continue
    [ "$(readlink "$canonical_dest")" = "$known_src" ] || continue

    legacy_dest=$legacy_skills_dir/$dest_name
    if [ -L "$legacy_dest" ] && [ "$(readlink "$legacy_dest")" = "../../.agents/skills/$dest_name" ]; then
      remove_managed_link "$legacy_dest"
    fi
    remove_managed_link "$canonical_dest"
  done
fi
