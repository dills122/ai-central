---
name: kotlin-jvm-engineering
description: Implement, refactor, review, or debug Kotlin/JVM services, libraries, CLI tools, and applications built with Gradle. Use for Kotlin source, Gradle Kotlin DSL, JVM toolchain compatibility, dependency and module changes, coroutine behavior, public APIs, Java interoperability, generated code, tests, or CI.
---

# Kotlin/JVM Engineering

## Establish The Project Contract

1. Read `AGENTS.md`, `.codex/steering/kotlin-jvm-steering.md` when installed, closer-scoped guidance,
   module documentation, Gradle settings, and the affected build files.
2. Use the checked-in Gradle wrapper and identify the Java toolchain, Kotlin JVM target, plugin and
   dependency-management approach, test framework, formatting/linting tools, and CI commands.
3. Inspect neighboring source and tests before introducing a new package, abstraction, dependency,
   or convention.
4. Identify any public Kotlin, Java, serialization, configuration, CLI, or service contract affected
   by the change.
5. Treat generated sources as outputs. Change their source schema or generator, then regenerate.

## Fit The Existing Project

- Preserve the established architecture and module boundaries unless the task explicitly changes
  them.
- Keep core behavior independently testable and keep external I/O or framework integration at clear
  boundaries where relevant.
- Keep entrypoints and adapters focused on input mapping, behavior invocation, and result mapping.
- Keep library APIs narrow; hide implementation details with private or `internal` visibility.
- Avoid cyclic dependencies, catch-all utility packages, speculative abstractions, and wrappers that
  add no meaningful boundary.
- Do not introduce or replace a framework, serialization library, persistence tool, DI container, or
  logging stack without a concrete requirement.

## Implement Kotlin Deliberately

- Prefer immutable values and read-only collections unless mutation has a clear owner.
- Make nullability and invalid states explicit; avoid sentinel values and stringly typed control
  flow.
- Use data classes, sealed types, enums, and value classes when they improve the model, not as
  mandatory architecture.
- Keep functions and classes cohesive, and preserve useful error causes rather than swallowing broad
  exceptions.
- Consider Java callers when changing supported Java-facing APIs.
- Use structured concurrency, explicit cancellation, bounded parallelism, and appropriate
  dispatchers when the project uses coroutines.
- Avoid adding concurrency to code that does not benefit from it.
- Inject time, scheduling, IDs, or randomness when deterministic behavior matters.

## Protect Build And Boundary Integrity

- Keep the Java toolchain, Kotlin target, CI runtime, and deployment runtime compatible.
- Use the repository's dependency-management mechanism, preserve locks and verification metadata,
  and keep new dependencies intentional.
- Keep generated output reproducible and verify drift when contracts or generators change.
- Apply migrations, transaction, retry, idempotency, timeout, and resource-bound rules only to the
  data or integration boundaries that actually exist.
- Keep credentials out of source control and avoid exposing secrets through errors or logs.
- Preserve compatibility for downstream users or make breaking changes explicit and tested.
- Do not suppress failing project tests through broad exclusions, filters, or relaxed gates.

## Verify In Layers

Run the smallest reliable checks first, followed by the repository gate:

1. focused unit or regression tests;
2. the affected module's test task;
3. formatting and static analysis configured by the project;
4. Gradle `check`, compatibility, integration, or generated-code drift checks required by the repo.

Report exact commands and results. If Gradle cannot run because dependency resolution, sandboxing,
or an external service is unavailable, state the unverified boundary and remaining risk.
