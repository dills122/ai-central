#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$repo_root"

if [ ! -d collected ]; then
  echo "Missing collected directory" >&2
  exit 1
fi

find collected -type f -print0 | sort -z | xargs -0 shasum -a 256 > docs/source-manifest.sha256
echo "updated docs/source-manifest.sha256"
