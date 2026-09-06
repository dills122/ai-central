# ai-central context worktree hook v1
if [ "${3:-}" = "1" ] && [ -f .git ]; then
  case "${1:-}" in
    ""|*[!0]*) ;;
    *)
      (
        # Cross-checkout Git commands must not inherit the hook's GIT_DIR.
        unset $(git rev-parse --local-env-vars)
        {{CONTEXT_SETUP_COMMAND}} "$PWD" --source {{CONTEXT_SOURCE_DIR}}
      ) || exit "$?"
      ;;
  esac
fi
# /ai-central context worktree hook
