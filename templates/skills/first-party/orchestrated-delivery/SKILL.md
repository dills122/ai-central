---
name: orchestrated-delivery
description: Plan, dispatch, monitor, reconcile, and close multi-agent or multi-chat repository work. Use when a brain or lead chat owns a larger outcome, when work must be split across subagents or separate Codex tasks, when a task graph has parallel lanes, or when child handoffs must be integrated into one verified repository result. Do not use for a small self-contained change that one agent can finish directly.
---

# Orchestrated Delivery

Keep the lead task responsible for requirements, integration, and final delivery. Move bounded work to child tasks without letting chat history become the source of truth.

## Classify Every Assignment

Choose one delivery unit before dispatch:

- **Internal subagent:** bounded work inside the lead task's branch and worktree. The lead owns conflicts, commits, verification, and the final PR.
- **Independent task:** a user-visible outcome with its own branch or worktree and complete delivery handoff.
- **Research task:** read-only or experimental work that returns evidence and a recommendation. Convert it before retaining implementation changes.

Delegate only when the user, applicable repository instructions, or runtime policy authorizes it. Prefer parallel agents for independent exploration, review, tests, and research. Serialize work that shares files, contracts, migrations, or mutable state.

## Build The Execution Index

Read the repository's canonical specs, plans, ADRs, and applicable `AGENTS.md`. Write or update one repo artifact that records:

- objective and completion boundary;
- work items with stable IDs;
- dependencies and parallel lanes;
- owner or delivery-unit type;
- acceptance and verification commands;
- current status, blockers, and integration destination.

Do not duplicate product truth into the execution index. Link to the canonical requirement or decision.

## Dispatch A Complete Packet

Give every child:

```markdown
Work item: <stable ID and title>
Outcome: <one bounded result>
Read first: <canonical files>
Scope: <owned paths or research boundary>
Do not change: <shared or protected paths>
Acceptance: <observable conditions>
Verify: <commands or evidence>
Delivery unit: <internal subagent | independent task | research>
Return: <required handoff fields>
```

State whether the lead will wait for all children, integrate incrementally, or stop at a decision gate. Tell parallel writers that they share the codebase and must preserve other work.

## Require Structured Handoffs

Collect these fields from every child:

- scoped status and parent status when different;
- summary of work and files or artifacts retained;
- exact verification and results;
- decisions, assumptions, confidence, and limitations;
- unresolved questions and recommended next action;
- branch, commit, PR, or explicit integration destination when applicable.

A child result is evidence, not an automatic verdict. Re-read material claims against the repository before accepting them.

## Reconcile And Close

1. Confirm every requested child returned or was explicitly cancelled.
2. Reconcile conflicting findings and shared-file changes.
3. Update canonical specs, plans, ADRs, and status in the same retained change when reality changed.
4. Run integration-level verification from the lead task.
5. Confirm every retained commit has a PR or documented destination.
6. Report completed, blocked, and deferred work separately.

Never declare the parent complete because its child slices completed. Parent completion requires integrated evidence against the parent acceptance boundary.
