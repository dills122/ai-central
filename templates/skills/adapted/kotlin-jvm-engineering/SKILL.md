---
name: kotlin-jvm-engineering
description: Implement, refactor, review, or debug Kotlin/JVM services and libraries built with Gradle. Use for Kotlin source, Gradle Kotlin DSL, JVM toolchain alignment, coroutine behavior, layered service architecture, persistence adapters, generated contracts, and Kotlin test or CI changes.
---

# Kotlin/JVM Engineering

## Establish The Local Contract

1. Read `AGENTS.md`, closer-scoped guidance, module documentation, and the Gradle build files.
2. Locate the checked-in Gradle wrapper and identify the Java toolchain, Kotlin JVM target, plugin
   versions, dependency-management pattern, test framework, and CI commands.
3. Inspect sibling packages and tests before introducing a new structure.
4. Treat generated sources as outputs. Change the schema or generator, then regenerate.

## Preserve Architecture Boundaries

- Keep domain rules free of HTTP, serialization, DI, SQL, and messaging framework types.
- Put use cases, command handlers, and workflow orchestration in application code organized by
  bounded context.
- Keep transport, persistence, and external integrations in explicit adapters.
- Keep composition-root and environment bootstrap separate from routes and domain logic.
- Split route modules by bounded context before an entrypoint accumulates unrelated handlers.
- Prefer cohesive service or gateway dependencies over long lists of single-method lambdas.

Follow the repository's established framework. Do not introduce or replace Ktor, Spring, Micronaut,
serialization, migration, or DI tooling without an explicit requirement.

## Implement Kotlin Deliberately

- Prefer immutable data classes for DTOs and event payloads.
- Use sealed types or enums for constrained state.
- Make nullability, units, identity, money/quantity, and time semantics explicit at boundaries.
- Use structured concurrency; avoid detached jobs, unbounded coroutine creation, and hidden blocking
  work on coroutine dispatchers.
- Inject clocks, ID generators, and randomness when determinism matters.
- Keep domain rejection, validation failure, and infrastructure failure distinct.
- Extract shared bootstrap or integration helpers when a repeated pattern could drift.

## Protect Build And Data Integrity

- Use the checked-in wrapper rather than global Gradle.
- Keep the Java toolchain, Kotlin target, CI runtime, and container runtime aligned.
- Keep migrations explicit and versioned; make transaction boundaries visible.
- Match consumer idempotency to the declared messaging delivery semantics.
- Do not suppress product tests through source-set exclusions, broad filters, or coverage exclusions.
- Preserve additive compatibility for versioned contracts and test semantic parity across language
  or service boundaries.

## Verify In Layers

Run the smallest reliable module checks first, then the repository's broader gate:

1. focused unit or regression test;
2. module `test` or equivalent;
3. Gradle `check`, coverage verification, integration, or contract checks required by the repo;
4. formatting or static analysis configured by the project.

Report exact commands and results. If Gradle cannot run because dependency resolution, sandboxing,
or a service dependency is unavailable, state the unverified boundary and remaining risk.
