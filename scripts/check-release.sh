#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage: check-release.sh [--base-ref REF --labels LIST]

Without arguments, validate the repository version and generated APM package versions.
With --base-ref, also validate an intentional release version change against the base ref.
LIST is the comma-separated pull request label list supplied by GitHub Actions.
EOF
}

base_ref=
labels=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --base-ref)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      base_ref=$2
      shift 2
      ;;
    --labels)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      labels=$2
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

version=$(sed -n '1p' version.txt)
semver_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
if ! printf '%s\n' "$version" | grep -Eq "$semver_pattern"; then
  echo "version.txt must contain one stable semantic version: $version" >&2
  exit 1
fi
if [ "$(wc -l <version.txt | tr -d ' ')" -ne 1 ]; then
  echo "version.txt must contain exactly one line" >&2
  exit 1
fi

release_please_version=$(
  sed -n 's/^[[:space:]]*"\.":[[:space:]]*"\([0-9][0-9.]*\)"[[:space:]]*$/\1/p' \
    .release-please-manifest.json
)
if [ "$release_please_version" != "$version" ]; then
  echo ".release-please-manifest.json version $release_please_version does not match version.txt $version" >&2
  exit 1
fi

manifest_count=0
for manifest in packages/apm/*/apm.yml; do
  manifest_count=$((manifest_count + 1))
  manifest_version=$(sed -n 's/^version: //p' "$manifest")
  if [ "$manifest_version" != "$version" ]; then
    echo "$manifest version $manifest_version does not match version.txt $version" >&2
    exit 1
  fi
done
if [ "$manifest_count" -eq 0 ]; then
  echo "No generated APM package manifests found" >&2
  exit 1
fi

if [ -z "$base_ref" ]; then
  exit 0
fi

if ! git cat-file -e "$base_ref^{commit}" 2>/dev/null; then
  echo "Unable to resolve release-policy base ref: $base_ref" >&2
  exit 1
fi

base_version=$(git show "$base_ref:version.txt" 2>/dev/null || true)
if [ -z "$base_version" ]; then
  echo "Release version baseline initialized at $version"
  exit 0
fi
if ! printf '%s\n' "$base_version" | grep -Eq "$semver_pattern"; then
  echo "Base version is not a stable semantic version: $base_version" >&2
  exit 1
fi
if [ "$base_version" = "$version" ]; then
  exit 0
fi

case ",$labels," in
  *",autorelease: pending,"*|*",release:manual,"*) ;;
  *)
    echo "Only a Release Please PR or a release:manual PR may change version.txt" >&2
    exit 1
    ;;
esac

old_ifs=$IFS
IFS=.
set -- $base_version
base_major=$1
base_minor=$2
base_patch=$3
set -- $version
next_major=$1
next_minor=$2
next_patch=$3
IFS=$old_ifs

if [ "$next_major" -lt "$base_major" ] || \
   { [ "$next_major" -eq "$base_major" ] && [ "$next_minor" -lt "$base_minor" ]; } || \
   { [ "$next_major" -eq "$base_major" ] && [ "$next_minor" -eq "$base_minor" ] && [ "$next_patch" -le "$base_patch" ]; }; then
  echo "Release version must increase: $base_version -> $version" >&2
  exit 1
fi

if [ "$next_major" -gt "$base_major" ]; then
  case ",$labels," in
    *",release:major-approved,"*) ;;
    *)
      echo "Major release $base_version -> $version requires release:major-approved" >&2
      exit 1
      ;;
  esac
fi

echo "Release version change approved: $base_version -> $version"
