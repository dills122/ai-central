# .NET Clean Architecture Steering

## Scope And Enforcement

Use this guidance for `{{DOTNET_ARCHITECTURE_ROOT}}` only when the repository has deliberately
adopted Clean Architecture, ports and adapters, onion architecture, dependency-inverted layers, or
an equivalent vertical-slice design. Use it together with the C# and .NET steering and any applicable
ASP.NET Core or EF Core steering.

This profile governs dependency direction and ownership, not folder names or a mandatory number of
projects. Preserve repository-specific architecture decisions and replace every placeholder before
enforcement. Do not introduce Clean Architecture as an incidental refactor during unrelated work.

## Architecture Fitness And Boundaries

- Start from the system's business capabilities, change patterns, deployment shape, and team
  ownership. Projects and abstractions must protect a real boundary, not merely resemble a template.
- Keep a simple application or feature in one project when namespaces, folders, and tests provide
  sufficient separation. Extract a project or module when independent compilation, dependency
  enforcement, ownership, reuse, or replacement value justifies the cost.
- Model dependency direction explicitly. Business policy must not depend on ASP.NET Core, EF Core,
  message brokers, cloud SDKs, file systems, email providers, or other delivery/infrastructure details.
- The composition root may reference concrete adapters in order to wire the application. That is an
  intentional outer-layer responsibility, not permission for business code to resolve dependencies.
- Avoid project-reference cycles, layer-skipping shortcuts that expose implementation types, and a
  shared/common project that becomes an unowned dependency magnet.
- Record material boundary decisions and exceptions in `{{ARCHITECTURE_DECISION_LOCATION}}`.

## Domain And Business Rules

- Put business invariants and state transitions with the model that owns them. Do not leave required
  rules only in endpoints, validators, persistence configuration, or UI code.
- Keep aggregates no larger than the consistency boundary requires. Mutate aggregate state through
  behavior that preserves invariants; avoid public setters and externally mutable collections.
- Use entities, value objects, domain services, specifications, and domain events only where their
  semantics improve the model. Do not turn every primitive into a type or every operation into a
  pattern ceremony.
- Keep domain errors explicit and meaningful. Distinguish invalid input, business rejection, missing
  data, conflicts, cancellation, dependency failure, and unexpected defects.
- Inject or pass time, identifiers, randomness, and external facts when business decisions depend on
  them. Domain tests must not depend on ambient clocks, global state, or live services.
- Keep domain types serialization- and persistence-agnostic unless the repository has deliberately
  accepted that coupling and protects it with compatibility tests.

## Application Use Cases And Vertical Slices

- Organize application behavior around user- or system-visible use cases. A slice should make its
  request, policy, dependencies, result, and tests easy to locate together.
- Commands own state-changing workflows and an explicit commit boundary. Queries may use optimized
  read models or direct projections; they need not pass through an aggregate repository when no
  domain behavior is involved.
- Keep handlers focused on orchestration. Business decisions belong in the domain or an explicitly
  named application policy; transport mapping and provider details belong at adapters.
- Pass cancellation through application ports. Define timeout, retry, idempotency, and duplicate
  handling at the boundary that owns them rather than hiding them in generic handlers.
- Add mediator, CQRS, pipeline, or repository abstractions only when they provide a real seam or
  policy. Do not require an interface for every class or a message for every local method call.
- Cross-cutting behaviors must preserve ordering and semantics. Authentication, authorization,
  validation, transactions, retries, caching, logging, and metrics are not interchangeable wrappers.

## Ports, Adapters, And Composition

- Define a port near the policy that needs it and in terms of that policy's language. Do not leak
  `DbContext`, `IQueryable`, HTTP clients, SDK response types, or provider exceptions through inward
  interfaces.
- Keep adapters responsible for translating between external contracts and application/domain types,
  including error, cancellation, pagination, and consistency semantics.
- Register concrete adapters in a composition root or a narrowly scoped installer. Fail startup on
  missing required configuration without logging secrets.
- Keep DI lifetimes aligned with resource ownership. Do not capture scoped dependencies in singletons
  or use a service locator inside domain/application code.
- Replace adapters in tests at the outer boundary. Do not reshape the core model merely to make a
  mocking framework convenient.

## Data, Transactions, And Events

