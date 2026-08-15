# .NET Orleans Steering

## Scope And Enforcement

Use this guidance for Orleans code under `{{ORLEANS_ROOT}}`, together with the C# and .NET steering.
Repository-specific instructions and closer-scoped steering take precedence. Replace placeholders
before enforcement. Exceptions to **must**, **do not**, and **never** require a documented reason,
narrow scope, and a regression guard.

## Grain Boundaries And Identity

- Model grains around stable identity, isolated state, and cohesive behavior. Do not turn every
  entity into a grain or create chatty call graphs that serialize unrelated work.
- Choose grain key types and canonical formatting deliberately; changing identity rules is a data and
  routing migration.
- Keep grain interfaces small and versionable. Do not expose storage records, provider types, or
  mutable implementation objects across grain boundaries.
- Avoid singleton grains and other hot keys unless the bottleneck is intentional, measured, and
  protected by load tests or partitioning.

## Scheduling, Async, And Reentrancy

- Never block the grain scheduler with `.Result`, `.Wait()`, synchronous network or storage I/O, or
  long CPU work.
- Await Orleans-aware tasks directly in grain code. Do not use `ConfigureAwait(false)` or escape to
  `Task.Run` unless scheduler escape is explicitly required, safe, and tested.
- Keep grains non-reentrant by default. Any `[Reentrant]`, `[AlwaysInterleave]`, or method-level
  interleaving decision must document invariants across every `await` and have concurrency tests.
- Treat request cancellation as cooperative. Propagate Orleans cancellation tokens where supported
  and make state transitions safe if cancellation arrives late.
- Bound fan-out and avoid cyclic grain-call dependencies. Apply time budgets at external boundaries.

## Delivery, Idempotency, And Failure

- Assume Orleans request delivery is at-most-once by default. A retry can create at-least-once
  effects, so retry only operations that are idempotent or protected by durable deduplication.
- Do not assume a timeout proves the callee did no work. Design uncertain outcomes explicitly.
- Preserve stable exception and result semantics across grain contracts; do not leak secrets or
  provider internals in failure payloads.
- Make retry limits, backoff, overload behavior, and duplicate handling observable.

## Persistence And State Evolution

- Await every state read, write, and clear operation. Do not acknowledge durable success before the
  provider confirms it.
- Keep persisted state tolerant of missing fields and older representations. Version migrations and
  test rolling-upgrade and rollback paths with representative stored data.
- Use storage concurrency controls where competing activations or external writers can race. Handle
  conflicts explicitly rather than silently overwriting newer state.
- Keep large or append-heavy data out of a single grain state record when it creates unbounded reads,
  writes, or activation cost.

## Serialization And Contract Compatibility

- Use Orleans-generated serializers for application contracts where possible.
- Assign stable `[Id]` values deliberately. Never reuse removed field IDs or change their meaning.
- Treat aliases, grain interfaces, method signatures, generic constraints, and serialized types as
  rolling-deployment compatibility contracts.
- Use immutability annotations only when the complete reachable object graph is actually immutable;
  callers must not mutate values after sending them.
- Register custom codecs and converters narrowly and test unknown, missing, malformed, and old data.

## Timers, Reminders, Streams, And Lifecycle

- Use timers for activation-local work and reminders for durable scheduling; neither is a general
  real-time scheduler. Make callbacks idempotent and bounded.
- Keep timer, reminder, subscription, and background-task handles owned and cleaned up during
  deactivation or shutdown.
- For streams, document delivery expectations, subscription ownership, ordering, replay, duplicate
  handling, backpressure, and recovery after activation or cluster failure.
- Keep activation startup bounded. Avoid network waterfalls and large state loads in activation hooks.

## Hosting, Deployment, And Observability

- Keep cluster ID, service ID, membership, storage, reminders, and networking configured explicitly
  per environment; never ship development clustering or credentials as production defaults.
- Plan interface and serializer changes for mixed-version silos and clients. Prefer additive rollout
  before removal.
- Use graceful shutdown and readiness/health signals that reflect membership and required providers.
- Emit bounded telemetry for request latency, failures, activation pressure, queues, storage, retries,
  reminders, and stream health without grain IDs or user data as unbounded metric attributes.

## Testing And Quality Gates

- Unit-test grain-local policy separately from Orleans hosting where practical.
- Use `TestCluster` or the repository integration harness for activation, scheduling, persistence,
  reminders, streams, cancellation, reentrancy, and serializer behavior.
- Include multi-silo tests for placement, failover, retries, rolling compatibility, and hot-key risks.
- Use real configured providers in bounded integration tests when provider behavior matters.
- Keep tests deterministic and ensure clusters, clients, subscriptions, and providers shut down.

## Verification

Run the shared .NET gate plus the Orleans-specific checks:

```sh
{{ORLEANS_BUILD_COMMAND}}
{{ORLEANS_TEST_COMMAND}}
{{ORLEANS_MULTISILO_TEST_COMMAND}}
{{ORLEANS_SERIALIZATION_COMPAT_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
