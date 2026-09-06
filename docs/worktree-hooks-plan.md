# Worktree Hook Requirements And Plan

This scope records the user's CCE seeding request and subsequent request for a separate AI Central
context hook. It is the canonical acceptance checklist for the combined uncommitted change;
there was no separate formal plan file before implementation began.

## Required Observable Behavior

1. A new ordinary Git worktree can reuse compatible CCE embeddings from an existing checkout of
   the same repository, while retaining independent search data and session state.
2. An independently installable hook seeds AI Central's ignored agent guidance, skills, steering,
   and agent definitions without requiring CCE or the Codex Local Environment trigger.
3. Both hook installations coexist in Git's single post-checkout hook, preserve unrelated commands,
   and order context seeding before CCE on new worktree creation in either install order.
4. Existing hooks require explicit replacement permission, with preview, backup, and idempotent
   reinstallation. Existing target context and CCE stores are not replaced.
5. Manifest-level relative external context links continue working in deeply nested worktrees;
   internal relative links remain local to the worktree. Whole allowlisted directory links are
   supported, with a whole canonical skills directory treated as authoritative: legacy aliases
   must not be adopted by writing through it into the shared source.
6. Setup errors remain visible. Missing source caches do not silently create fresh cold CCE stores.
   Context audit failures return failure to Git. Manual setup remains a fallback.
7. Tests cover actual Git dispatch, context-only and combined flows, SQLite WAL-safe cache reuse,
   target isolation, external-link traversal through intermediate symlinks, minimal-PATH CCE
   runtime discovery after both absolute- and relative-PATH hook installation, and relevant refusals. The full repository check
   must pass.
8. A fresh-context independent reviewer assesses both the implementation and this plan, starting
   with a neutral bootstrap before reading the author explanation. Up to three instances, with
   findings returned to the author before any next instance.

## Implementation Sequence

- Implement cache-only CCE snapshot and worktree indexing; integrate the optional setup flag.
- Add a CCE hook installer to seed before the stock background checkout index starts.
- Add an independent context block and share the hook installation mechanics.
- Correct context-link portability and whole-directory allowlist handling exposed by hook tests.
- Document installation, coexistence, recovery, prerequisites, and trigger limitations.
- Run fixture checks and an optional installed-CCE integration check; freeze the dirty-tree scope
  and hand off to the independent reviewer. Address bounded findings and rerun review if material.

## Deliberate Limits

No automatic rollout into unspecified consuming repositories, commits, pushes, or global settings.
No automatic edits to custom external hook managers or MCP project bindings. No proof yet that
every Codex app worktree creation path dispatches the hook. No large-repository latency benchmark.
Full live-index cloning is deferred because CCE does not atomically publish all of its stores.
The cache adapter supports the inspected CCE 0.4.26 contract only. The context hook is independent
of that version gate. Collected historical material and its source manifest are unchanged.
Links nested inside copied real directories retain their source link text; recursive rewriting
is a pre-existing portability limitation, not an acceptance claim of this work. The first review
identified that the original criterion 5 wording was broader than the implemented link boundary;
this wording makes that boundary explicit.