- Treat an aggregate repository as a persistence port for an aggregate consistency boundary, not as
  a universal query API. Keep query projections explicit and bounded.
- Make transaction and save points visible in the use case. Do not call `SaveChanges` from mapping,
  validation, property access, or unrelated event handlers.
- Dispatching an in-process domain event before or after a database save does not make external side
  effects atomic. Use an outbox, inbox/deduplication, saga, or another durable design when a workflow
  crosses transactional resources.
- Document whether domain events run before commit, after commit, or asynchronously. Tests must cover
  handler failure, retries, duplicates, ordering assumptions, and event clearing.
- Keep migrations and provider-specific mappings in infrastructure. Verify migrations and important
  queries against the supported database provider; `EnsureCreated` alone is not migration proof.
- Prevent application and domain layers from acquiring persistence dependencies through convenience
  extension methods, shared base classes, or generated types.

## Delivery And Contract Boundaries

- Keep HTTP, RPC, messaging, CLI, and worker entrypoints thin: validate and map input, invoke one
  application capability, and map its result to the delivery contract.
- Transport DTOs, status codes, headers, message schemas, and error envelopes are compatibility
  contracts. Do not expose persistence entities, domain events, or internal exceptions directly.
- Perform syntactic and trust-boundary validation at delivery adapters; enforce business invariants
  in the domain/application boundary even when an outer validator already rejected bad input.
- Keep authorization close to the protected resource and re-check rules that depend on current
  domain state inside the use case.
- Preserve the repository's established endpoint and message-handler style. Do not introduce a second
  framework or organizational convention as part of an ordinary feature.

## Change Design And Evolution

- Trace each feature through the minimum necessary path: contract, application use case, domain
  policy, port, adapter, composition, persistence/migration, and tests. Omit layers that have no role.
- Prefer a vertical change that leaves the repository working over speculative horizontal framework
  building. Add shared abstractions only after stable common semantics are demonstrated.
- Keep public and cross-boundary contracts backward compatible or version and migrate them
  deliberately. Coordinate database expand/migrate/contract changes with mixed-version deployment.
- When moving code between boundaries, update project references, namespaces, DI registration,
  serialization metadata, tests, documentation, and architecture guards in the same change.
- Delete template examples and unused abstractions once their teaching role is over. Sample code must
  not become accidental production policy.

## Architecture Enforcement

- Express allowed project references and forbidden framework dependencies in architecture tests or
  an equivalent repository check. At minimum, protect the domain/application boundary from outer
  projects and detect project-reference cycles.
- Test architecture by semantics as well as names. Namespace tests are useful only when namespaces
  accurately represent ownership.
- Keep exceptions narrow, documented, and reviewable. A broad dependency-test exclusion is not an
  acceptable substitute for resolving a boundary violation.
- Review architecture tests when adding source generators, shared contracts, test utilities, or new
  adapters so generated and test-only dependencies do not create misleading results.

## Testing And Quality Gates

- Unit-test domain invariants and application policies without hosting or real infrastructure.
- Use contract tests for each port whose semantics matter, then run the same contract against the
  production adapter where practical.
- Integration-test database mappings, migrations, transactions, external clients, queues, and event
  publication with realistic implementations and bounded infrastructure.
- Functional tests must exercise delivery mapping, authentication/authorization, validation, error
  translation, and the application wiring through the real composition root.
- Test failure paths: cancellation, conflicts, timeouts, handler failure, duplicate delivery, partial
  work, and unavailable dependencies. Provider fallbacks must not silently turn a required
  provider-specific gate into a weaker test.
- Keep tests parallel-safe. Avoid process-wide environment mutation, shared databases, fixed ports,
  and static mutable fixtures unless isolation and cleanup are explicit.

## Verification

Run the shared .NET gate plus architecture-specific checks:

```sh
{{DOTNET_ARCHITECTURE_TEST_COMMAND}}
{{DOTNET_DOMAIN_TEST_COMMAND}}
{{DOTNET_ADAPTER_CONTRACT_TEST_COMMAND}}
{{DOTNET_FUNCTIONAL_TEST_COMMAND}}
{{DOTNET_MIGRATION_TEST_COMMAND}}
```

Also inspect the changed project-reference graph and dependency registrations. Report exact commands
and results; if a boundary or realistic-infrastructure check cannot run, state the unverified
invariant and remaining risk.
