# C# And .NET Steering

## Scope And Enforcement

Use this guidance for C# and .NET code under `{{DOTNET_ROOT}}`.

Repository-specific instructions and closer-scoped steering take precedence. Replace every
placeholder before enforcing this file.

The words **must**, **do not**, and **never** describe default requirements. Exceptions require a
documented reason, narrow scope, and a regression guard. Do not relax compiler, analyzer, test,
compatibility, or security gates merely to make a change pass.

## SDK, MSBuild, And Reproducible Builds

- Honor `global.json`, checked-in tool manifests, target frameworks, `LangVersion`, and repository
  build entrypoints. Do not silently move a project to the newest installed SDK or language version.
- Keep local development, CI, containers, and deployment on compatible supported .NET versions.
- Put shared early defaults in `Directory.Build.props`, late targets in `Directory.Build.targets`,
  and central package versions in `Directory.Packages.props` when the repository uses them.
- Preserve MSBuild evaluation order. Defaults intended to be overridden must be conditional, and
  target-framework-dependent logic must run only after `TargetFramework` is available.
- Extend existing property and target chains instead of replacing them. Custom targets must declare
  inputs, outputs, ordering, and clean behavior when they create artifacts.
- Treat source generators and generated code as a contract: edit the schema or generator,
  regenerate, and verify drift. Do not hand-edit generated files.
- Keep builds deterministic and free of hidden network access or environment-specific absolute paths.

## Formatting, Analyzers, And Warnings

- Follow the repository `.editorconfig`; use `dotnet format` or the configured formatter as a gate.
- Enable nullable analysis for project-owned C# and fix warnings at their source.
- Use the SDK analyzer baseline and repository analyzer configuration. Treat new warnings as errors
  unless a narrower policy is explicitly documented.
- Suppress diagnostics at the smallest practical scope with a reason. Do not add blanket `NoWarn`,
  `WarningsNotAsErrors`, or generated-code exclusions to land a change.
- Remove unused code and imports. Do not retain commented-out implementations or obsolete feature
  branches without an owner and removal condition.

## Projects, APIs, And Maintainability

- Preserve solution and project dependency direction; do not introduce project-reference cycles.
- Keep public APIs narrow and explicit. Prefer `internal` or `private` until a supported consumer
  requires a public contract.
- Treat public types, nullability annotations, exceptions, configuration keys, serialization shapes,
  and NuGet package contents as compatibility surfaces.
- Separate domain behavior from hosting, transport, persistence, serialization, and framework glue.
- Reuse established validators, serializers, clients, resilience policies, and abstractions before
  adding parallel implementations.
- Extract shared code only when behavior and invariants are genuinely the same. Remove obsolete
  paths after migration so one behavior has one authority.
- Avoid service locators, mutable global state, and catch-all `Helpers` or `Utils` areas.

## C# Language And Type Design

- Match the language version selected by the repository. Do not use syntax or BCL APIs unavailable
  on supported targets.
- Make invalid states difficult to represent with focused types, enums, and validated value objects.
- Use nullable reference types honestly; do not silence analysis with `!` unless an invariant is
  proven locally and remains guarded.
- Prefer immutable data and narrow mutation ownership. Do not expose mutable collections or internal
  buffers from supported APIs without an explicit ownership contract.
- Use records for value-oriented data only when their equality, copying, and mutability semantics fit.
- Keep methods cohesive and dependencies explicit. Do not hide I/O or global state behind extension
  methods, implicit conversions, or property getters.
- Use pattern matching and LINQ when they improve clarity; avoid allocation-heavy chains in measured
  hot paths.

## Async, Concurrency, Errors, And Resources

- Use async all the way for asynchronous I/O. Do not call `.Result`, `.Wait()`, or block thread-pool
  threads on tasks.
- Every background task must have a lifecycle owner, failure policy, cancellation path, and observed
  completion. Avoid unowned fire-and-forget work.
- Accept and propagate `CancellationToken` at cancellable boundaries. Cancellation is a normal
  outcome and must not be translated into an unrelated failure.
- Bound concurrency, queues, retries, buffers, and fan-out. Apply explicit timeouts to external I/O.
- Catch only exceptions the current layer can handle or map. Preserve the original exception as the
  inner cause and do not use exceptions for routine branching.
- Dispose `IDisposable` and `IAsyncDisposable` resources deterministically with the correct owner.
- Do not hold locks across `await`; use immutable snapshots, confinement, channels, or an intentional
  synchronization primitive.

## Input, Serialization, And Security

- Treat HTTP/RPC payloads, files, environment variables, configuration, database values, and plugin
  output as untrusted until validated for type, size, range, encoding, and allowed values.
- Bound payloads, decoded output, recursion, collection sizes, decompression, redirects, retries, and
  process output before expensive work or allocation.
- Use parameterized data access and context-appropriate output encoding. Keep secrets out of source,
  logs, exceptions, telemetry, fixtures, and snapshots.
- Do not use `BinaryFormatter`, `NetDataContractSerializer`, LosFormatter, ObjectStateFormatter, or
  unrestricted polymorphic deserialization for untrusted data.
- Treat reflection, dynamic loading, source generators, analyzers, build tasks, native libraries, and
  process execution as privileged boundaries.
- Invoke processes with explicit argument lists and validate paths and executable selection.

## Dependencies And Compatibility

- Prefer the BCL and existing repository dependencies before adding a NuGet package.
- Pin or centrally manage direct dependency versions according to repository policy. Do not use
  floating versions in reproducible paths.
- Commit project, central-version, lock, and generated restore changes together when applicable.
- Review transitive dependencies, licenses, analyzers/build assets, native components, and package
  source mapping before adoption.
- Run NuGet vulnerability auditing and do not suppress an advisory without affected-version analysis,
  a narrow rationale, an owner, and a review/removal condition.
- For published libraries, classify API changes and verify binary/source compatibility and package
  contents. Version breaking changes deliberately.

## Performance And Efficiency

- Measure representative workloads before and after performance-sensitive changes.
- Choose algorithms and data structures with bounded, understood cost; avoid repeated allocation,
  boxing, parsing, reflection, and unnecessary materialization in hot paths.
- Stream or page large data and use bounded pooling only with explicit lifetime and clearing rules.
- Use `Span<T>`, pooling, source generation, compiled expressions, or Native AOT work only when the
  target supports them and evidence justifies their complexity.
- Caches must define keys, invalidation, concurrency behavior, size limits, and observability.

## Testing And Quality Gates

- Add focused unit tests for behavior, edge cases, failure paths, cancellation, and every fixed defect.
- Add integration tests for the actual database, filesystem, process, network, serialization, and
  hosting boundaries changed by the work.
- Keep tests deterministic by controlling time, randomness, IDs, scheduling, and external clients.
- Test supported target frameworks and runtime/OS matrices promised by the repository.
- Do not require live third-party services in the default unit-test gate.
- Restore, formatting, build, analyzers, tests, package validation, and dependency audit must pass in
  CI with no new warnings.

## Verification

Run the smallest relevant checks first, then the complete gate:

```sh
{{DOTNET_RESTORE_COMMAND}}
{{DOTNET_FORMAT_COMMAND}}
{{DOTNET_BUILD_COMMAND}}
{{DOTNET_TEST_COMMAND}}
{{DOTNET_PACK_COMMAND}}
{{DOTNET_API_COMPAT_COMMAND}}
{{DOTNET_AUDIT_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
