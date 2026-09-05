# ai-central cce worktree hook v1
# cce hook
# Git passes an all-zero old HEAD when creating a worktree. Seed synchronously
# before any background CCE index can create the target's empty store.
if [ "${3:-}" = "1" ] && [ -f .git ]; then
  case "${1:-}" in
    ""|*[!0]*)
      {{CCE_COMMAND}} index >/dev/null 2>&1 &
      ;;
    *)
      (
        unset $(git rev-parse --local-env-vars)
        CCE_BIN={{CCE_COMMAND}} {{CCE_SEED_COMMAND}} "$PWD" --source {{CCE_SOURCE_DIR}}
      ) || exit "$?"
      ;;
  esac
else
  {{CCE_COMMAND}} index >/dev/null 2>&1 &
fi
# /ai-central cce worktree hook
