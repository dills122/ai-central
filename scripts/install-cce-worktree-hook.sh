#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec python3 -B "$script_dir/install-cce-worktree-hook.py" "$@"
