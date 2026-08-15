#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TARGET_DIR [--profile LIST] [--mode copy|link] [--dry-run]" >&2
}

if [ "$#" -lt 1 ]; then
  usage
  exit 2
fi

target_dir=$1
shift

profile=base
mode=copy
dry_run=0
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

old_ifs=$IFS
IFS=,
for selected_profile in $profile; do
  case "$selected_profile" in
    base|javascript-typescript|angular|kotlin-jvm|rust|shell-scripting|payload|frontend-design|infrastructure-opentofu) ;;
    *)
      echo "Unknown profile: $selected_profile" >&2
      usage
      exit 2
      ;;
  esac
done
IFS=$old_ifs

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

if [ "$dry_run" -eq 0 ]; then
  mkdir -p "$target_dir/.codex/steering"
fi

copy_if_missing() {
  src=$1
  dest=$2
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing $dest"
  elif [ "$dry_run" -eq 1 ]; then
    echo "would create $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "created $dest"
  fi
}

install_reusable_if_missing() {
  src=$1
  dest=$2
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing $dest"
  elif [ "$mode" = "link" ]; then
    if [ "$dry_run" -eq 1 ]; then
      echo "would link $dest -> $src"
    else
      mkdir -p "$(dirname "$dest")"
      ln -s "$src" "$dest"
      echo "linked $dest -> $src"
    fi
  elif [ "$dry_run" -eq 1 ]; then
    echo "would create $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "created $dest"
  fi
}

profile_selected() {
  wanted_profile=$1
  case ",$profile," in
    *,"$wanted_profile",*) return 0 ;;
    *) return 1 ;;
  esac
}

copy_if_missing "$repo_root/templates/agents/AGENTS.md" "$target_dir/AGENTS.md"
copy_if_missing "$repo_root/templates/steering/repository-steering.md" "$target_dir/.codex/steering/repository-steering.md"
copy_if_missing "$repo_root/templates/steering/testing-quality-gates-steering.md" "$target_dir/.codex/steering/testing-quality-gates-steering.md"

if profile_selected javascript-typescript || profile_selected angular || profile_selected frontend-design || profile_selected payload; then
  install_reusable_if_missing "$repo_root/templates/steering/javascript-typescript-steering.md" "$target_dir/.codex/steering/javascript-typescript-steering.md"
fi

if profile_selected angular; then
  install_reusable_if_missing "$repo_root/templates/steering/angular-steering.md" "$target_dir/.codex/steering/angular-steering.md"
fi

if profile_selected kotlin-jvm; then
  install_reusable_if_missing "$repo_root/templates/steering/kotlin-jvm-steering.md" "$target_dir/.codex/steering/kotlin-jvm-steering.md"
fi

if profile_selected rust; then
  install_reusable_if_missing "$repo_root/templates/steering/rust-steering.md" "$target_dir/.codex/steering/rust-steering.md"
fi

if profile_selected shell-scripting; then
  install_reusable_if_missing "$repo_root/templates/steering/shell-scripting-steering.md" "$target_dir/.codex/steering/shell-scripting-steering.md"
fi

if profile_selected frontend-design; then
  install_reusable_if_missing "$repo_root/templates/steering/frontend-design-steering.md" "$target_dir/.codex/steering/frontend-design-steering.md"
fi

if profile_selected payload; then
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$target_dir/.cursor/rules"
  fi
  install_reusable_if_missing "$repo_root/templates/cursor-rules/payload-overview.md" "$target_dir/.cursor/rules/payload-overview.md"
fi

if profile_selected infrastructure-opentofu; then
  copy_if_missing "$repo_root/templates/steering/infrastructure-opentofu-steering.md" "$target_dir/.codex/steering/infrastructure-opentofu-steering.md"
fi
