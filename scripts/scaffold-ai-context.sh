#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TARGET_DIR [--profile base|angular|payload|frontend-design] [--mode copy|link]" >&2
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift

profile=base
mode=copy
while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      profile=$2
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

case "$profile" in
  base|angular|payload|frontend-design) ;;
  *)
    echo "Unknown profile: $profile" >&2
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

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

mkdir -p "$target_dir/.codex/steering"

copy_if_missing() {
  src=$1
  dest=$2
  if [ -e "$dest" ]; then
    echo "skip existing $dest"
  else
    cp "$src" "$dest"
    echo "created $dest"
  fi
}

install_reusable_if_missing() {
  src=$1
  dest=$2
  if [ -e "$dest" ]; then
    echo "skip existing $dest"
  elif [ "$mode" = "link" ]; then
    ln -s "$src" "$dest"
    echo "linked $dest -> $src"
  else
    cp "$src" "$dest"
    echo "created $dest"
  fi
}

copy_if_missing "$repo_root/templates/agents/AGENTS.md" "$target_dir/AGENTS.md"
copy_if_missing "$repo_root/templates/steering/repository-steering.md" "$target_dir/.codex/steering/repository-steering.md"
install_reusable_if_missing "$repo_root/templates/steering/javascript-esm-steering.md" "$target_dir/.codex/steering/javascript-esm-steering.md"
copy_if_missing "$repo_root/templates/steering/testing-quality-gates-steering.md" "$target_dir/.codex/steering/testing-quality-gates-steering.md"

if [ "$profile" = "angular" ]; then
  install_reusable_if_missing "$repo_root/templates/steering/angular-steering.md" "$target_dir/.codex/steering/angular-steering.md"
fi

if [ "$profile" = "frontend-design" ]; then
  install_reusable_if_missing "$repo_root/templates/steering/frontend-design-steering.md" "$target_dir/.codex/steering/frontend-design-steering.md"
fi

if [ "$profile" = "payload" ]; then
  mkdir -p "$target_dir/.cursor/rules"
  install_reusable_if_missing "$repo_root/templates/cursor-rules/payload-overview.md" "$target_dir/.cursor/rules/payload-overview.md"
fi
