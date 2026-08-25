# Architecture Selection

Use this reference when deciding whether a .NET application needs full project boundaries, a
modular monolith, a single-project vertical-slice layout, or a focused repair to its current model.

## Start With Forces, Not Labels

Capture:

- business capabilities and invariants that change together;
- current and expected application size, domain complexity, and change rate;
- team ownership and merge/conflict patterns;
- deployment and scaling units;
- external systems and consistency boundaries;
- compatibility commitments and migration constraints;
- current dependency pain demonstrated by code or incidents.

Do not infer a required architecture from endpoint count or entity count alone. Those can be useful
signals, but complexity comes from behavior, coupling, volatility, and ownership.

## Compare Shapes

| Shape | Prefer when | Main cost | Enforcement |
| --- | --- | --- | --- |
| Single-project vertical slices | One deployment, small team, modest domain, fast feature changes | Folder boundaries are easy to bypass | Namespace tests, review, focused component tests |
| Layered multi-project application | Domain/application policy must be insulated from several adapters | More projects, references, mapping, and build overhead | Compiler project graph plus architecture tests |
| Modular monolith | Several business capabilities need ownership and data/API boundaries but deploy together | Cross-module contracts and transactions require discipline | Per-module projects/namespaces, contract tests, dependency rules |
| Ports and adapters around selected features | External technology churn or test seams affect only part of the system | Mixed styles need clear local scope | Ports owned by the policy and adapter contract tests |
| Separate services | Independent deployment/scale/ownership and operational isolation are required | Distributed consistency, latency, operations, and versioning | Network contracts, consumer tests, deployment policy |

Choose a shape per meaningful boundary. A solution can combine a vertical-slice web host, a rich
domain module, and simple CRUD modules without pretending they have identical needs.

## Boundary Decision Questions

For each proposed project, module, or port, ask:

1. What policy or capability does it own?
2. Which dependencies must it be protected from?
3. Who is allowed to call it, and through what contract?
4. What consistency and transaction boundary does it assume?
5. Which change can now occur independently?
6. How will the boundary be tested and mechanically enforced?
7. What mapping and maintenance cost does it add?
8. What evidence would justify merging or splitting it later?

If the answers are only “separation of concerns” or “Clean Architecture says so,” the boundary is not
yet designed.

## Dependency Model

A common multi-project arrangement is:

```text
Domain <- Application <- Delivery
   ^          ^             |
   |          |             |
   +------ Infrastructure <-+
```

The exact project references vary because the outer composition root must see concrete adapters.
The invariant is that business policy does not compile against outer implementation details.

In a single-project shape, use namespaces and feature layout to model the same ownership:

```text
Features/<Capability>/Domain
Features/<Capability>/UseCases
Features/<Capability>/Endpoints
Infrastructure/<Technology>
```

Folder names alone do not enforce dependencies. Add a test or static rule if the boundary matters.

## Migration Strategy

Prefer incremental migration:

1. characterize current behavior with tests;
2. select one high-value seam or feature;
3. define the desired ownership and allowed dependencies;
4. move behavior without simultaneously replacing every framework;
5. adapt callers through a narrow contract;
6. add a mechanical dependency guard;
7. remove the obsolete path;
8. evaluate the result before repeating.

Avoid a flag-day rewrite, a parallel “new architecture” with no migration owner, or widespread
interfaces that preserve the old coupling under new names.
