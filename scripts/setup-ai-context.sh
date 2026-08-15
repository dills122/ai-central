#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: setup-ai-context.sh TARGET_DIR [options]

Options:
  --yes                    Use detected recommendations without prompts
  --profiles LIST          Comma-separated steering profiles: base,javascript-typescript,angular,dotnet-csharp,dotnet-aspnetcore,dotnet-efcore,dotnet-orleans,dotnet-aspire,dotnet-opentelemetry,dotnet-grpc,kotlin-jvm,rust,shell-scripting,payload,frontend-design,infrastructure-opentofu
  --bundles LIST           Comma-separated skill bundles: core,node,orchestration,documentation,delivery,brevity,engineering,dotnet,jvm,rust,product,planning,frontend,frontend-tooling,frontend-vue,hallmark,infra,writing,workflow,all,none
  --skills LIST            Comma-separated installed skill names to add after bundle expansion
  --skip-skills LIST       Comma-separated installed skill names to exclude after bundle expansion
  --mode copy|link          copy installs files; link symlinks reusable templates and skills
  --sync                    In link mode, prune deselected AI Central-managed skill links
  --skip-profiles LIST     Comma-separated profiles to exclude
  --skip-bundles LIST      Comma-separated bundles to exclude
  --dry-run                Show exact creates, links, skips, and removals without writing
  --help                   Show this help

Examples:
  ./scripts/setup-ai-context.sh /path/to/project
  ./scripts/setup-ai-context.sh /path/to/project --yes
  ./scripts/setup-ai-context.sh /path/to/project --yes --mode link
  ./scripts/setup-ai-context.sh /path/to/project --profiles base,angular --bundles core,frontend,hallmark
  ./scripts/setup-ai-context.sh /path/to/project --bundles core,frontend-tooling --skip-skills vite,vitest,turborepo,vitepress,slidev --mode link --sync --yes
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

prompt_mode() {
  current=$1
  if [ ! -t 0 ]; then
    printf "%s" "$current"
    return 0
  fi
  printf "Install mode\n" >&2
  printf "Allowed: copy,link\n" >&2
  printf "Default: %s\n" "$current" >&2
  printf "Enter install mode, blank for default: " >&2
  read answer || answer=
  case "$answer" in
    "") printf "%s" "$current" ;;
    copy|link) printf "%s" "$answer" ;;
    *)
      echo "Unknown mode: $answer" >&2
      exit 2
      ;;
  esac
}

