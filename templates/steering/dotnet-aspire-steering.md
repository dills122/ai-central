# .NET Aspire Steering

## Scope And Enforcement

Use this guidance for Aspire AppHost, ServiceDefaults, integrations, and tests under
`{{ASPIRE_ROOT}}`, together with the C# and .NET steering. Replace placeholders before enforcement;
repository-specific and closer-scoped guidance takes precedence.

## Application Model And Resource Relationships

- Treat the AppHost as the code-first declaration of resources and relationships for development and
  deployment generation. Keep names, endpoints, references, volumes, and lifecycle dependencies stable.
- Express dependencies with Aspire references and wait relationships instead of duplicating connection
  strings or startup polling in application code.
- Keep resource names and endpoint contracts environment-independent where possible. A rename can
  change configuration and deployment identities and requires migration review.
- Do not place product behavior or runtime request handling in the AppHost.

## Service Defaults And Application Configuration

- Keep ServiceDefaults focused on genuinely shared service discovery, resilience, health, and
  OpenTelemetry setup. Do not turn it into a general application framework or dependency grab bag.
- Preserve explicit opt-in where a default is unsafe for a worker, client, library, or non-HTTP process.
- Validate required configuration at startup and use typed options where established.
- Configure service-to-service clients from discovery-aware endpoints; do not hardcode local ports or
  container hostnames in application code.

## Resources, Secrets, And Environment Boundaries

- Use parameters or the repository secret mechanism for credentials and sensitive configuration.
  Never commit generated secrets, dashboard tokens, connection strings, or deployment credentials.
- Treat development containers and executable resources as replaceable dependencies with bounded
  data and explicit persistence. Do not infer production durability, security, scaling, or availability
  from local orchestration behavior.
- Pin and align Aspire hosting, integrations, workload/templates, and deployment tooling according to
  repository policy; review integration packages as executable infrastructure code.
- Generated manifests and deployment artifacts must be reviewed for secrets, public exposure,
  persistence, health, identity, and environment-specific assumptions before use.

## Health, Resilience, And Observability

- Define health checks that match resource readiness and use wait relationships only for real startup
  dependencies. Avoid dependency chains that prevent partial availability without necessity.
- Keep resilience policies bounded and align them with request deadlines and operation idempotency.
- Preserve trace context and stable resource attributes across services. Keep metric dimensions bounded
  and secrets or personal data out of logs, traces, and dashboard-visible configuration.
- Do not add duplicate framework/OpenTelemetry instrumentation when ServiceDefaults already supplies it.

## Testing And Quality Gates

- Test AppHost startup, resource discovery, references, health, and required dependencies with the
  Aspire testing host or repository integration fixture.
- Keep integration tests bounded, isolated, and responsible for shutting down resources and cleaning
  test-owned durable data.
- Validate generated deployment output separately from local orchestration. Local success does not
  prove production identity, networking, secret, storage, scaling, or recovery behavior.
- Exercise missing configuration, unavailable dependencies, restart, and graceful shutdown paths.

## Verification

Run the shared .NET gate plus the Aspire checks:

```sh
{{ASPIRE_APPHOST_TEST_COMMAND}}
{{ASPIRE_INTEGRATION_TEST_COMMAND}}
{{ASPIRE_MANIFEST_COMMAND}}
{{ASPIRE_DEPLOYMENT_VALIDATION_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
