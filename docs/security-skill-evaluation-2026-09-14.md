# Security Skill Forward-Test

Date: 2026-09-14. Method: one independent fresh-context agent applied the four
draft skills to a small supplied contract and Python fixture. It received no
intended answers or suspected findings. No network, third-party targets or project
source mutations were allowed; output stayed in an isolated temporary directory.

## Retained Inputs

- [Fixture](../scripts/fixtures/security-skills/fixture.py)
- [Contract](../scripts/fixtures/security-skills/CONTRACT.md)
- [Generated regression harness](../scripts/fixtures/security-skills/forward_test.py)

The fixture intentionally violates its contract. The harness is the evaluator's
output, not input for future independent evaluations. Its zero exit status means
the expected model violations and valid controls reproduced, **not** that the
fixture passed its security contract.

Reusable evaluation request (replace paths with the isolated input copy):

> Use security-state-recovery, security-secret-boundary-testing,
> security-race-and-toctou and security-protocol-fuzzing to assess fixture.py against
> CONTRACT.md. Create and run small bounded tests; produce an evidence report with
> supported conclusions and limits. Do not modify the fixture. No network or
> external resources. Keep generated tests and reports in the temporary workspace.

## Observed Results

| Workflow | Observation | Evidence boundary |
| --- | --- | --- |
| Recovery | Failure after acknowledgement leaves 1 acknowledgement and 0 stored rows after Receiver recreation | Model restart over the same Store; no process or disk durability claim |
| Race/TOCTOU | Two threads at the supported scheduling hook both consume a grant; 2 effects | Feasible deterministic model schedule; sequential controls produce 1 effect |
| Secret boundary | ASCII and binary synthetic Reply bodies appear in declared stderr | Named synchronous list sinks and captured Python streams; no OS-wide capture claim |
| Protocol fuzzing | 222 oversized accepts in 1,014 bounded cases; 129-byte payload is the smallest length violation | Deterministic seeds/PRNG sampling, not coverage-guided fuzzing or exhaustive parser proof |

The evaluator checked valid behavior, defective controls and thread termination.
It preserved the fixture SHA-256
`433feaf79f4924418bdb7608b90762508186175a3ca7f23955d68356c4460879`.
Initial environment: Python 3.14.6 on macOS 26.6.2 arm64.

Budgets: two race workers; 0.5-second barrier; 1-second joins; 1,014 protocol inputs
of at most 300 bytes; two-second campaign; 64 KiB capture; 32 KiB JSON evidence.
The decoder time check occurs between calls and is sufficient only for this
inspected nonblocking toy decoder. It is not an external watchdog for unknown code.
Native/whole-process allocation is not independently capped or measured.

## Feedback Applied

The recovery draft requested identifier/scope/generation variants without qualifying
APIs that lack those concepts. The evaluator correctly marked them unsupported.
The skill and evidence asset now explicitly say to use those dimensions only where
the target contract supports them. No other blocking workflow ambiguity emerged.

## Reproduce The Retained Model Checks

The repository gate runs these in a temporary directory. To inspect the JSON output
manually, copy the three retained files to an empty temporary directory and run
`python3 -B forward_test.py` there. The script writes sanitized `evidence.json` and
a synthetic `oversized-frame.bin` beside itself; do not run it in a source checkout
if those generated artifacts should remain outside the repository.

For future behavioral evaluation, give a fresh agent only the skills, fixture and
contract. Keep this report and the generated harness out of its context. Add clean
fixtures and different API shapes over time; this single forward-test does not
establish a measured false-positive rate or production effectiveness.
