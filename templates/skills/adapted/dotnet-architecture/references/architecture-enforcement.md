# Architecture Enforcement

Use this reference when adding or reviewing mechanical checks for .NET architectural boundaries.

## Protect Invariants, Not A Diagram

Write down the small set of rules whose violation would create real coupling. Typical examples:

- domain code must not depend on delivery, persistence, or vendor SDK assemblies;
- application code may depend on domain but not concrete infrastructure;
- modules may communicate only through declared contracts;
- outer adapters may be referenced only by the composition root and adapter tests;
- project references must remain acyclic;
- internal implementation namespaces must not be consumed across module boundaries.

Avoid tests that assert every class suffix, directory, or fashionable pattern. Such tests create work
without protecting behavior.

## Select An Enforcement Level

Prefer the simplest reliable mechanism already supported by the repository:

1. project references and `internal` visibility;
2. solution filters or build entrypoints that compile boundary projects independently;
3. analyzer rules and forbidden-reference configuration;
4. architecture-test libraries that inspect assembly dependencies and types;
5. a small repository script for project-graph invariants;
6. review-only guidance for low-value boundaries.

Do not add an architecture-test package merely to duplicate what the compiler already proves. Add
one when namespace/type relationships or forbidden transitive dependencies cannot otherwise be
expressed clearly.

## Test Design

- Name the architectural reason in the test and failure message.
- Scope rules to owned assemblies and namespaces. Exclude generated, migration, proxy, and test code
  only when their semantics genuinely differ.
- Assert both positive ownership and important forbidden dependencies when one-sided tests could pass
  vacuously.
- Fail clearly if the assembly or namespace under test disappears; an empty scan must not look green.
- Keep exception lists short, attributed, and time-bounded.
- Run architecture tests in the normal CI gate, not only in an optional suite.

Example rule inventory (adapt to the repository; this is not library-specific code):

```text
Domain:
  may depend on: BCL, approved domain primitives
  must not depend on: Application, Infrastructure, Delivery, EF Core, ASP.NET Core

Application:
  may depend on: Domain, application contracts
  must not depend on: concrete Infrastructure, Delivery

Infrastructure:
  may depend on: Domain, Application ports, provider libraries

Delivery/Host:
  may depend on: Application, contracts, composition installers
  concrete adapters are visible only to composition
```

## Project Graph Review

For every changed `.csproj`:

- inspect added and removed `ProjectReference` and `PackageReference` entries;
- determine whether the reference is required at compile time or only by the host/composition root;
- check `PrivateAssets`, analyzer, generator, and build-asset behavior;
- build the affected project independently where supported;
- inspect the transitive effect on downstream projects and published packages;
- detect cycles and outer-to-inner leaks hidden through shared projects.

Central package management controls versions, not architectural permission. A package present in
`Directory.Packages.props` is not automatically valid in every layer.

## Test Pyramid Across Boundaries

- Domain tests prove invariants without infrastructure.
- Application tests prove orchestration with controlled ports.
- Port contract tests define adapter semantics.
- Infrastructure tests prove provider behavior, migrations, and resource handling.
- Functional tests prove transport mapping and production composition.
- Architecture tests prove dependency constraints.

No one test level substitutes for all others. In particular, a functional test can pass while the
dependency graph degrades, and an architecture test can pass while transaction semantics are wrong.

## Verification Report

Include the enforced invariant, mechanism, scope, exceptions, CI command, and a demonstration that
the check fails for a representative violation when a new guard is introduced. If the project lacks
a practical enforcement mechanism, document the manual review boundary and why automation is not yet
worth its cost.
