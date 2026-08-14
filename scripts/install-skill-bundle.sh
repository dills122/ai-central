#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TARGET_DIR [--bundle core|orchestration|documentation|delivery|brevity|engineering|jvm|rust|product|planning|frontend|frontend-tooling|frontend-vue|hallmark|infra|writing|workflow|all] [--mode copy|link]" >&2
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift

bundle=core
mode=copy
while [ "$#" -gt 0 ]; do
  case "$1" in
    --bundle)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      bundle=$2
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
    *)
      usage
      exit 2
      ;;
  esac
done

case "$bundle" in
  core|orchestration|documentation|delivery|brevity|engineering|jvm|rust|product|planning|frontend|frontend-tooling|frontend-vue|hallmark|infra|writing|workflow|all) ;;
  *)
    echo "Unknown bundle: $bundle" >&2
    usage
    exit 2
    ;;
esac

case "$mode" in
  copy|link) ;;
  *)
    echo "Unknown mode: $mode" >&2
    usage
    exit 2
    ;;
esac

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skills_dir=$target_dir/.agents/skills
legacy_skills_dir=$target_dir/.codex/skills
mkdir -p "$skills_dir"
mkdir -p "$legacy_skills_dir"

install_legacy_link() {
  dest_name=$1
  legacy_dest=$legacy_skills_dir/$dest_name

  if [ -e "$legacy_dest" ] || [ -L "$legacy_dest" ]; then
    return 0
  fi

  ln -s "../../.agents/skills/$dest_name" "$legacy_dest"
  echo "linked compatibility path $legacy_dest -> ../../.agents/skills/$dest_name"
}

install_skill() {
  src=$1
  dest_name=$2
  dest=$skills_dir/$dest_name
  legacy_dest=$legacy_skills_dir/$dest_name

  if [ ! -f "$src/SKILL.md" ]; then
    echo "missing SKILL.md: $src" >&2
    exit 1
  fi

  if [ ! -e "$dest" ] && [ ! -L "$dest" ] && [ -e "$legacy_dest" ]; then
    ln -s "../../.codex/skills/$dest_name" "$dest"
    echo "adopted legacy skill $legacy_dest at canonical path $dest"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing $dest"
  elif [ "$mode" = "link" ]; then
    ln -s "$src" "$dest"
    echo "linked $dest -> $src"
  else
    cp -R "$src" "$dest"
    echo "created $dest"
  fi

  install_legacy_link "$dest_name"
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
  install_find_skills "$repo_root/templates/skills/imported/agent-skills" ""
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering" "claude-"
  install_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team" "claude-"
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

case "$bundle" in
  core)
    install_core
    ;;
  orchestration)
    install_orchestration
    ;;
  documentation)
    install_documentation
    ;;
  delivery)
    install_delivery
    ;;
  brevity)
    install_brevity
    ;;
  engineering)
    install_engineering
    ;;
  jvm)
    install_jvm
    ;;
  rust)
    install_rust
    ;;
  product)
    install_product
    ;;
  planning)
    install_planning
    ;;
  frontend)
    install_frontend
    ;;
  frontend-tooling)
    install_frontend_tooling
    ;;
  frontend-vue)
    install_frontend_vue
    ;;
  hallmark)
    install_hallmark
    ;;
  infra)
    install_infra
    ;;
  writing)
    install_writing
    ;;
  workflow)
    install_workflow
    ;;
  all)
    install_core
    install_orchestration
    install_documentation
    install_delivery
    install_brevity
    install_engineering
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
esac
