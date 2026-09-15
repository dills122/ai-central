---
name: security-secret-boundary-testing
description: Build synthetic-secret regression tests across formatting, logs, IPC, files, and retained test artifacts. Use when verifying redaction or secret custody boundaries, especially across processes. Not a credential-harvesting or production secret-rotation workflow.
license: MIT
---

# Secret Boundary Testing

Test which component may see each secret and which observations must exclude it.
Use generated fixture secrets that cannot authenticate to a real service. Never
use real credentials merely to make a leakage test realistic.

## Define The Observation Boundary

Read the custody and telemetry contract. Separate authorized storage/transport of
a secret from accidental exposure. Ciphertext, identifiers, lengths and timing can
also be restricted by a privacy contract; do not assume only plaintext matters.

Inventory channels before running the scenario: ordinary and pretty formatting,
nested errors/results, stdout/stderr, child-process diagnostics, logs/traces,
temporary files, IPC, crash output and CI artifacts. Identify who owns collection
of each channel. A caller-selected subset cannot prove complete capture.

Keep fixture source, expected-value buffers and authorized vault data separate
from forbidden observations. Their intentional canaries are not leakage findings.

## Build The Regression

1. Generate distinct synthetic values for each secret class and owner. Exercise
   relevant encodings and binary values, including empty and non-UTF8 input where
   supported. Never print the secret to explain an assertion failure.
2. Drive the real producer, formatter and boundary under test, including refusal,
   cancellation and restart paths. A test of a redaction helper alone does not
   cover wrappers that bypass it.
3. Capture bounded output from all declared channels. Start collection before
   secret creation and finish after owned children exit and buffers drain. Flag
   truncation, missing streams and early collector failure as incomplete capture.
4. Assert that forbidden observations lack the fixture secret and contract-relevant
   representations. Check nested/pretty Debug or equivalent formatting as well as
   the ordinary form. Preserve explicit authorized accessors and useful nonsecret
   diagnostics required by the API.
5. Include a controlled leaky formatter or test-only emission into a forbidden
   channel. The same capture and scan path must detect it. Report channel and
   secret-class labels rather than matching bytes.
6. Prove the intended operation still succeeds: a restart can unlock, an authorized
   recipient can decrypt, or a valid error remains diagnosable. Suppressing the
   operation or losing all diagnostics is not sufficient evidence of correctness.

Use [assets/capture-inventory.md](assets/capture-inventory.md) to retain the inventory
and verdict. Work within existing authorized fixtures. This workflow does not
grant access to unrelated local secrets, service accounts or production artifacts.

## Report Three Separate Results

- **Secret scan:** pass, fail or not run for the declared captured surfaces.
- **Capture completeness:** established for the named scope, incomplete or unproved.
- **Boundary claim:** supported only for the intersection of tested secret classes,
  representations, channels, execution paths and platform behavior.

Passing substring scans do not establish resistance to arbitrary encoding or
inference, memory zeroization, same-account process isolation, ACL privacy on
another OS, or absence of all secrets. A signed artifact authenticates captured
bytes; it cannot prove that omitted channels were captured.
