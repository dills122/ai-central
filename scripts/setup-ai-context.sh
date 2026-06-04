#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: setup-ai-context.sh TARGET_DIR [options]

Options:
  --yes                    Use detected recommendations without prompts
  --profiles LIST          Comma-separated steering profiles: base,angular,payload,frontend-design
  --bundles LIST           Comma-separated skill bundles: core,engineering,rust,product,planning,frontend,all
  --skip-profiles LIST     Comma-separated profiles to exclude
  --skip-bundles LIST      Comma-separated bundles to exclude
  --dry-run                Show what would run without writing files
  --help                   Show this help

Examples:
  ./scripts/setup-ai-context.sh /path/to/project
  ./scripts/setup-ai-context.sh /path/to/project --yes
  ./scripts/setup-ai-context.sh /path/to/project --profiles base,angular --bundles core,frontend
EOF
}

contains_item() {
  list=$1
  item=$2
  case ",$list," in
    *,"$item",*) return 0 ;;
    *) return 1 ;;
  esac
}

append_unique() {
  list=$1
  item=$2
  if [ -z "$item" ]; then
    printf "%s" "$list"
  elif [ -z "$list" ]; then
    printf "%s" "$item"
  elif contains_item "$list" "$item"; then
    printf "%s" "$list"
  else
    printf "%s,%s" "$list" "$item"
  fi
}

remove_items() {
  list=$1
  skips=$2
  result=
  old_ifs=$IFS
  IFS=,
  for item in $list; do
    if [ -n "$item" ] && ! contains_item "$skips" "$item"; then
      result=$(append_unique "$result" "$item")
    fi
  done
  IFS=$old_ifs
  printf "%s" "$result"
}

validate_csv() {
  list=$1
  allowed=$2
  kind=$3
  old_ifs=$IFS
  IFS=,
  for item in $list; do
    if [ -n "$item" ] && ! contains_item "$allowed" "$item"; then
      echo "Unknown $kind: $item" >&2
      exit 2
    fi
  done
  IFS=$old_ifs
}

prompt_default_yes() {
  question=$1
  if [ ! -t 0 ]; then
    return 0
  fi
  printf "%s [Y/n] " "$question"
  read answer || answer=
  case "$answer" in
    n|N|no|NO|No) return 1 ;;
    *) return 0 ;;
  esac
}

prompt_csv() {
  label=$1
  current=$2
  allowed=$3
  if [ ! -t 0 ]; then
    printf "%s" "$current"
    return 0
  fi
  printf "%s\n" "$label" >&2
  printf "Allowed: %s\n" "$allowed" >&2
  printf "Default: %s\n" "${current:-none}" >&2
  printf "Enter comma-separated list, blank for default, or 'none': " >&2
  read answer || answer=
  case "$answer" in
    "") printf "%s" "$current" ;;
    none|NONE|None) printf "" ;;
    *)
      validate_csv "$answer" "$allowed" "$label"
      printf "%s" "$answer"
      ;;
  esac
}

detect_profiles() {
  target_dir=$1
  profiles=base

  if [ -f "$target_dir/angular.json" ] || find "$target_dir" -maxdepth 3 -name angular.json -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "angular")
    profiles=$(append_unique "$profiles" "frontend-design")
  fi

  if find "$target_dir" -maxdepth 4 \( -name payload.config.ts -o -name payload.config.js -o -path '*/payload.config.ts' -o -path '*/payload.config.js' \) -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "payload")
  fi

  if find "$target_dir" -maxdepth 4 \( -name '*.tsx' -o -name '*.jsx' -o -name '*.component.ts' \) -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "frontend-design")
  fi

  printf "%s" "$profiles"
}

detect_bundles() {
  target_dir=$1
  bundles=core

  if [ -f "$target_dir/Cargo.toml" ] || find "$target_dir" -maxdepth 4 -name Cargo.toml -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "rust")
  fi

  if [ -f "$target_dir/package.json" ] || find "$target_dir" -maxdepth 3 -name package.json -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "engineering")
  fi

  if [ -f "$target_dir/angular.json" ] || find "$target_dir" -maxdepth 3 -name angular.json -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend")
  fi

  if find "$target_dir" -maxdepth 4 \( -name '*.tsx' -o -name '*.jsx' -o -name '*.component.ts' \) -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend")
  fi

  if [ -d "$target_dir/docs" ] || [ -d "$target_dir/product" ]; then
    bundles=$(append_unique "$bundles" "product")
  fi

  printf "%s" "$bundles"
}

target_dir=
yes=0
dry_run=0
profiles_arg=
bundles_arg=
skip_profiles=
skip_bundles=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --yes|-y)
      yes=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --profiles)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      profiles_arg=$2
      shift 2
      ;;
    --bundles)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      bundles_arg=$2
      shift 2
      ;;
    --skip-profiles)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skip_profiles=$2
      shift 2
      ;;
    --skip-bundles)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skip_bundles=$2
      shift 2
      ;;
    -*)
      usage
      exit 2
      ;;
    *)
      if [ -n "$target_dir" ]; then
        usage
        exit 2
      fi
      target_dir=$1
      shift
      ;;
  esac
done

if [ -z "$target_dir" ]; then
  usage
  exit 2
fi

if [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 1
fi

allowed_profiles=base,angular,payload,frontend-design
allowed_bundles=core,engineering,rust,product,planning,frontend,all

validate_csv "$profiles_arg" "$allowed_profiles" "profile"
validate_csv "$bundles_arg" "$allowed_bundles" "bundle"
validate_csv "$skip_profiles" "$allowed_profiles" "profile"
validate_csv "$skip_bundles" "$allowed_bundles" "bundle"

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

detected_profiles=$(detect_profiles "$target_dir")
detected_bundles=$(detect_bundles "$target_dir")

profiles=${profiles_arg:-$detected_profiles}
bundles=${bundles_arg:-$detected_bundles}
profiles=$(remove_items "$profiles" "$skip_profiles")
bundles=$(remove_items "$bundles" "$skip_bundles")

echo "Target: $target_dir"
echo "Detected profiles: ${detected_profiles:-none}"
echo "Detected bundles: ${detected_bundles:-none}"

if [ "$yes" -ne 1 ]; then
  if prompt_default_yes "Customize selections?"; then
    profiles=$(prompt_csv "Profiles to install" "$profiles" "$allowed_profiles")
    bundles=$(prompt_csv "Skill bundles to install" "$bundles" "$allowed_bundles")
  fi
fi

profiles=$(remove_items "$profiles" "$skip_profiles")
bundles=$(remove_items "$bundles" "$skip_bundles")

echo "Selected profiles: ${profiles:-none}"
echo "Selected bundles: ${bundles:-none}"

run_cmd() {
  if [ "$dry_run" -eq 1 ]; then
    printf "dry-run:"
    for arg in "$@"; do
      printf " %s" "$arg"
    done
    printf "\n"
  else
    "$@"
  fi
}

old_ifs=$IFS
IFS=,
for profile in $profiles; do
  [ -n "$profile" ] || continue
  run_cmd "$repo_root/scripts/scaffold-ai-context.sh" "$target_dir" --profile "$profile"
done

for bundle in $bundles; do
  [ -n "$bundle" ] || continue
  run_cmd "$repo_root/scripts/install-skill-bundle.sh" "$target_dir" --bundle "$bundle"
done
IFS=$old_ifs

echo "Setup complete"
