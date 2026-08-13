---
name: spec-traceability
description: Maintain end-to-end traceability from repository requirements and decisions through implementation tasks, tests, evidence, and completion status. Use when writing or updating specs and plans, splitting work across sessions or agents, validating a feature against acceptance criteria, reconciling plan drift, or deciding whether work is actually complete.
---

# Spec Traceability

Make repository artifacts explain what is required, what implements it, and what proves it without relying on chat history.

## Establish The Authority Chain

Find the repository's existing source-of-truth hierarchy before inventing files. Prefer its naming and locations. Distinguish:

1. requirements and non-goals;
2. accepted decisions and constraints;
3. implementation tasks and dependencies;
4. tests or checks derived from acceptance criteria;
5. retained evidence and current status.

Do not make a plan override a spec or make a progress log override executed evidence.

## Use Stable Identifiers

Assign stable IDs when work spans multiple artifacts or agents, for example `REQ-004`, `DEC-002`, and `TASK-011`. Never renumber completed or externally referenced IDs. Mark superseded items and link their replacements.

Each task must identify:

- the requirement or decision it advances;
- its observable output;
- dependencies;
- acceptance conditions;
- verification method;
- status and evidence location.

## Maintain A Traceability View

Use the smallest representation that fits the repository. A compact table is usually enough:

```markdown
| Requirement | Decision | Tasks | Verification | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| REQ-004 | DEC-002 | TASK-011 | `pnpm test:x` | PR #123 | Passed |
```

Link to canonical sections rather than copying their full text. Leave an explicit gap when no task, test, or evidence exists; do not infer coverage.

## Update In The Right Order

When scope or architecture changes:

1. update the governing requirement or decision;
2. revise affected tasks and dependencies;
3. update or add verification derived from the revised acceptance criteria;
4. implement;
5. record evidence and status.

When implementation exposes an undocumented behavior, decide whether the code is wrong or the source of truth must change. Do not silently rewrite the spec after implementation.

## Completion Gate

Before marking an item complete, confirm:

- every in-scope requirement maps to an implementation task or explicit deferral;
- every completed task has executed verification evidence;
- test claims follow the acceptance criteria rather than mirror implementation details;
- conflicting prose is corrected or marked stale;
- parent status reflects the parent acceptance boundary, not only completed child work;
- open questions, limitations, and deferred work remain visible.

Executed failures and current repository state outrank optimistic prose. Missing evidence means incomplete, not passed.
