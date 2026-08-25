---
name: dotnet-architecture
description: Assess, design, implement, or review architectural boundaries in a .NET application using Clean Architecture, ports and adapters, onion architecture, modular monolith, or vertical slices. Use when a task changes project dependencies, domain/application/infrastructure ownership, use-case flow, repositories or query models, domain events, composition roots, or architecture tests. Do not use for a local C# edit whose boundary ownership is already clear.
---

# .NET Architecture

Preserve useful dependency boundaries while minimizing ceremony. Treat architecture as a set of
testable ownership and dependency decisions, not a required folder diagram or package list.

## Establish The Existing Contract

1. Read repository instructions, architecture decisions, solution/project files, shared MSBuild
   configuration, composition roots, representative features, and tests.
2. Map project references and important package dependencies. Identify which code owns business
   policy, application orchestration, delivery contracts, persistence, and external integrations.
3. Trace one comparable feature end to end before proposing a new pattern.
4. State whether the task preserves the existing architecture, repairs a violation, or deliberately
   changes the model. Do not smuggle an architectural migration into an ordinary feature.

For an architecture assessment or redesign, read
[references/architecture-selection.md](references/architecture-selection.md). For an implementation
or review that crosses boundaries, read [references/feature-change-map.md](references/feature-change-map.md).
For dependency and test enforcement, read
[references/architecture-enforcement.md](references/architecture-enforcement.md).

## Choose The Smallest Honest Boundary Model

- Keep a single project with feature folders when compile-time separation would cost more than it
  protects. Use projects or modules when independent compilation, dependency enforcement, ownership,
  replacement, or deployment value justifies them.
- Preserve inward dependency direction: business policy should not require delivery frameworks,
  persistence, cloud SDKs, or external service implementations.
- Let the outer composition root reference concrete adapters in order to wire them. Do not use DI
  resolution as an inward dependency escape hatch.
- Define ports from the needs of the owning policy and in domain/application language. Avoid leaking
  `DbContext`, `IQueryable`, SDK results, or transport DTOs inward.
- Keep vertical slices cohesive. A feature need not touch every layer, and a shared abstraction needs
  demonstrated common semantics rather than similar spelling.

## Implement Behavior Through The Boundaries

- Put state invariants and transitions in the domain model or an explicitly named policy.
- Keep application handlers focused on orchestration, authorization that depends on current state,
  transaction boundaries, and result semantics.
- Keep delivery adapters focused on transport validation/mapping and infrastructure adapters focused
  on external translation and resource ownership.
- Use repositories for aggregate persistence where they add a meaningful boundary. Queries may use
  direct, bounded projections or read models.
- Treat domain events as facts inside a boundary. If work crosses transactional resources, define
  durable publication, idempotency, retry, and duplicate behavior; in-process dispatch is not an
  atomic integration guarantee.
- Preserve cancellation, error categories, compatibility, and observability as data crosses ports.

Do not introduce a mediator, CQRS framework, repository abstraction, specification library, result
wrapper, endpoint framework, mapping layer, or value-object generator solely to make the repository
look architectural. Reuse established choices or justify a new dependency from a concrete need.

## Verify The Result

1. Unit-test domain invariants and application policy independently of hosting and external I/O.
2. Contract-test ports and production adapters where boundary semantics matter.
3. Integration-test persistence, migrations, transactions, queues, and external clients realistically.
4. Functional-test the composition root and delivery behavior for the changed path.
5. Run architecture checks for allowed project references, forbidden dependencies, and cycles.
6. Run the repository's normal format, build, analyzer, and test gates.

Report the resulting boundary map, decisions made, files changed, exact verification commands and
results, and any boundary that remains unverified.

## Attribution

Substantially adapted from architectural patterns and cautions reviewed in
[`ardalis/CleanArchitecture`](https://github.com/ardalis/CleanArchitecture), commit
`fbdc0951879f5e8dca1bebc273d4b28cb2934469`, MIT license. This skill generalizes the upstream full
and minimal templates, removes framework/package mandates, and adds explicit transaction,
architecture-enforcement, test-isolation, and evolutionary-design guidance.
