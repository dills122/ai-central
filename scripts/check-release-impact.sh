#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 BASE_REF PULL_REQUEST_TITLE" >&2
}

if [ "$#" -eq 1 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
  usage
  exit 0
fi
if [ "$#" -ne 2 ]; then
  usage
  exit 2
fi

base_ref=$1
title=$2

if ! git cat-file -e "$base_ref^{commit}" 2>/dev/null; then
  echo "Unable to resolve release-impact base ref: $base_ref" >&2
  exit 1
fi

release_content_changed=$(
  git diff --name-only "$base_ref...HEAD" |
    grep -E '^(templates/catalog\.json|templates/skills/.*/SKILL\.md)$' || true
)

if [ -z "$release_content_changed" ]; then
  exit 0
fi

if ! printf '%s\n' "$title" |
  grep -Eq '^(feat|fix)(\([a-z0-9][a-z0-9._/-]*\))?!?: .+'; then
  cat >&2 <<EOF
Changes to skill definitions or the bundle catalog must produce a release.
Use feat(...): for a minor release, fix(...): for a patch, or an approved ! marker for a major.

Release-bearing files:
$release_content_changed
EOF
  exit 1
fi
