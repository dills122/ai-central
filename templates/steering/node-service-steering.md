# Node.js Service Steering

## Scope And Enforcement

Use this guidance for Node.js servers, API processes, background workers, consumers, schedulers,
and operational CLIs under `{{NODE_SERVICE_ROOT}}`. Apply it together with the JavaScript and
TypeScript steering profile.

Repository-specific instructions and closer-scoped steering take precedence. Replace every
placeholder before enforcing this file.

The words **must**, **do not**, and **never** describe default requirements. An exception requires a
documented reason, the narrowest possible scope, and a test or other guard against regression. Do
not weaken compiler, lint, test, security, or operational gates merely to make a change pass.

## Runtime And Deployment Contract

- Pin the supported Node.js and package-manager versions in repository-owned configuration. Use a
  Node.js release line supported by the project's deployment platform and dependencies.
- Commit one lockfile and use the selected package manager's frozen or immutable install mode in
  CI and release builds.
- Make the module system, entrypoints, startup command, configuration schema, health endpoints,
  shutdown budget, and deployment topology explicit.
- Keep application processes stateless unless durable state ownership is an intentional part of
  the service contract. Persist durable data outside process memory.
- Treat containers, process managers, reverse proxies, orchestrators, and worker counts as
  deployment choices, not assumptions baked into business logic.
- Do not enable experimental runtime features in production without an explicit compatibility,
  rollback, and CI decision.

## Startup, Readiness, And Shutdown

- Parse and validate configuration before accepting work. Fail startup with a concise diagnostic
  when required configuration is missing or invalid.
- Separate liveness from readiness. Readiness must remain false until required initialization is
  complete and become false before planned shutdown stops accepting new work.
- Keep startup and shutdown functions explicit and idempotent. Avoid network, filesystem, timer,
  listener, and registration side effects at import time.
- On a planned termination signal, stop accepting work, drain bounded in-flight work, close servers,
  queues, database pools, timers, and telemetry exporters, then exit within the platform's budget.
- Do not attempt to continue normal operation after an uncaught exception. Perform only bounded,
  synchronous emergency cleanup and let an external supervisor restart the process.
- Observe unhandled promise rejections according to the pinned Node.js runtime. Do not depend on a
  version-sensitive default; prevent them through explicit promise ownership and tests.

## Event Loop And Worker Pool

- Keep event-loop callbacks and worker-pool tasks short and bounded. One expensive callback or task
  can reduce throughput for every concurrent request.
- Do not use synchronous filesystem, crypto, compression, DNS, or child-process APIs on service hot
  paths.
- Bound input before parsing, decoding, decompressing, regular-expression matching, serialization,
  or cryptographic work. Reject oversized work before allocating proportionally to it.
- Measure event-loop delay, latency distributions, queue depth, and saturation before changing
  concurrency or worker counts.
- Partition large work into resumable chunks or move CPU-bound work to a bounded worker-thread,
  process, or external-job pool. Worker threads are not a substitute for bounding admission.
- Avoid catastrophic-backtracking regular expressions. Prefer linear-time parsing or constrain and
  test the input space.

## Streams, Backpressure, And Resource Ownership

- Respect stream backpressure. Check write results, await drain where required, and use pipeline
  abstractions that propagate errors and cleanup.
- Do not buffer unbounded request bodies, files, queue batches, logs, or responses in memory.
- Give every timer, listener, socket, stream, database connection, file handle, child process, and
  worker a clear owner and cleanup path.
- Propagate cancellation or `AbortSignal` through supported I/O and long-running work.
- Bound concurrency, queues, retries, batch sizes, response sizes, and cache growth. Define overload
  behavior instead of allowing implicit memory pressure.
- Test success, failure, cancellation, peer disconnect, timeout, and shutdown cleanup paths.

## HTTP And Network Boundaries

- Validate method, route, headers, content type, body shape, ranges, encodings, and maximum sizes at
  the boundary before invoking domain behavior.
- Configure request, header, idle, keep-alive, upstream, and shutdown timeouts deliberately. Align
  them with proxies and load balancers so the layers do not fight each other.
- Apply authentication and authorization independently. Scope authorization to the requested
  resource and action, not only to route membership.
