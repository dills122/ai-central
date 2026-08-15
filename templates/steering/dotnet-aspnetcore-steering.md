# ASP.NET Core Steering

## Scope And Enforcement

Use this guidance for ASP.NET Core code under `{{ASPNETCORE_ROOT}}`, together with the C# and .NET
steering. Preserve the repository's established endpoint style unless a migration is explicitly in
scope. Replace placeholders before enforcement; closer repository guidance takes precedence.

## HTTP Contracts And Boundaries

- Treat routes, methods, status codes, headers, media types, request/response schemas, and OpenAPI as
  compatibility contracts.
- Bind transport DTOs at the edge and map them to application/domain types. Do not expose EF entities,
  persistence models, secrets, or internal exception details over HTTP.
- Validate type, length, range, encoding, content type, and allowed values before expensive work.
- Use one repository-standard validation and error mapping path. Return consistent Problem Details or
  the established error envelope without leaking stack traces.
- Preserve controller, minimal API, filter, and middleware conventions already used by the project;
  do not introduce a second endpoint architecture incidentally.

## Middleware, Dependency Injection, And Lifecycle

- Keep middleware ordering intentional, especially forwarded headers, exception handling, HTTPS,
  routing, CORS, authentication, authorization, rate limiting, and endpoints.
- Respect DI lifetimes. Never capture scoped services in singletons or resolve services from a global
  service locator.
- Keep startup validation explicit and fail fast for invalid required configuration without printing
  secrets.
- Background services must own cancellation, failure reporting, bounded queues, and graceful shutdown.

## Security And Abuse Resistance

- Require authentication and authorization at the correct resource boundary; do not rely on UI
  visibility or route grouping alone.
- Enforce request-body, upload, form, header, query, decompression, rate, and concurrency limits before
  buffering or parsing attacker-controlled data.
- Apply antiforgery protection to cookie-authenticated state-changing browser requests and constrain
  CORS to named origins, methods, and headers.
- Use framework data-protection, secret storage, TLS, and cookie defaults. Review forwarded-header and
  proxy trust configuration before accepting external scheme, host, or client-address values.
- Do not log credentials, tokens, authorization headers, cookies, sensitive bodies, or personal data.

## Async, Outbound Calls, And Resilience

- Use async I/O throughout request paths and propagate `HttpContext.RequestAborted` when work can stop.
- Do not continue expensive background work after disconnect unless it is durably handed to an owned
  queue with explicit semantics.
- Use `IHttpClientFactory` or the repository's established long-lived client ownership. Do not create
  and discard an `HttpClient` per request.
- Apply timeouts, retries, circuit breaking, and hedging only at understood boundaries. Retry only
  idempotent operations or operations protected by idempotency keys/deduplication.

## Operations And Observability

- Separate liveness from readiness; readiness must reflect only dependencies required to serve the
  advertised workload.
- Use structured logs, traces, and bounded metrics with consistent request correlation. Avoid user IDs,
  raw paths, exception messages, and other unbounded metric dimensions.
- Keep diagnostics, Swagger/OpenAPI UI, detailed errors, and framework introspection appropriately
  restricted by environment and authorization.
- Make shutdown drain behavior, proxy timeouts, request limits, and deployment health checks align.

## Testing And Quality Gates

- Unit-test application policy without hosting where useful.
- Use `WebApplicationFactory` or the repository host fixture for routing, binding, filters, middleware,
  authentication, authorization, error mapping, cancellation, and OpenAPI behavior.
- Test malformed, oversized, unauthorized, forbidden, rate-limited, and dependency-failure cases.
- Add contract or snapshot checks for supported HTTP/OpenAPI surfaces, reviewing intentional changes.

## Verification

Run the shared .NET gate plus the ASP.NET Core checks:

```sh
{{ASPNETCORE_TEST_COMMAND}}
{{ASPNETCORE_INTEGRATION_TEST_COMMAND}}
{{ASPNETCORE_OPENAPI_CHECK_COMMAND}}
{{ASPNETCORE_SECURITY_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
