# OpenTelemetry For .NET Steering

## Scope And Enforcement

Use this guidance for .NET telemetry code under `{{OTEL_DOTNET_ROOT}}`, together with the C# and .NET
steering. Replace placeholders before enforcement; repository-specific signal ownership, naming, and
privacy rules take precedence.

## Signal Ownership And Configuration

- Decide which traces, metrics, and logs are produced by framework instrumentation, libraries,
  application instrumentation, and the hosting platform. Do not instrument the same operation twice.
- Libraries should depend on telemetry APIs and emit neutral signals; applications own SDK providers,
  processors, sampling, readers, exporters, and environment-specific endpoints.
- Create long-lived `ActivitySource` and `Meter` instances with stable names and versions. Do not create
  them per request or per measurement.
- Configure exporters, sampling, batch limits, timeouts, and resource attributes externally where
  practical. Keep local console exporters and verbose diagnostics out of production defaults.

## Traces, Metrics, And Logs

- Follow stable OpenTelemetry semantic conventions for standard operations; introduce custom names
  only where no standard applies and document their meaning and unit.
- Create spans only around meaningful operations. Set status for actual failures and preserve context
  across async, queue, and RPC boundaries without inventing parentage.
- Select the correct metric instrument and aggregation for the quantity. Record canonical units and
  avoid duplicate counters that disagree with framework signals.
- Use structured logs and trace correlation supplied by the logging pipeline. Do not copy trace IDs
  into metric attributes; use exemplars when supported.
- Record exceptions once at the layer that owns the failure signal; avoid duplicate events and logs.

## Cardinality, Privacy, And Cost

- Metric attributes must come from bounded vocabularies. Never use user IDs, request IDs, trace/span
  IDs, raw URLs, SQL, exception messages, arbitrary tenant IDs, or other unbounded values.
- Normalize routes and operation names before attaching them. Bound span events and log volume on
  loops, retries, streams, and attacker-controlled failures.
- Keep credentials, tokens, cookies, message bodies, query values, personal data, and sensitive
  business values out of all telemetry unless an approved classification and redaction policy exists.
- Review sampling and retention together with incident needs and cost; errors and rare workflows may
  need deliberate policies rather than globally maximal collection.

## Export, Shutdown, And Failure Isolation

- Telemetry export must not become a correctness dependency for request processing.
- Bound exporter queues, batches, memory, retry, and shutdown flush time. Make dropped telemetry and
  exporter failures observable without recursive logging.
- Use OTLP transport, TLS, authentication, and endpoint configuration appropriate to the environment.
  Do not disable certificate validation or embed collector credentials.
- Ensure hosted providers flush on graceful shutdown while accepting that crashes can lose buffered data.

## Testing And Quality Gates

- Use in-memory exporters/listeners to assert important span names, relationships, tags, metric units,
  bounded dimensions, log correlation, and error behavior.
- Test context propagation across HTTP, gRPC, messaging, and background work that the service uses.
- Add a smoke test against the configured collector path for deployment-sensitive changes.
- Verify that sensitive fixtures and high-cardinality values do not appear in exported signals.

## Verification

Run the shared .NET gate plus telemetry checks:

```sh
{{OTEL_DOTNET_TEST_COMMAND}}
{{OTEL_DOTNET_SIGNAL_CONTRACT_COMMAND}}
{{OTEL_DOTNET_COLLECTOR_SMOKE_COMMAND}}
{{OTEL_DOTNET_PRIVACY_CHECK_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
