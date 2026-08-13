---
name: session-handoff
description: Create, validate, consume, or refresh a durable repository handoff for continuing work in another Codex chat or after context reset. Use when pausing substantial work, moving an outcome to a separate task, resuming from a handoff, or preserving state that would otherwise exist only in conversation history. Do not create handoffs for trivial completed work.
---

# Session Handoff

Persist only the context a fresh agent needs to continue safely. Prefer the repository's existing handoff convention; otherwise use `docs/work/handoffs/YYYY-MM-DD-<slug>.md`.

## Create Or Refresh

Inspect the current branch, status, recent commits, changed files, canonical plan, and executed verification. Write:

```markdown
# Handoff: <outcome>

## Objective And Boundary
## Canonical Sources
## Current Repository State
## Completed Work And Evidence
## Decisions And Rationale
## Blockers And Limitations
## Immediate Next Actions
## Verification Commands
## Delivery Metadata
```

Delivery metadata includes the repository path, branch, base or checkpoint commit, retained commits, PR, dirty files, and date. Use stable spec or task IDs where available.

Record what failed and why so the next task does not repeat dead ends. Never include secrets, credential bytes, private tokens, or unnecessary raw logs.

## Validate Before Handoff

Confirm that:

- referenced files and commits exist;
- reported status matches the current worktree and executed checks;
- dirty or uncommitted work is named explicitly;
- the first next action is concrete and safe;
- decisions that affect the product or architecture are also in canonical specs or ADRs;
- the handoff does not pretend to be a source of product truth.

## Resume

1. Read applicable `AGENTS.md` and the handoff completely.
2. Verify repository, branch, commit, worktree state, and referenced paths.
3. Inspect commits and file changes since the handoff; classify it as current, partially stale, or stale.
4. Reconcile the handoff with canonical specs and plans. Repository truth wins.
5. Start from the first still-valid next action.
6. Update or supersede the handoff when the continuation reaches another boundary.

Do not chain every historical handoff into context. Read the newest one first and follow predecessors only when it references unresolved decisions or evidence.
