#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 TITLE [LABELS]" >&2
}

if [ "$#" -eq 1 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
  usage
  exit 0
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  usage
  exit 2
fi

title=$1
labels=${2:-}
pattern='^(feat|fix|perf|refactor|docs|test|build|ci|chore|revert)(\([a-z0-9][a-z0-9._/-]*\))?!?: .+'

if ! printf '%s\n' "$title" | grep -Eq "$pattern"; then
  cat >&2 <<EOF
Pull request title must use Conventional Commits so release automation can classify it:
  feat(skills): add or materially improve a skill
  fix(skills): make a backward-compatible correction
  feat(skills)!: make a breaking skill change
  docs: clarify project usage

Received: $title
EOF
  exit 1
fi

breaking_pattern='^(feat|fix|perf|refactor|docs|test|build|ci|chore|revert)(\([a-z0-9][a-z0-9._/-]*\))?!:'
if printf '%s\n' "$title" | grep -Eq "$breaking_pattern"; then
  case ",$labels," in
    *",release:major-approved,"*) ;;
    *)
      echo "Breaking pull request title requires release:major-approved: $title" >&2
      exit 1
      ;;
  esac
fi
