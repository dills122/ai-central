#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: generate-apm-selection.sh [options]

Options:
  --bundle LIST       Comma-separated bundles; repeatable. Defaults to core.
                      Use none with --skills to select no bundle.
  --skills LIST       Comma-separated installed skill names to add.
  --skip-skills LIST  Comma-separated installed skill names to exclude.
  --name NAME         Project manifest name. Defaults to ai-central-selection.
  --version VERSION   Project manifest version. Defaults to 0.1.0.
  --targets LIST      Comma-separated stable APM targets. Defaults to agent-skills.
  --ref REF           AI Central Git ref. Defaults to the release tag when this
                      checkout is tagged, otherwise its full commit SHA.
  --output FILE       Create FILE instead of printing the manifest to stdout.
                      Existing files and symlinks are never overwritten.
  --help              Show this help.

The generated apm.yml declares the exact resolved skill sources directly. Run
`apm install`, commit apm.yml and apm.lock.yaml, and use `apm prune --dry-run`
before pruning dependencies removed from a later generated manifest.
EOF
}

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

validate_identifier() {
  value=$1
  label=$2
  if ! printf '%s\n' "$value" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._-]*$'; then
    echo "Invalid $label: $value" >&2
    exit 2
  fi
}

validate_ref() {
  value=$1
  if ! printf '%s\n' "$value" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._/-]*$'; then
    echo "Invalid AI Central ref: $value" >&2
    exit 2
  fi
}

validate_targets() {
  value=$1
  if ! printf '%s\n' "$value" | grep -Eq '^[a-z0-9-]+(,[a-z0-9-]+)*$'; then
    echo "Invalid APM targets: $value" >&2
    exit 2
  fi

  old_ifs=$IFS
  IFS=,
  set -- $value
  IFS=$old_ifs
  for target do
    case "$target" in
      agent-skills|antigravity|claude|codex|copilot|cursor|gemini|grok-build|intellij|kiro|opencode|windsurf) ;;
      *)
        echo "Unsupported stable APM target: $target" >&2
        exit 2
        ;;
    esac
  done
}

bundles=
bundle_supplied=0
skills=
skip_skills=
manifest_name=ai-central-selection
manifest_version=0.1.0
targets=agent-skills
ref=
output_file=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --bundle)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      bundles=$(append_csv "$bundles" "$2")
      bundle_supplied=1
      shift 2
      ;;
    --skills)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skills=$(append_csv "$skills" "$2")
      shift 2
      ;;
    --skip-skills)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      skip_skills=$(append_csv "$skip_skills" "$2")
      shift 2
      ;;
    --name)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      manifest_name=$2
      shift 2
      ;;
    --version)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      manifest_version=$2
      shift 2
      ;;
    --targets)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      targets=$2
      shift 2
      ;;
    --ref)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      ref=$2
      shift 2
      ;;
    --output)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      output_file=$2
      shift 2
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

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -z "$ref" ]; then
  if ! checkout_commit=$(git -C "$repo_root" rev-parse --verify HEAD 2>/dev/null); then
    echo "Unable to resolve the AI Central checkout commit; pass --ref explicitly." >&2
    exit 1
  fi
  release_version=$(sed -n '1p' "$repo_root/version.txt")
  release_tag=v$release_version
  tagged_commit=$(git -C "$repo_root" rev-parse --verify "$release_tag^{commit}" 2>/dev/null || true)
  if [ "$tagged_commit" = "$checkout_commit" ]; then
    ref=$release_tag
  else
    ref=$checkout_commit
  fi
fi

validate_identifier "$manifest_name" "manifest name"
validate_identifier "$manifest_version" "manifest version"
validate_targets "$targets"
validate_ref "$ref"

if [ -n "$output_file" ] && { [ -e "$output_file" ] || [ -L "$output_file" ]; }; then
  echo "Refusing to overwrite existing APM manifest: $output_file" >&2
  exit 1
fi

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-apm-selection.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
install_dir=$tmp_dir/install
manifest=$tmp_dir/apm.yml
seen_sources=$tmp_dir/seen-sources.tsv
mkdir -p "$install_dir"
: >"$seen_sources"

set -- "$install_dir" --bundle "$bundles" --mode link
if [ -n "$skills" ]; then
  set -- "$@" --skills "$skills"
fi
if [ -n "$skip_skills" ]; then
  set -- "$@" --skip-skills "$skip_skills"
fi
"$repo_root/scripts/install-skill-bundle.sh" "$@" >/dev/null

skill_count=$(
  find "$install_dir/.agents/skills" -mindepth 1 -maxdepth 1 -type l 2>/dev/null |
    wc -l | tr -d ' '
)

{
  echo "name: $manifest_name"
  echo "version: $manifest_version"
  echo "description: Exact AI Central skill selection generated from bundles and installed-name selectors."
  echo "targets:"
  printf '%s\n' "$targets" | tr ',' '\n' | while IFS= read -r target; do
    echo "  - $target"
  done
  echo "dependencies:"
  if [ "$skill_count" -eq 0 ]; then
    echo "  apm: []"
  else
    echo "  apm:"
    find "$install_dir/.agents/skills" -mindepth 1 -maxdepth 1 -type l | sort |
      while IFS= read -r link; do
        installed_name=$(basename "$link")
        source_path=$(readlink "$link")
        relative_path=${source_path#"$repo_root/"}
        natural_name=$(basename "$source_path")

        if [ "$relative_path" = "$source_path" ]; then
          echo "Skill link points outside the repository: $link -> $source_path" >&2
          exit 1
        fi

        existing_name=$(
          awk -F '\t' -v path="$relative_path" '$1 == path { print $2; exit }' "$seen_sources"
        )
        if [ -n "$existing_name" ]; then
          echo "APM source deduplication: keeping $existing_name and omitting $installed_name for $relative_path" >&2
          continue
        fi
        printf '%s\t%s\n' "$relative_path" "$installed_name" >>"$seen_sources"

        echo "    - git: https://github.com/dills122/ai-central.git"
        echo "      path: $relative_path"
        echo "      ref: $ref"
        if [ "$installed_name" != "$natural_name" ]; then
          echo "      alias: $installed_name"
        fi
      done
  fi
} >"$manifest"

if [ -n "$output_file" ]; then
  mkdir -p "$(dirname "$output_file")"
  cp "$manifest" "$output_file"
  echo "created $output_file" >&2
else
  cat "$manifest"
fi
