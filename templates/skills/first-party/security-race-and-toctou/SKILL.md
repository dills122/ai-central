---
name: security-race-and-toctou
description: Design controlled concurrency tests for authorization reuse, check/use identity changes, and non-atomic state transitions. Use for one-use grants, filesystem snapshots, competing reservations, or cancellation races. Not a broad penetration test or kernel exploitation workflow.
license: MIT
---

# Race And TOCTOU Testing

Find a schedule that violates a documented invariant, then preserve it as a
bounded regression. TOCTOU means that an observation no longer justifies the later
operation because relevant state or identity changed between them.

## Model The Competing Operations

Name the checked object, the action that uses it, and the actor able to change it.
Record the target revision and actual contract for revocation, expiry and one-use
consumption. Continued work after revocation is not automatically a bug: determine
whether the contract authorizes a snapshot or requires continuing authorization.

Locate the atomic decision point and what protects it: transaction, lock,
compare-and-swap, immutable snapshot or OS handle. Determine whether every competing
path participates in that mechanism. A thread-race detector can miss a logical race
that spans individually synchronized operations or separate processes.

## Construct A Controlled Schedule

1. Use local synthetic grants, isolated stores and fixture files. Identify owned
   workers, total attempts, per-wait deadlines and cleanup before execution.
2. Place a test barrier or fault hook after the relevant check and before use;
   perform the competing mutation, then release the operation. The hook must not
   create a behavior impossible in the real code or bypass the control under test.
3. Assert complete effects, not only return values. For a one-use grant, count
   successful authority-bearing effects and inspect consumption state. Depending
   on the contract, a duplicate may return an earlier result without a new effect.
4. Exercise both orderings, invalid identity/scope, same identifier with different
   content, and cancellation near the commit point where applicable. After refusal,
   verify an unrelated valid operation still succeeds.
5. Demonstrate that a defective fixture or temporary mutation fails the same oracle,
   then remove it. Keep the bounded schedule and fixture as regression evidence.

Do not serialize the competing operations in the harness and then claim they are
safe under concurrency. If testing a locking fix, put the observation hook outside
the protected region or observe blocked contenders; do not require both workers to
reach a barrier inside a lock held by one worker. All waits need deadlines.

## Filesystem And Native Boundaries

Use two harmless files beneath a temporary fixture root for substitution tests.
Track path resolution separately from the opened object, byte snapshot and later
action. Inspect parent-directory replacement, links/reparse points and inherited
handles only when they are part of the target's threat model.

Do not prescribe one flag as a portable fix. A no-follow flag's scope and native
handle guarantees vary; verify the selected OS API and full resolution path.
Holding a handle can stabilize identity without making its content immutable.
Never use system credential files or unrelated processes as proof targets.

## Evidence And Limits

Use [assets/race-case.md](assets/race-case.md). State whether the schedule is
deterministic, instrumented, model-only or probabilistic. Record observations and
budgets for stress runs; no observed failure is not proof of impossibility. Report
unsupported hook schedules as inconclusive rather than vulnerabilities. A fix must
preserve the operation's intended semantics, not merely reduce the timing window.

Concept reference: [CWE-367](https://cwe.mitre.org/data/definitions/367.html).
This is an AI Central-authored workflow; no Claude-Red checklist text or payloads
are imported here.
