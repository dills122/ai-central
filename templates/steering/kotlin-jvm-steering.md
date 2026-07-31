# Kotlin And JVM Steering

## Scope

Use this guidance for Kotlin/JVM code under `{{KOTLIN_ROOT}}`.

Repository-specific `AGENTS.md`, module documentation, and closer-scoped steering take precedence.
Follow the repository's existing framework and build conventions unless a change explicitly replaces
them.

## Build And Toolchain

- Use the checked-in Gradle wrapper; do not rely on a globally installed Gradle.
- Keep the Java toolchain, Kotlin JVM target, CI runtime, and container runtime aligned with
  `{{JVM_VERSION}}`.
- Pin Kotlin, plugins, and dependencies through the repository's existing dependency-management
  mechanism. Review toolchain upgrades separately from feature changes.
- Keep generated sources reproducible. Do not hand-edit generated code; change its schema or
  generator and regenerate it.
- Do not hide failing product-owned tests with source-set exclusions or broad test filters.

## Architecture And Boundaries

- Keep domain rules independent from HTTP, serialization, dependency-injection, SQL, and messaging
  framework types.
- Put use cases, command handlers, and workflow orchestration in an application layer organized by
  bounded context.
- Keep transport, persistence, and external-service code in explicit adapters or infrastructure
  packages.
- Keep composition-root wiring and environment bootstrap separate from request handlers and domain
  code.
- Prefer modules and packages named for business roles over generic technology buckets.

Framework code should connect the application; it should not define business behavior.

## API And Routing

- Keep routes thin: validate and map boundary data, invoke one application use case, and map its
  result.
- Split route modules by bounded context before an entrypoint accumulates unrelated handlers.
- Pass route modules cohesive services or gateways. A long constructor of single-method lambdas is
  still a misplaced god class.
- Keep transport failures distinct from domain rejections and return stable, structured error
  shapes.

## Kotlin Design

- Prefer immutable data classes for DTOs and event payloads.
- Use sealed types or enums for constrained state instead of stringly typed control flow.
- Make nullability, units, identifiers, money/quantity representation, and time semantics explicit
  at boundaries.
- Use structured concurrency. Avoid detached work, unbounded coroutine creation, and hidden blocking
  calls on coroutine dispatchers.
- Inject clocks, ID generators, and randomness sources when behavior must be deterministic.
- Keep classes cohesive; split orchestration, validation, persistence, projection, and serialization
  when they begin to change for different reasons.
- Extract a shared bootstrap or integration helper when the same pattern appears a second time and
  could otherwise drift.

## Persistence And Messaging

- Keep migrations explicit, ordered, and versioned.
- Make transaction boundaries visible in application workflows.
- Persist domain state and its corresponding outbox/event facts atomically when the delivery model
  requires it.
- Design consumers for the declared delivery semantics and enforce idempotency for retries.
- Avoid generic repositories that erase domain meaning or leak storage schemas into public API
  contracts.

## Contracts And Interoperability

- Define cross-module and cross-service contracts before transport adapters.
- Prefer additive, versioned contract evolution and test compatibility across supported producers
  and consumers.
- Carry required identity, correlation, causation, and time metadata through every adapter.
- Test serialization and semantic parity at language or service boundaries, not only compilation.

## Testing

Prioritize:

- domain state-transition and invariant tests;
- application command/use-case tests;
- route and serialization tests;
- persistence and migration integration tests;
- messaging and external-service contract tests;
- deterministic coroutine and time-dependent tests.

Workflow tests should assert resulting state and emitted facts, not only return values.

## Verification

Run the smallest reliable checks for the changed module, then the broader gate before handoff:

```sh
{{KOTLIN_TEST_COMMAND}}
{{KOTLIN_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
