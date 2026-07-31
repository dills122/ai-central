# Kotlin And JVM Steering

## Scope

Use this guidance for Kotlin/JVM code under `{{KOTLIN_ROOT}}`.

Repository-specific `AGENTS.md`, module documentation, and closer-scoped steering take precedence.
Follow the project's existing architecture, framework, and build conventions unless a change
explicitly replaces them. Replace every placeholder before treating this file as project policy.

## Build And Toolchain

- Use the checked-in Gradle wrapper rather than a globally installed Gradle.
- Keep the Java toolchain, Kotlin JVM target, CI runtime, and deployment runtime compatible with
  `{{JVM_VERSION}}`.
- Manage plugin and dependency versions through the repository's established mechanism, such as a
  version catalog, convention plugin, or dependency-management block.
- Keep dependency additions narrow and intentional. Check the standard library and existing
  dependencies before introducing another library.
- Separate toolchain and major dependency upgrades from unrelated feature work when practical.
- Treat generated sources as outputs: change the schema or generator, regenerate, and verify drift.
- Do not hide failing project tests with source-set exclusions, broad filters, or relaxed gates.

## Structure And Boundaries

- Preserve the repository's established module and package boundaries; do not impose a new
  architectural style without a concrete need.
- Keep core behavior testable without booting an entire framework or external environment.
- Keep I/O, configuration, serialization, persistence, and external-system integration at clear
  boundaries when the project uses them.
- Keep application entrypoints and framework adapters focused on mapping inputs, invoking behavior,
  and mapping results.
- Keep library public APIs narrow and intentional. Prefer `internal` or private visibility for
  implementation details.
- Avoid catch-all utility packages, cyclic module dependencies, and abstractions that only wrap one
  implementation without adding a useful boundary.
- Follow existing framework choices. Do not introduce or replace a server, UI, persistence,
  serialization, dependency-injection, or logging framework incidentally.

## Kotlin Design

- Prefer immutable values and read-only collection interfaces unless mutation has a clear owner.
- Make nullability explicit and avoid sentinel strings or numbers for missing or invalid state.
- Use data classes for value-oriented data and sealed types or enums for genuinely closed state
  spaces; do not force either pattern where ordinary classes are clearer.
- Use domain-specific value types for identifiers, units, or constrained values when they prevent
  real mistakes, not as ceremony around every primitive.
- Keep functions and classes cohesive. Split code when responsibilities change for different
  reasons or tests require excessive setup.
- Use extension functions for behavior that naturally belongs with a type; avoid using them to hide
  dependencies or global behavior.
- Handle recoverable failures explicitly and preserve useful causes. Do not catch broad exceptions
  merely to return a default value.
- Keep Java interoperability in mind for public APIs: avoid leaking Kotlin-specific constructs when
  Java callers are part of the supported contract.

## Coroutines And Concurrency

- Use structured concurrency and make coroutine ownership and cancellation clear.
- Avoid detached work, unbounded coroutine creation, blocking calls on constrained dispatchers, and
  mutable state shared without an explicit synchronization strategy.
- Inject clocks, ID generators, schedulers, or randomness when behavior must be deterministic.
- Make timeouts, retries, cleanup, and shutdown behavior explicit at I/O boundaries.
- Do not add coroutines to synchronous code unless concurrency or suspension provides a concrete
  benefit.

## Data, Configuration, And External Systems

Apply these rules only when the project has the corresponding boundary:

- Keep database migrations explicit, ordered, reviewable, and compatible with the deployment plan.
- Make transaction boundaries visible and keep network calls out of database transactions unless
  the tradeoff is deliberate.
- Use parameterized database operations and avoid leaking persistence models into stable public
  contracts.
- Keep credentials and environment-specific values outside source control. Validate configuration
  early and report missing values without exposing secrets.
- Design asynchronous consumers for the delivery guarantees the system actually provides, including
  duplicate delivery or retry behavior where applicable.
- Bound queues, retries, payloads, and concurrent external calls; use explicit timeouts.

## Contracts And Compatibility

- Treat public Kotlin APIs, Java-facing APIs, serialized data, configuration keys, command-line
  interfaces, and service endpoints as contracts when downstream users depend on them.
- Prefer additive evolution and intentional deprecation over silent breaking changes.
- Keep one source of truth for generated schemas, clients, or bindings and verify generated output.
- Test serialization, API compatibility, and cross-module or cross-language behavior where those
  boundaries exist.

## Testing

Choose tests that match the project shape:

- focused unit tests for behavior and edge cases;
- parameterized tests for meaningful input combinations;
- coroutine tests with controlled scheduling and time;
- boundary tests for parsing, serialization, configuration, and error mapping;
- integration tests for databases, files, processes, networks, or frameworks when used;
- compatibility tests for public libraries and generated contracts;
- regression tests for every fixed defect when practical.

Keep tests deterministic and independent by default. Do not require live external services unless
the test is explicitly an integration or end-to-end check.

## Verification

Run the smallest reliable checks for the changed module, then the broader repository gate:

```sh
{{KOTLIN_FORMAT_COMMAND}}
{{KOTLIN_TEST_COMMAND}}
{{KOTLIN_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
