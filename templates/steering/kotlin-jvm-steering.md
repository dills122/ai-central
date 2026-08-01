# Kotlin And JVM Steering

## Scope And Enforcement

Use this guidance for Kotlin/JVM code under `{{KOTLIN_ROOT}}`.

Repository-specific instructions and closer-scoped steering take precedence. Replace every
placeholder before enforcing this file.

The words **must**, **do not**, and **never** describe default requirements. Exceptions require a
documented reason, narrow scope, and a regression guard. Do not relax compiler, lint, test,
compatibility, or security gates merely to make a change pass.

## Toolchain And Reproducible Builds

- Use the checked-in Gradle wrapper and verify wrapper upgrades as executable supply-chain changes.
- Pin and keep compatible the Gradle version, Java toolchain, Kotlin compiler, Kotlin language/API
  versions, CI runtime, and deployment runtime.
- Build and test with the declared Java toolchain, not whichever JDK happens to launch Gradle.
- Centralize dependency and plugin versions through the repository's version catalog or established
  dependency-management mechanism.
- Do not introduce dynamic versions, version ranges, changing modules, or `SNAPSHOT` dependencies in
  reproducible build paths.
- Commit dependency locks when the project uses them and enable strict dependency verification for
  external artifacts and plugins where practical.
- Commit manifest, lock, verification-metadata, and generated changes together.
- Keep custom build logic in convention plugins or focused build-logic modules, not copied across
  subprojects.
- New or changed build logic must remain compatible with Gradle's configuration cache unless a
  documented tool limitation prevents it.
- Build tasks must declare inputs and outputs and must not perform hidden work during configuration.
- Treat generated sources as outputs: modify the source schema or generator, regenerate, and verify
  that CI detects drift.

## Compiler, Formatting, And Static Analysis

- Use the official Kotlin coding conventions and one repository formatter configuration.
- Treat compiler warnings as errors for project-owned source, with narrow documented exceptions for
  generated or compatibility code.
- Run the repository's Kotlin linter/static analyzer in CI; do not add project-wide suppressions.
- A suppression must be placed on the smallest declaration or expression and explain why the rule
  does not apply.
- Remove unused code and imports. Do not retain commented-out implementations or compatibility paths
  without a documented removal plan.
- Keep the build free of deprecation warnings introduced by new code.

## Modules, Visibility, And DRY

- Preserve intentional module direction and do not introduce cyclic project dependencies.
- Keep public APIs narrow. Default implementation details to `private` or `internal`.
- For published APIs, specify visibility and return/property types explicitly and document public
  behavior with KDoc.
- Keep packages cohesive and avoid catch-all `util`, `helpers`, or `common` areas with unrelated code.
- Separate core computation and policy from framework, serialization, persistence, and I/O adapters.
- Keep application entrypoints and adapters focused on mapping inputs, invoking behavior, and mapping
  results.
- Reuse an existing parser, validator, serializer, client, retry policy, or configuration loader
  before adding another implementation.
- Extract shared code when behavior and invariants are genuinely identical and copies could drift;
  do not add abstractions solely to eliminate similar syntax.
- Remove the obsolete path after migration; two authoritative implementations are not acceptable.
- Do not introduce or replace a server, persistence, serialization, DI, or logging framework as an
  incidental part of another change.

## Kotlin Language Design

- Default to `val` and read-only collection interfaces. Mutation must have a clear, narrow owner.
- Model absence with nullability, not sentinel strings, magic numbers, or partially initialized data.
- Do not use `!!` unless an invariant is proven locally and documented; prefer validation, `require`,
  `check`, or explicit control flow.
- Avoid unchecked casts and star projections in stable APIs. Validate and narrow unknown data at the
  boundary.
- Use data classes for value-oriented data, sealed types for genuinely closed variants, and value
  classes for identifiers or units when they prevent real mistakes.
- Make `when` expressions exhaustive for closed state.
- Do not expose mutable collections, arrays, builders, or internal implementation types from public
  APIs without an explicit ownership contract.
- Keep extension functions narrow in scope and visibility; do not use them to hide dependencies or
  global side effects.
- Prefer clear loops over long allocation-heavy collection chains in measured hot paths.
- Keep functions cohesive and parameter lists intentional. Introduce a named parameter object only
  when the values form a stable concept, not to hide poor decomposition.

## Errors, Resources, And JVM Boundaries

- Use exceptions for exceptional failures, not routine branching.
- Throw specific exception types with stable meaning and preserve the original cause when translating.
- Catch only failures that can be handled, enriched, or mapped at that layer; otherwise propagate.
- Never catch `Throwable`, `Error`, or broad `Exception` merely to log and continue.
- Do not expose secrets, credentials, tokens, or unnecessary sensitive data in messages or logs.
- Close `AutoCloseable` resources deterministically with `use` or an equivalent structured owner.
- Avoid finalizers and hidden resource ownership. Startup and shutdown must be explicit and testable.
- Treat reflection, annotation processors, compiler plugins, JNI, and deserialization hooks as
  privileged execution boundaries.
