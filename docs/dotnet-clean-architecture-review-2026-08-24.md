# Ardalis Clean Architecture Review — 2026-08-24

## Outcome

Use `ardalis/CleanArchitecture` as a strong case study for dependency-inverted .NET applications,
not as a universal project layout or package prescription.

Promoted:

- the explicit `dotnet-clean-architecture` steering profile;
- the `dotnet-architecture` adapted skill in the detected `dotnet` bundle;
- focused references for architecture selection, cross-boundary feature work, and mechanical
  dependency enforcement;
- regression coverage for copy/link installation, direct profile composition, generated APM
  manifests, and exact skill selection.

The profile is deliberately not auto-detected. Project names such as `Core`, `Application`,
`Infrastructure`, or `Web` are too ambiguous to prove that a repository has chosen this architecture.
Teams can select it explicitly after confirming the repository's architectural intent.

## Source Provenance

| Field | Value |
| --- | --- |
| Upstream | `https://github.com/ardalis/CleanArchitecture` |
| Local review clone | `external/ardalis-cleanarchitecture` |
| Commit | `fbdc0951879f5e8dca1bebc273d4b28cb2934469` |
| Commit date | 2026-08-18 |
| License | MIT, copyright Steve Smith |
| Review date | 2026-08-24 |
| Import mode | Substantially adapted guidance; no application/template source code copied |
| Verbatim content | Upstream MIT license copied to `templates/skills/imported/licenses/ardalis-cleanarchitecture-LICENSE` |

The ignored local clone remains available for review but is not vendored. This follows
`docs/external-source-policy.md`.

## Material Reviewed

- root and generated-template READMEs;
- `docs/content/design-decisions.md` and `docs/content/minimal-clean-architecture.md`;
- root and sample GitHub Copilot instructions;
- solution, project, `Directory.Build.props`, `Directory.Packages.props`, and `global.json` files;
- Core, UseCases, Infrastructure, Web, AspireHost, and ServiceDefaults project relationships;
- representative aggregates, value objects, domain services, commands, queries, endpoints,
  repositories, EF Core mappings, event dispatch, and dependency registration;
- unit, integration, functional, Aspire, Testcontainers, and parallel-test material;
- full and minimal template configuration.

## Architecture Evidence

### Full template

The full template demonstrates a useful dependency-inverted shape:

- Core owns domain concepts and inward-facing abstractions;
- UseCases owns commands, queries, handlers, and application policy;
- Infrastructure implements persistence and external-service adapters and references inward projects;
- Web is the delivery and composition boundary;
- test projects are separated by behavior and infrastructure scope.

It also illustrates pragmatic read/write separation: commands use aggregate persistence abstractions,
while queries can use purpose-built query services and projections. Endpoint request/response types
remain at the delivery edge, and the sample exercises domain, use-case, database, and hosted API
tests separately.

### Minimal template

The minimal template is equally important evidence. It retains dependency inversion, testability,
and framework-independent business rules inside a single Web project organized by vertical feature
slices. Mediator, CQRS, repositories, value objects, specifications, and domain services are optional
and introduced only when the application needs them.

This prevents the reusable guidance from equating Clean Architecture with four or more projects.
Compiler-enforced project boundaries and single-project feature cohesion are both valid tools with
different costs.

## Durable Patterns Promoted

- Dependency direction protects business policy from delivery, persistence, and provider details.
- A composition root may see concrete adapters without allowing service location in business code.
- Business invariants belong with the model or policy that owns state transitions.
- Application behavior is easier to change when organized around cohesive use cases or vertical
  slices.
- Commands and queries can use different data access shapes; repositories are not mandatory for
  read-only projections.
- Delivery DTOs, provider models, and domain models should not become one accidental contract.
- Validation has distinct roles at trust/transport boundaries and at business-invariant boundaries.
- Architecture is more durable when important dependency rules are enforced mechanically.
- Unit, adapter/integration, functional, migration, and architecture tests prove different properties.
- Sample abstractions and packages should be deleted or replaced when they no longer serve a real
  production requirement.

## Template-Specific Choices Not Promoted

The reusable output does not require:

- FastEndpoints or the REPR pattern;
- Mediator, CQRS, pipeline behaviors, or one handler per operation;
- Ardalis.Result, GuardClauses, SharedKernel, Specification, or other Ardalis packages;
- Vogen or a value object for every primitive;
- EF Core, SQLite, SQL Server, Aspire, Serilog, or a specific test framework;
- repository abstractions for every table or query;
- a four-project solution or a single-project solution;
- DDD for CRUD-dominant or low-complexity features.

These remain options to preserve when already chosen or adopt when a concrete need justifies them.

## Cautions Added During Adaptation

### Source truth and version policy

At the reviewed commit, `Directory.Build.props` and `global.json` target .NET 10, while one root
README sentence still says the main branch uses .NET 9. Reusable guidance therefore treats checked-in
build configuration as the version authority and avoids hardcoding the newest SDK or framework.

### Domain purity is a spectrum

The upstream Core project has several package dependencies, including mediator, logging abstraction,
and Ardalis components. This can be a reasonable tradeoff, but “framework independence” should be
tested as the repository actually defines it rather than assumed from the project name.

### Events and transactions

The template includes EF Core post-save domain-event dispatch. A database commit followed by handler
execution can still leave committed state when a handler or external side effect fails. The promoted
guidance requires explicit pre/post/asynchronous semantics and durable outbox/inbox or equivalent
coordination when cross-resource reliability matters.

### Provider-realistic tests

Functional tests can fall back from SQL Server Testcontainers to SQLite, and they use
`EnsureCreated`. That is useful developer feedback but is not proof of SQL Server behavior or EF
migration correctness. Required provider and migration gates must fail clearly rather than silently
weakening their evidence.

### Parallel test isolation

Process-wide environment-variable changes, shared databases, and fixed resources can make tests
order-dependent. The reusable profile makes resource isolation, cleanup, and parallel safety
explicit.

### Documentation and code examples

The upstream repository correctly describes itself as a starter rather than a reference application.
Promoted guidance therefore treats examples as disposable teaching material and avoids converting
sample naming, dependencies, or shortcuts into universal policy.

## Reusable Design

### Steering

`templates/steering/dotnet-clean-architecture-steering.md` is durable policy for repositories that
have deliberately selected the style. It composes with `dotnet-csharp` and any framework profiles but
does not activate them automatically.

### Skill

`templates/skills/adapted/dotnet-architecture/` handles task-oriented work:

- select a proportionate architecture from concrete forces;
- map an end-to-end feature across only the boundaries it needs;
- design ports, transactions, events, and error semantics;
- enforce project/type dependencies and verify each boundary at the appropriate test level.

The skill is included in the detected `dotnet` bundle. Its activation description excludes local C#
edits whose ownership is already clear, limiting context noise.

## Validation Requirements

- The new skill must pass the Codex skill validator with no scaffold placeholders.
- Every explicit `dotnet-clean-architecture` scaffold must also install `dotnet-csharp` and no
  unrelated .NET specialist profile.
- Automatic .NET detection must not infer Clean Architecture from generic project names or package
  references.
- The `dotnet` bundle and its APM package must include `dotnet-architecture` while exact inclusion,
  exclusion, link sync, and non-overwriting behavior remain valid.
- The full repository check must pass.
