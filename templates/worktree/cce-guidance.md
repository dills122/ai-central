# CCE Context For {{PROJECT_NAME}}

- Use the CCE server bound to this worktree for repository searches. Check its project binding
  before relying on results; a primary-checkout server represents that checkout's state.
- The worktree filesystem is authoritative for current code, especially files edited after the
  last indexing run. Verify retrieved paths and relevant code before editing.
- Worktree setup reuses compatible embeddings from the primary checkout and builds independent
  search data. Each worktree should keep its own CCE store; never symlink writable index stores.
- If setup reports an indexing failure, resolve it and rerun setup before treating CCE as current.
  A cache-only seed is not a searchable index.