- Avoid native Java serialization for untrusted data. If legacy deserialization is unavoidable, use
  restrictive filters and validate reconstructed invariants.
- Keep JNI methods private behind validating Kotlin/Java wrappers, and revalidate on the native side.

## Coroutines And Concurrency

Apply this section whenever the project uses coroutines:

- Use structured concurrency. `GlobalScope` and unowned application scopes are prohibited.
- Every launched coroutine must have a documented lifecycle owner and failure policy.
- Do not hardcode dispatchers in reusable logic; inject dispatchers or keep dispatcher selection at
  the application boundary.
- Never perform blocking I/O on a constrained coroutine dispatcher. Move blocking work through the
  project's explicit blocking boundary.
- Preserve cancellation. Do not swallow `CancellationException`, and make long CPU loops cooperate.
- Use `supervisorScope` or `SupervisorJob` only when sibling failure isolation is an intentional,
  tested requirement.
- Bound concurrency, channels, buffers, retries, and queued work.
- Do not hold locks across suspension. Protect shared mutable state through confinement, immutable
  snapshots, atomic primitives, or an explicitly chosen synchronization mechanism.
- Apply explicit timeouts at external boundaries and make retry safety, backoff, and cancellation
  observable.
- Test coroutine code with controlled dispatchers, virtual time where appropriate, cancellation, and
  failure propagation.

## Input, Configuration, And Security

- Treat network data, files, environment variables, command-line arguments, stored data, and plugin
  output as untrusted until validated for type, length, range, encoding, and allowed values.
- Validate before allocation or expensive processing and again at the security-sensitive use when
  intervening code can alter the value.
- Use overflow-safe arithmetic for sizes, offsets, counters, quotas, and time calculations.
- Bound payloads, decoded output, recursion, collections, queues, retries, and concurrent work.
- Use parameterized database operations and context-appropriate output encoding.
- Keep credentials and environment-specific values outside source control. Validate configuration at
  startup without printing secrets.
- Do not load classes, scripts, templates, JNDI names, native libraries, or executable commands from
  untrusted input.
- Invoke processes with explicit argument lists; do not assemble shell command strings.

## Dependencies And Compatibility

- Add dependencies only after checking the Kotlin/JDK libraries and existing dependency graph.
- Keep dependency scopes accurate; implementation details must not leak through public API scopes.
- Review transitive dependencies, licenses, native components, annotation processors, and plugin
  execution before adoption.
- Treat public Kotlin APIs, Java-facing APIs, serialized formats, configuration keys, CLI contracts,
  and service boundaries as compatibility surfaces.
- Published libraries must run binary/API compatibility validation in `check`.
- Do not assume adding a default parameter preserves JVM binary compatibility. Review generated JVM
  signatures and add deliberate overloads or a versioned migration where required.
- Use `@JvmOverloads`, `@JvmName`, `@JvmStatic`, `@PublishedApi`, and inline public functions only
  after reviewing their binary and Java-interoperability consequences.
- Make breaking changes explicit, versioned, documented, and covered by compatibility fixtures.

## Performance And Efficiency

- Measure performance-sensitive changes with representative inputs before and after modification.
- Choose algorithms and data structures with bounded, understood cost.
- Avoid accidental boxing, repeated parsing/serialization, needless collection copies, regex
  recompilation, and per-item blocking I/O in hot paths.
- Stream or page large data and enforce limits before allocating or decoding it.
- Caches must have explicit keys, invalidation, concurrency behavior, and memory bounds.
- Do not sacrifice clarity for micro-optimizations without profiling evidence.

## Testing And Quality Gates

- Add focused unit tests for behavior, edge cases, failure paths, and every fixed defect.
- Test null, empty, malformed, oversized, overflow, and boundary inputs where applicable.
- Add integration tests for database, filesystem, process, network, framework, or serialization
  boundaries the project actually uses.
- Published libraries must test supported Java/Kotlin compatibility and public API behavior.
- Keep tests deterministic: inject time, randomness, IDs, scheduling, and external clients.
- Do not require live external services in the default unit-test task.
- Formatting, compilation, static analysis, unit tests, and the repository's `check` task must run in
  CI with no new warnings.
- Do not reduce coverage, exclude source sets, or loosen quality thresholds merely to pass a change.

## Verification

Run the smallest relevant checks first, then the full gate:

```sh
{{KOTLIN_FORMAT_COMMAND}}
{{KOTLIN_LINT_COMMAND}}
{{KOTLIN_TEST_COMMAND}}
{{KOTLIN_CHECK_COMMAND}}
{{KOTLIN_API_CHECK_COMMAND}}
{{KOTLIN_DEPENDENCY_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
