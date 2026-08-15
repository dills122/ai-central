# Entity Framework Core Steering

## Scope And Enforcement

Use this guidance for EF Core code under `{{EFCORE_ROOT}}`, together with the C# and .NET steering.
The repository model and migrations are the schema authority unless closer instructions say otherwise.
Replace placeholders before enforcement; exceptions require a narrow documented rationale and tests.

## DbContext Ownership And Units Of Work

- Keep each `DbContext` short-lived and owned by one unit of work. Do not use the same context for
  parallel operations or concurrent threads.
- Await each operation before starting another on the context and propagate cancellation tokens.
- Respect scoped lifetime boundaries. Factories and pooling require explicit tenant/state reset rules;
  never leak request-specific state between pooled contexts.
- Keep transactions as short as correctness permits and do not mix retrying execution strategies with
  ad hoc transactions without the provider-supported pattern.

## Models, Queries, And Performance

- Keep persistence mappings explicit for keys, requiredness, lengths, precision, relationships,
  delete behavior, indexes, concurrency, and provider-specific behavior that affects correctness.
- Project only required columns, use `AsNoTracking` for read-only work, and avoid unbounded materialization.
- Detect and prevent N+1 queries. Prefer explicit query shapes over broad `Include` graphs.
- Paginate large result sets with deterministic ordering; prefer keyset pagination for hot deep pages
  when the access pattern permits it.
- Review generated SQL and query plans for performance-sensitive changes. Add or change indexes based
  on measured query needs, not guesswork.
- Use compiled queries, context pooling, split queries, or provider tuning only after measurement and
  with tests for their semantic tradeoffs.

## Writes, Transactions, And Concurrency

- Make write boundaries and commit points explicit. Do not call `SaveChanges` from hidden mapping,
  validation, or property-access code.
- Use optimistic concurrency tokens where lost updates matter and map conflicts to explicit retry,
  merge, or user-visible resolution behavior.
- Treat retryable transactions and message handling as duplicate-prone. Protect external side effects
  with idempotency, an outbox, or another durable coordination design.
- Avoid long transactions across network calls. Never assume an in-memory update and a separate
  external side effect commit atomically.
- Parameterize raw SQL and dynamic fragments through supported APIs. Never concatenate untrusted input
  into SQL, identifiers, or migration commands.

## Migrations And Deployment

- Change the model and migration together. Review every generated migration and model snapshot; do
  not accept destructive operations, provider drift, or accidental table rebuilds blindly.
- Give migration artifacts stable, descriptive names and keep them immutable after deployment unless
  repository policy explicitly permits repair.
- Separate migration generation from production application. Do not apply production migrations or
  execute destructive database commands without explicit operator authorization.
- Design expand/migrate/contract rollouts for mixed application versions and large tables. Backfills
  must be restartable, observable, and bounded.
- Document backup, rollback/roll-forward, lock, timeout, and failure recovery for risky migrations.

## Testing And Quality Gates

- Use unit tests only for persistence-independent policy. Do not treat mocked `DbSet` behavior as proof
  of provider query semantics.
- Test queries, mappings, constraints, transactions, concurrency, migrations, and raw SQL against the
  actual supported provider in bounded integration tests.
- Apply migrations from an empty database and from supported prior snapshots; verify important data
  transformations and rollback/forward recovery.
- Assert query count or inspect SQL for paths vulnerable to N+1 or accidental client-side work.

## Verification

Run the shared .NET gate plus the EF Core checks:

```sh
{{EFCORE_MIGRATION_CHECK_COMMAND}}
{{EFCORE_INTEGRATION_TEST_COMMAND}}
{{EFCORE_QUERY_REGRESSION_COMMAND}}
{{EFCORE_DEPLOYMENT_VALIDATION_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