- Bound pagination, fan-out, upload size, decompression ratio, redirects, and outbound response
  consumption. Apply rate or concurrency limits where abuse can consume shared resources.
- Return stable public error contracts while keeping stack traces, secrets, dependency details, and
  sensitive inputs out of responses and logs.
- Make retries explicit, bounded, jittered, observable, and limited to operations safe to repeat.

## Isolation And Privilege

- Treat dependencies, loaders, install scripts, native addons, generated code, and dynamic imports
  as executable supply-chain code.
- Never treat `node:vm` contexts as a security boundary for untrusted code. Use a separate process,
  container, virtual machine, or purpose-built isolation service with resource and capability limits.
- Invoke child processes with an executable and argument array. Avoid a shell, validate every
  argument, limit inherited environment and filesystem access, and enforce time and output bounds.
- Run with the least operating-system and cloud permissions needed. Do not run production services
  as root merely for convenience.
- Keep the Node.js inspector and other administrative interfaces disabled or privately isolated in
  production.
- When the pinned runtime supports the Node.js permission model, consider it defense in depth; do
  not treat it as a replacement for operating-system or workload isolation.

## Observability And Diagnostics

- Emit structured logs to standard output/error unless the platform contract says otherwise.
- Include a stable request, job, or trace correlation identifier without logging secrets or raw
  sensitive payloads.
- Measure request/job rate, errors, latency, saturation, event-loop delay, queue depth, memory, and
  external dependency behavior. Alert on user-visible symptoms and exhaustion risk.
- Keep metric labels bounded; never use user IDs, raw URLs, exception messages, or unbounded values
  as dimensions.
- Make diagnostic reports, heap snapshots, CPU profiles, and inspector access an explicit protected
  operator workflow because they can contain sensitive data and pause or burden the process.
- Test that readiness, logging, metrics, and traces still behave during degradation and shutdown.

## Dependencies And Publishing

- Prefer platform APIs and existing dependencies before adding another package. Review maintenance,
  transitive graph, install scripts, native code, permissions, and release provenance.
- Review manifest and lockfile changes together. Run the repository's dependency audit and triage
  findings by reachable impact rather than suppressing them globally.
- Disable dependency lifecycle scripts only when compatible with the project; otherwise explicitly
  review the scripts that will execute in CI and releases.
- Published packages must use an explicit file allowlist or equivalent packaging check. Inspect the
  release archive before publishing so source secrets, tests, local config, and build debris are not
  shipped.
- Prefer short-lived trusted publishing and provenance when the registry and CI provider support
  them. Do not store long-lived publish tokens when workload identity is available.

## Testing And Quality Gates

- Add focused unit tests for pure policy and transformation logic, then component tests around the
  real service boundary with controlled external dependencies.
- Test malformed, missing, oversized, slow, aborted, duplicated, and unauthorized inputs.
- Test timeout, retry, backpressure, concurrency, queue saturation, dependency failure, and partial
  response behavior.
- Exercise startup, readiness, planned shutdown, in-flight draining, fatal failure, and restart in
  integration tests appropriate to the deployment model.
- Keep fixtures isolated per test or worker. Do not rely on shared mutable ports, databases, clocks,
  environment variables, or process-wide state without controlled ownership.
- Run tests on every supported Node.js release line. Type checking, linting, formatting, tests,
  builds, and dependency checks must pass with no new warnings.
- Performance and load tests must use representative concurrency, payload distributions, and
  resource limits. Record the baseline and regression threshold.

## Verification

Run the smallest relevant checks first, then the complete gate:

```sh
{{NODE_FORMAT_COMMAND}}
{{NODE_LINT_COMMAND}}
{{NODE_TYPECHECK_COMMAND}}
{{NODE_TEST_COMMAND}}
{{NODE_BUILD_COMMAND}}
{{NODE_DEPENDENCY_AUDIT_COMMAND}}
{{NODE_SERVICE_SMOKE_COMMAND}}
```

For lifecycle, resource, or performance changes, also verify the production-like startup command,
readiness transition, termination signal, drain behavior, exit code, and relevant load or diagnostic
measurement. Report exact commands and results. If a check cannot run, state why and what risk remains.
