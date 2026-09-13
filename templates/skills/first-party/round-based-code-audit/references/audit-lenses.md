# Audit Lenses And Round Design

Use the requester's selected lenses. The default audit uses all groups below, but the number and names of rounds are configurable. Combine adjacent groups when the target is small; split a group when a large or high-risk subsystem needs a dedicated pass.

## Default Lens Groups

### Correctness And Reliability

- incorrect state transitions, boundary conditions, fall-through, stale state, and partial failure;
- error handling, retries, timeouts, cancellation, cleanup, and resource lifetime;
- concurrency hazards, ordering, idempotency, duplicate delivery, and race conditions;
- data integrity, transaction boundaries, migrations, serialization, and compatibility;
- unsupported assumptions about input, locale, time, precision, platform, or dependency behavior.

### Security, Privacy, And Abuse Resistance

- trust boundaries, authentication, authorization, tenancy, and privilege changes;
- injection, unsafe parsing or deserialization, path and URL handling, SSRF, and command execution;
- secrets, sensitive logs, personal data, retention, encryption, and insecure defaults;
- dependency and supply-chain exposure, integrity verification, and unsafe update behavior;
- denial of service, unbounded work, replay, rate limiting, and attacker-controlled resource use.

For a possible vulnerability, trace a concrete source-to-sink or attacker-to-impact path. Separate exploitability from defense-in-depth advice. Follow repository `SECURITY.md` disclosure rules.

### Architecture And Design Health

- god files, god objects, mixed responsibilities, inappropriate dependency direction, and hidden coupling;
- abstractions that leak, duplicate behavior, shotgun changes, and non-DRY logic with real divergence risk;
- circular dependencies, unclear ownership, feature scattering, and unstable interfaces;
- unnecessary indirection, speculative generality, and patterns that conflict with repository architecture;
- public API evolution, backward compatibility, and migration or rollback design.

File length alone does not prove a god file. Duplication is reportable when it creates drift, inconsistent behavior, or material maintenance cost—not merely because similar syntax exists twice.

### Maintainability And Code Quality

- confusing names, dense control flow, excessive mutation, dead code, and misleading comments;
- broad functions, deeply nested logic, implicit invariants, temporal coupling, and fragile ordering;
- type-system escape hatches, unchecked casts, sentinel values, and ambiguous error contracts;
- inconsistent repository style that harms comprehension or tool enforcement;
- poor testability, hard-coded collaborators, unstable seams, and absent ownership boundaries.

Do not report subjective preferences. Connect every style or smell finding to a concrete defect risk, comprehension burden, change amplification, or repository convention.

### Tests, Performance, And Operations

- missing high-value tests, assertions that cannot fail for the intended reason, unrealistic mocks, and flaky timing;
- algorithmic cost, repeated I/O, avoidable network chatter, unbounded memory, and hot-path blocking;
- configuration validation, environment parity, deployment safety, feature flags, and rollback;
- logs, metrics, traces, health checks, alertability, and diagnosability of partial failure;
- CI gaps, nondeterminism, artifact provenance, and checks that do not exercise production behavior.

Report performance only when the path is plausibly material or measurement supports it. Report test gaps as findings when a concrete behavior or regression risk is left unprotected.

### Documentation And Developer Experience

- stale or missing public API, setup, operational, recovery, or security documentation;
- code whose non-obvious invariants, failure modes, or lifecycle require maintained explanation;
- comments that contradict implementation and generated docs edited instead of their source;
- misleading examples, unusable commands, missing migration notes, and unclear contribution workflows;
- discoverability and onboarding costs that repeatedly force source archaeology.

Prefer fixing self-explanatory code over demanding comments. Documentation findings must identify the audience, missing decision or behavior, and consequence.

## Optional Target-Specific Lenses

Add these only when repository signals justify them:

- frontend accessibility, rendering, browser compatibility, and interaction states;
- API schema consistency, versioning, pagination, and client compatibility;
- database query plans, locking, isolation, backup, restore, and retention;
- distributed consistency, clock assumptions, partition behavior, and message delivery;
- infrastructure state, least privilege, network exposure, cost, and destructive lifecycle;
- mobile lifecycle, offline behavior, permissions, and constrained resources;
- build tooling, package publication, plugin boundaries, and consumer compatibility.

## Depth Calibration

- **Survey:** map the repository, inspect high-risk entry points and representative paths, and clearly state incomplete coverage.
- **Standard:** inspect every selected lens across the frozen target, trace material flows, review relevant tests and history, and run proportionate checks.
- **Deep:** expand complete flow tracing, variant searches, dependency and history analysis, additional targeted tests or analyzers, and adversarial validation. Deep does not mean inventing more findings.

## Coverage Map

Maintain a compact map with rows for selected lenses and columns for material subsystems or boundaries. Mark each cell `inspected`, `not applicable`, or `blind spot`. A list of files opened is not evidence of conceptual coverage.
