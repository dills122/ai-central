---
name: security-state-recovery
description: Design and verify crash, retry, replay, and restart tests for security-sensitive state transitions. Use for invitation consumption, durable outboxes, acknowledgement ordering, approval journals, or teardown recovery. Not a general backup or database migration workflow.
license: MIT
---

# Security State Recovery

Turn the target's recovery contract into observable state-transition tests. Use
repository contracts and supported failure models; do not invent stronger
durability or rollback guarantees.

## Establish The Contract

Identify the operation's owner, authorization scope, persisted state, external
effects and commit point. Separate what the caller was told from what actually
committed. An error or timeout can leave an indeterminate operation.

Record the target revision, platform, storage implementation, allowed fixtures,
fault budget and intended evidence location. Existing authorization covers local
reversible tests in scope; it does not authorize killing unrelated processes or
faulting live storage. Use isolated fixture stores and owned child processes.

Write allowed pre-state and post-state combinations before injecting faults. For
example, when a contract requires persist-before-acknowledge, an acknowledgement
without the corresponding durable receive state is forbidden. Some outbox contracts
allow duplicate delivery and require receiver deduplication; do not demand globally
exactly-once side effects from a local transaction.

## Exercise Transitions

1. Trace validation, reservation, mutation, durable commit, publication and
   acknowledgement. Mark where authority is consumed and which component owns it.
2. Inject faults before and after meaningful boundaries, including a committed
   operation whose response is lost. Prefer deterministic fault hooks over sleeps.
3. Reopen through the real supported recovery path. Discard volatile state and
   recreate the owner; use a fresh process when claiming process-restart behavior.
4. Compare the complete relevant state with the allowed outcomes: invitation or
   grant, membership, replay record, outbox, cursor, acknowledgement intent and
   external effect as applicable. Checking only the public return value is weak.
5. Retry the same operation. Where the contract/API supports identifiers, scope,
   generation or owner, vary them while reusing an operation identifier and check
   that collisions cannot replay authority. Mark unsupported dimensions explicitly;
   do not invent deduplication or identity guarantees for an API that lacks them.
6. After refusal, prove a legitimate operation still works within the documented
   recovery policy. An implementation that rejects everything is not a passing fix.

Use a deliberately defective local fixture or temporary mutation to show the
oracle detects a forbidden outcome. Keep mutations out of shipped code. Record
whether the test covers a model, real adapter, composed application, or native
storage behavior; success in one layer does not prove the next.

## Calibrate Failure Claims

- Process termination does not establish power-loss durability.
- Atomic crash recovery does not establish rejection of an older valid snapshot.
  Rollback resistance needs a contract and freshness authority outside that snapshot.
- A timeout does not establish cancellation, child termination or absence of an
  external effect. Observe cleanup and unresolved ownership separately.
- Recovery must not adopt a resource solely because a reusable PID or path matches.
- Include storage refusal and unavailable clocks when the contract depends on them;
  preserve explicit indeterminate states instead of labelling them success.

## Retain Evidence

Use [assets/recovery-matrix.md](assets/recovery-matrix.md) for plans or results.
Fill only supported claims and mark unrun rows. Report the reproduced violation,
fault schedule, permitted outcome, observed reopened state, revision, commands,
negative control and platform limits. Redact secret-bearing state; use synthetic
identities. Publishing findings or changing unrelated deployment policy remains
outside this workflow unless requested.