detect_profiles() {
  target_dir=$1
  profiles=base
  dotnet_detected=0

  if [ -f "$target_dir/package.json" ]; then
    profiles=$(append_unique "$profiles" "javascript-typescript")
  fi

  if [ -f "$target_dir/angular.json" ]; then
    profiles=$(append_unique "$profiles" "javascript-typescript")
    profiles=$(append_unique "$profiles" "angular")
    profiles=$(append_unique "$profiles" "frontend-design")
  fi

  if find "$target_dir" -maxdepth 6 \
    \( -name '*.cs' -o -name '*.csproj' -o -name '*.sln' -o -name '*.slnx' -o \
       -name global.json -o -name Directory.Build.props -o -name Directory.Build.targets -o \
       -name Directory.Packages.props \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' ! -path '*/packages/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' |
    grep -q .; then
    dotnet_detected=1
    profiles=$(append_unique "$profiles" "dotnet-csharp")
  fi

  if [ "$dotnet_detected" -eq 1 ] && find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'Microsoft\.NET\.Sdk\.Web|Microsoft\.AspNetCore\.App' {} + | grep -q .; then
    profiles=$(append_unique "$profiles" "dotnet-aspnetcore")
  fi

  if [ "$dotnet_detected" -eq 1 ] && find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'Microsoft\.EntityFrameworkCore' {} + | grep -q .; then
    profiles=$(append_unique "$profiles" "dotnet-efcore")
  fi

  if [ "$dotnet_detected" -eq 1 ] && find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'Microsoft\.Orleans|Aspire\.Hosting\.Orleans' {} + | grep -q .; then
    profiles=$(append_unique "$profiles" "dotnet-orleans")
  fi

  if [ "$dotnet_detected" -eq 1 ] && find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'Aspire\.Hosting|Aspire\.AppHost\.Sdk|<IsAspireHost>' {} + | grep -q .; then
    profiles=$(append_unique "$profiles" "dotnet-aspire")
  fi

  if [ "$dotnet_detected" -eq 1 ] && find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'OpenTelemetry' {} + | grep -q .; then
    profiles=$(append_unique "$profiles" "dotnet-opentelemetry")
  fi

  if [ "$dotnet_detected" -eq 1 ] && { find "$target_dir" -maxdepth 6 -name '*.proto' \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' | grep -q . || find "$target_dir" -maxdepth 6 \
    \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' \
    -exec grep -Eil 'Grpc\.AspNetCore|Grpc\.Net\.Client|Grpc\.Tools|Google\.Protobuf|<Protobuf' {} + |
    grep -q .; }; then
    profiles=$(append_unique "$profiles" "dotnet-grpc")
  fi

  if find "$target_dir" -maxdepth 5 \( -name '*.kt' -o -name build.gradle.kts -o -name settings.gradle.kts \) -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "kotlin-jvm")
  fi

  if [ -f "$target_dir/Cargo.toml" ] || find "$target_dir" -maxdepth 4 -name Cargo.toml -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "rust")
  fi

  if find "$target_dir" -maxdepth 4 \( -name payload.config.ts -o -name payload.config.js -o -path '*/payload.config.ts' -o -path '*/payload.config.js' \) -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "javascript-typescript")
    profiles=$(append_unique "$profiles" "payload")
  fi

  if [ -f "$target_dir/package.json" ] && find "$target_dir" -maxdepth 4 \( -name '*.tsx' -o -name '*.jsx' -o -name '*.astro' -o -name '*.component.ts' \) -type f ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/build/*' | grep -q .; then
    profiles=$(append_unique "$profiles" "javascript-typescript")
    profiles=$(append_unique "$profiles" "frontend-design")
  fi

  if find "$target_dir" -maxdepth 5 \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tofu' -o -name '*.tofuvars' \) -type f | grep -q .; then
    profiles=$(append_unique "$profiles" "infrastructure-opentofu")
  fi

  printf "%s" "$profiles"
}

detect_bundles() {
  target_dir=$1
  bundles=core

  if [ -f "$target_dir/package.json" ]; then
    bundles=$(append_unique "$bundles" "node")
  fi

  if find "$target_dir" -maxdepth 6 \
    \( -name '*.cs' -o -name '*.csproj' -o -name '*.sln' -o -name '*.slnx' -o \
       -name global.json -o -name Directory.Build.props -o -name Directory.Build.targets -o \
       -name Directory.Packages.props \) \
    -type f ! -path '*/.git/*' ! -path '*/bin/*' ! -path '*/obj/*' ! -path '*/packages/*' \
    ! -path '*/node_modules/*' ! -path '*/vendor/*' |
    grep -q .; then
    bundles=$(append_unique "$bundles" "dotnet")
  fi

  if find "$target_dir" -maxdepth 5 \( -name '*.kt' -o -name build.gradle.kts -o -name settings.gradle.kts \) -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "jvm")
  fi

  if [ -f "$target_dir/Cargo.toml" ] || find "$target_dir" -maxdepth 4 -name Cargo.toml -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "rust")
  fi

  if [ -f "$target_dir/angular.json" ]; then
    bundles=$(append_unique "$bundles" "frontend")
  fi

  if [ -f "$target_dir/package.json" ] && find "$target_dir" -maxdepth 4 \( -name '*.tsx' -o -name '*.jsx' -o -name '*.astro' -o -name '*.component.ts' \) -type f ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/build/*' | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend")
  fi

  if [ -f "$target_dir/package.json" ] && find "$target_dir" -maxdepth 5 \( -name '*.vue' -o -name nuxt.config.ts -o -name nuxt.config.js -o -name vite.config.ts -o -name vite.config.js \) -type f ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/build/*' | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend")
  fi

  if [ -f "$target_dir/package.json" ] && find "$target_dir" -maxdepth 5 \( -name '*.vue' -o -name nuxt.config.ts -o -name nuxt.config.js \) -type f ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/build/*' | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend-vue")
  elif [ -f "$target_dir/package.json" ] && grep -E '"(vue|nuxt|pinia|@vueuse/core)"[[:space:]]*:' "$target_dir/package.json" | grep -q .; then
    bundles=$(append_unique "$bundles" "frontend-vue")
  fi

  if find "$target_dir" -maxdepth 5 \( -name '*.tf' -o -name '*.tfvars' -o -name '*.tofu' -o -name '*.tofuvars' \) -type f | grep -q .; then
    bundles=$(append_unique "$bundles" "infra")
  fi

  printf "%s" "$bundles"
}

target_dir=
yes=0
dry_run=0
mode=copy
profiles_arg=
bundles_arg=
skip_profiles=
skip_bundles=
skills=
skip_skills=
sync=0

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
    --skills)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skills=$2
      shift 2
      ;;
    --skip-skills)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skip_skills=$2
      shift 2
      ;;
    --mode)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      mode=$2
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
    --sync)
      sync=1
      shift
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

allowed_profiles=base,javascript-typescript,angular,dotnet-csharp,dotnet-aspnetcore,dotnet-efcore,dotnet-orleans,dotnet-aspire,dotnet-opentelemetry,dotnet-grpc,kotlin-jvm,rust,shell-scripting,payload,frontend-design,infrastructure-opentofu
allowed_bundles=core,node,orchestration,documentation,delivery,brevity,engineering,dotnet,jvm,rust,product,planning,frontend,frontend-tooling,frontend-vue,hallmark,infra,writing,workflow,all,none

case "$mode" in
  copy|link) ;;
  *)
    echo "Unknown mode: $mode" >&2
    usage
    exit 2
    ;;
esac

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
    mode=$(prompt_mode "$mode")
  fi
fi

profiles=$(remove_items "$profiles" "$skip_profiles")
bundles=$(remove_items "$bundles" "$skip_bundles")

echo "Selected profiles: ${profiles:-none}"
echo "Selected bundles: ${bundles:-none}"
echo "Additional skills: ${skills:-none}"
echo "Excluded skills: ${skip_skills:-none}"
echo "Install mode: $mode"
echo "Sync managed links: $([ "$sync" -eq 1 ] && echo yes || echo no)"

if [ "$sync" -eq 1 ] && [ "$mode" != "link" ]; then
  echo "--sync requires --mode link because copied or project-owned directories cannot be proven safe to prune" >&2
  exit 2
fi

if contains_item "$bundles" "none" && [ "$bundles" != "none" ]; then
  echo "Bundle 'none' cannot be combined with other bundles" >&2
  exit 2
fi

# Validate exact selectors before any profile files are installed.
if [ -n "$skills" ] || [ -n "$skip_skills" ]; then
  set -- "$target_dir" --bundle "${bundles:-none}" --mode "$mode" --dry-run
  if [ -n "$skills" ]; then
    set -- "$@" --skills "$skills"
  fi
  if [ -n "$skip_skills" ]; then
    set -- "$@" --skip-skills "$skip_skills"
  fi
  "$repo_root/scripts/install-skill-bundle.sh" "$@" >/dev/null
fi

if [ -n "$profiles" ]; then
  if [ "$dry_run" -eq 1 ]; then
    "$repo_root/scripts/scaffold-ai-context.sh" "$target_dir" --profile "$profiles" --mode "$mode" --dry-run
  else
    "$repo_root/scripts/scaffold-ai-context.sh" "$target_dir" --profile "$profiles" --mode "$mode"
  fi
fi

set -- "$target_dir" --bundle "${bundles:-none}" --mode "$mode"
if [ -n "$skills" ]; then
  set -- "$@" --skills "$skills"
fi
if [ -n "$skip_skills" ]; then
  set -- "$@" --skip-skills "$skip_skills"
fi
if [ "$sync" -eq 1 ]; then
  set -- "$@" --sync
fi
if [ "$dry_run" -eq 1 ]; then
  set -- "$@" --dry-run
fi
"$repo_root/scripts/install-skill-bundle.sh" "$@"

echo "Setup complete"
