# Feature Change Map

Use this reference to implement or review a feature that crosses .NET architectural boundaries.

## Map Before Editing

Write a compact change map. Use `none` rather than manufacturing work for a layer.

| Concern | Existing authority | Required change | Contract/risk | Verification |
| --- | --- | --- | --- | --- |
| Delivery input/output | route, message, CLI, worker | | compatibility and validation | contract/functional test |
| Application use case | command/query/handler/service | | authorization, orchestration, cancellation | unit/component test |
| Domain policy | aggregate/value/policy/service | | invariant and state transition | domain unit/property test |
| Port | repository/client/publisher/clock | | semantics and failure model | contract test |
| Adapter | EF/client/broker/filesystem | | translation, timeout, resource ownership | integration test |
| Composition | startup/DI/module registration | | lifetime and configuration | host smoke test |
| Data | mapping/schema/migration/read model | | compatibility and rollout | provider/migration test |
| Operations | logs/traces/metrics/health/runbook | | diagnosis and bounded telemetry | telemetry/health assertion |

## Design The Contracts

- Keep transport DTOs at the delivery boundary. Map them to application/domain types deliberately.
- Give a use case an explicit success and failure vocabulary. Preserve not-found, invalid, forbidden,
  conflict, cancellation, dependency failure, and unexpected failure distinctions where applicable.
- Define ports from caller needs, including cancellation, timeouts, pagination, idempotency, and
  consistency. Avoid generic CRUD interfaces that erase required semantics.
- Keep queries bounded: explicit projection, ordering, filters, and page/stream limits.
- Define one commit owner for a command. Hidden commits make transactions and failure recovery
  impossible to reason about.

## Domain And Event Decisions

For each state-changing rule, identify:

- the aggregate or policy that owns it;
- facts required to decide it;
- the valid transition and rejected states;
- concurrency behavior;
- events produced and when they become observable.

For each event, classify it:

- domain event inside one process/transaction boundary;
- application notification for in-process follow-up;
- integration event intended for another component or service.

Then specify dispatch timing, durability, ordering requirements, retries, duplicate handling, and
failure recovery. A handler invoked after `SaveChanges` can still fail after the database committed;
an external side effect needs durable coordination when losing it is unacceptable.

## Data Access Decisions

- Use an aggregate repository when loading and saving a consistency boundary through domain behavior.
- Use a direct query service/read model for read-only projections when it is clearer and more
  efficient. Do not hydrate an aggregate solely to return a list DTO.
- Keep EF Core entities as domain entities only when the mapping does not force persistence concerns
  into business policy. Otherwise map at the adapter boundary.
- Review transaction scope, optimistic concurrency, generated SQL, indexes, migration rollout, and
  mixed-version compatibility for the affected path.
- Test against the supported provider. In-memory or alternate-provider tests can be fast feedback but
  do not establish provider correctness.

## Review For Boundary Smells

- domain/application code imports ASP.NET Core, EF Core, or vendor SDK types;
- endpoints contain state transitions or transaction policy;
- handlers are mapping pass-throughs created only to satisfy ceremony;
- repositories expose `IQueryable` across the port;
- one generic service/repository owns unrelated capabilities;
- DI is resolved inside business logic;
- domain events are used as an implicit distributed transaction;
- validation exists only at the UI/endpoint;
- exceptions are flattened into one failure or leaked to transport;
- tests replace so much production wiring that the composition root is untested;
- environment variables, fixed ports, or shared databases make tests order-dependent;
- every feature touches every layer even when no behavior exists there.

## Completion Evidence

Report:

- the before/after boundary and dependency map;
- decisions and alternatives rejected;
- contracts changed and compatibility treatment;
- transaction/event semantics;
- tests at each affected boundary;
- exact commands and results;
- remaining operational or migration risks.
