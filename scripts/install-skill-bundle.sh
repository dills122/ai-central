#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TARGET_DIR [--bundle core|engineering|rust|product|planning|frontend|all]" >&2
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift

bundle=core
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
    *)
      usage
      exit 2
      ;;
  esac
done

case "$bundle" in
  core|engineering|rust|product|planning|frontend|all) ;;
  *)
    echo "Unknown bundle: $bundle" >&2
    usage
    exit 2
    ;;
esac

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skills_dir=$target_dir/.codex/skills
mkdir -p "$skills_dir"

copy_skill() {
  src=$1
  dest_name=$2
  dest=$skills_dir/$dest_name

  if [ ! -f "$src/SKILL.md" ]; then
    echo "missing SKILL.md: $src" >&2
    exit 1
  fi

  if [ -e "$dest" ]; then
    echo "skip existing $dest"
  else
    cp -R "$src" "$dest"
    echo "created $dest"
  fi
}

copy_find_skills() {
  root=$1
  prefix=$2
  find "$root" -name SKILL.md -type f | sort | while IFS= read -r skill_file; do
    src=$(dirname "$skill_file")
    leaf=$(basename "$src")
    copy_skill "$src" "$prefix$leaf"
  done
}

install_core() {
  copy_skill "$repo_root/templates/skills/adapted/planning-files-lite" "planning-files-lite"
  copy_skill "$repo_root/templates/skills/adapted/frontend-design-review" "frontend-design-review"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/context-engineering" "context-engineering"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/spec-driven-development" "spec-driven-development"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/planning-and-task-breakdown" "planning-and-task-breakdown"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/test-driven-development" "test-driven-development"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/code-review-and-quality" "code-review-and-quality"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/debugging-and-error-recovery" "debugging-and-error-recovery"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/source-driven-development" "source-driven-development"
}

install_engineering() {
  copy_find_skills "$repo_root/templates/skills/imported/agent-skills" ""
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering" "claude-"
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team" "claude-"
}

install_rust() {
  copy_find_skills "$repo_root/templates/skills/imported/rust-agentic-skills" "rust-"
}

install_product() {
  copy_find_skills "$repo_root/templates/skills/imported/pm-skills" "pm-"
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/product-team" "claude-"
}

install_planning() {
  copy_skill "$repo_root/templates/skills/adapted/planning-files-lite" "planning-files-lite"
  copy_skill "$repo_root/templates/skills/imported/planning-with-files/planning-with-files" "planning-with-files"
}

install_frontend() {
  copy_skill "$repo_root/templates/skills/adapted/frontend-design-review" "frontend-design-review"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/frontend-ui-engineering" "frontend-ui-engineering"
  copy_skill "$repo_root/templates/skills/imported/agent-skills/browser-testing-with-devtools" "browser-testing-with-devtools"
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team/a11y-audit" "claude-"
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/engineering-team/playwright-pro" "claude-playwright-"
  copy_find_skills "$repo_root/templates/skills/imported/claude-skills/product-team/skills/ui-design-system" "claude-"
}

case "$bundle" in
  core)
    install_core
    ;;
  engineering)
    install_engineering
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
  all)
    install_core
    install_engineering
    install_rust
    install_product
    install_planning
    install_frontend
    ;;
esac
