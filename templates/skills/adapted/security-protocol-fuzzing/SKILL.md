---
name: security-protocol-fuzzing
description: Build bounded fuzzing campaigns and regression corpora for parsers, wire formats, IPC, and protocol state machines. Use when malformed inputs or operation sequences must preserve explicit security properties. Not a broad network scan or cryptographic proof.
license: MIT
---

# Protocol Fuzzing

Adapted from `SnailSploit/Claude-Red`,
`Skills/fuzzing/offensive-fuzzing/SKILL.md`, commit
`24d7968bab4b883e7f13477afe0fd91f2df3b722` (MIT; see [LICENSE](LICENSE)).
The target/harness/corpus/oracle/triage workflow is narrowed to repository-owned
protocol tests, with original state and evidence guidance added for AI Central.

## Choose A Target And Oracle

Start at the real untrusted boundary, naming the revision, decoder or dispatcher,
wire version, supported inputs and resource contract. Identify what detects a bug:
panic, sanitizer report, excessive work, forbidden state change, authorization
effect or violation of canonical encoding. A crash-free run alone does not prove
a security property.

Choose only properties the contract requires:

- Parser rejection leaves retained state and quotas unchanged when specified.
- Accepted canonical bytes re-encode identically when the format requires it;
  general decoders may intentionally accept multiple equivalent encodings.
- A rejected or expired proof cannot consume unrelated authority.
- Duplicate/reordered operations obey declared replay and lifecycle semantics.
- Work, allocation, recursion and retained state stay within their own budgets.

Do not assume all operations are idempotent. Differential disagreement is a lead;
resolve which implementation or specification defines the expected behavior.

## Build The Harness

Use the project's existing test and fuzz stack. Consult
[references/harness-selection.md](references/harness-selection.md) when choosing
between language-native fuzzing, sanitizers and sequence tests.

1. Call the actual parser/operation without a duplicate validator that hides bad
   input. Cap campaign input separately from product limits and make the harness
   cap large enough to exercise just-over-limit product cases safely.
2. Reset per-case state, clock and randomness as required for reproduction. For a
   stateful protocol, encode a bounded sequence and reset between sequences, not
   between every operation inside one sequence.
3. Seed valid canonical examples, empty/truncated data, exact limit and limit+1,
   unknown tags/versions, duplicate fields, bad lengths and relevant expired,
   replayed or reordered operations. Use synthetic data with no real bearer rights.
4. Keep real signature verification in production-boundary tests. To reach deeper
   state logic, generate fixture-valid signed inputs or use a separately labelled
   internal harness. A bypassed verifier cannot establish authentication security.
5. Define elapsed time, input size, memory, worker count, operation count and
   artifact limits. Use local fixtures; no dependency installation, external
   downloads or network targeting is implied by skill activation.
6. Confirm the oracle detects a controlled defective fixture or temporary mutation
   and that valid inputs reach meaningful behavior. Do not swallow all exceptions,
   filter all malformed inputs, or treat a harness crash as a product finding.

## Run And Retain

Run a bounded initial campaign. Track reached behaviors and reject reasons as well
as execution counts. If mutations never pass a checksum/signature or reach a state
transition, improve seed generation or target selection before increasing runtime.

Reproduce and minimize failures while preserving the invariant violation and
required state history. Distinguish timeout, OOM, harness defect and product defect.
Save the minimized synthetic case as an ordinary deterministic regression so it
runs without the fuzz engine. Keep longer campaigns separate from fast CI tests.

Use [assets/fuzz-campaign.md](assets/fuzz-campaign.md) to record configuration,
oracles, seeds, commands, instrumented target, results and gaps. A finite campaign
supports its observed coverage only; it does not certify parser safety, protocol
correctness or the strength of cryptographic primitives.
