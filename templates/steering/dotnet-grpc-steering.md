# gRPC For .NET Steering

## Scope And Enforcement

Use this guidance for gRPC and Protocol Buffers under `{{GRPC_DOTNET_ROOT}}`, together with the C# and
.NET steering. Treat `.proto` files as source contracts and generated C# as output. Replace
placeholders before enforcement; closer repository guidance takes precedence.

## Protobuf Contracts And Compatibility

- Change `.proto` files, regenerate, and review generated/API drift. Never hand-edit generated clients,
  messages, descriptors, or service bases.
- Keep field numbers and meanings stable. Reserve removed field numbers and names; never reuse them.
- Prefer additive fields and methods. Removing fields, changing types/numbers, renaming packages or
  services, changing streaming shape, or tightening previously optional behavior requires a versioned
  compatibility plan.
- Choose presence deliberately with messages, `optional`, wrapper types, or `oneof`; do not overload
  default scalar values when absence has business meaning.
- Treat enums as open to unknown numeric values across versions. Keep zero as a safe unspecified value
  and make consumers tolerate future values.
- Bound repeated fields, maps, strings, bytes, nesting, and decoded message size before expensive work.

## Service Boundaries And Errors

- Keep RPC methods cohesive and transport messages separate from domain and persistence models.
- Validate authorization and resource access per method and object; authentication alone is not enough.
- Map expected failures to stable gRPC status codes and approved structured details. Do not expose stack
  traces, provider errors, secrets, or sensitive data in status text or metadata.
- Use interceptors for genuinely cross-cutting behavior such as correlation, auth enforcement, and
  telemetry; keep business decisions in services.
- Constrain reflection and diagnostic services by environment and authorization.

## Deadlines, Cancellation, And Retries

- Clients must set realistic deadlines; gRPC has no universal default deadline. Propagate the effective
  deadline and cancellation through downstream calls and application/storage work.
- Servers must observe `ServerCallContext.CancellationToken` and stop work where safe. Treat late
  cancellation and uncertain completion explicitly.
- Configure retries centrally with bounded attempts, backoff, retryable status codes, and the overall
  deadline. Retry only idempotent operations or operations protected by durable deduplication.
- Never retry merely because an `RpcException` occurred; committed calls and streaming calls have
  distinct retry semantics.

## Clients, Channels, Streaming, And Resources

- Reuse channels or use gRPC client factory; do not create a channel per call. Keep TLS, credentials,
  discovery, load balancing, handlers, limits, and resilience in the client configuration boundary.
- Use async APIs. Do not block on RPC tasks.
- Bound concurrent calls and streaming buffers. `RequestStream.WriteAsync` has a single-writer
  requirement; serialize multiple producers through an owned bounded queue.
- Complete streams gracefully and dispose/cancel streaming calls on every exit path. Define reconnect,
  resume, replay, ordering, duplicate, and checkpoint behavior for long-lived streams.
- Avoid large unary binary messages; stream bounded chunks or use a more suitable transfer endpoint
  when whole-message buffering creates unacceptable memory pressure.

## Transport And Operations

- Require TLS and validate peer identity outside explicitly isolated local development. Keep tokens and
  sensitive metadata out of logs.
- Align client/server message limits, keepalive, proxy, HTTP/2, load-balancing, and deadline settings
  across the deployment path; do not raise limits globally without measured need.
- Use the standard gRPC health service where operational tooling expects it, with readiness semantics
  that match the served workload.
- Emit bounded telemetry for method, status, latency, deadline, retry, queue, and stream lifecycle using
  normalized service/method names rather than payload values.

## Testing And Quality Gates

- Add protobuf compatibility checks that compare supported contract baselines and reject field-number
  reuse or other breaking changes.
- Test services through a real in-process or test server with generated clients, HTTP/2, interceptors,
  auth, deadlines, cancellation, status mapping, and configured limits.
- Test malformed/oversized messages, unknown enum values, partial streams, disconnects, retryable and
  non-retryable failures, backpressure, and graceful completion.
- Run interoperability tests for every supported non-.NET client or server contract.

## Verification

Run the shared .NET gate plus the gRPC checks:

```sh
{{GRPC_PROTO_LINT_COMMAND}}
{{GRPC_BREAKING_CHANGE_COMMAND}}
{{GRPC_GENERATION_CHECK_COMMAND}}
{{GRPC_INTEGRATION_TEST_COMMAND}}
{{GRPC_INTEROP_TEST_COMMAND}}
```

Report exact commands and results. If a check cannot run, state why and what risk remains.
