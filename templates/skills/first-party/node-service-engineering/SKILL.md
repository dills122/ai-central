---
name: node-service-engineering
description: Design, implement, review, and operate reliable Node.js services, APIs, background workers, consumers, schedulers, and operational CLIs. Use when work involves Node process lifecycle, configuration and readiness, graceful shutdown, fatal errors, event-loop or worker-pool fairness, HTTP timeouts and limits, streams and backpressure, worker threads or child processes, production observability, dependency execution risk, or service load and resilience testing. Do not use for browser-only frontend work or when the task is only to inspect an installed package API.
---

# Node Service Engineering

Build Node.js workloads around explicit runtime, boundary, resource, and operational contracts. Use
the repository's framework and package manager; this skill does not impose a framework, deployment
platform, process manager, module system, or fixed architecture.

## Establish The Project Contract

Before changing code, inspect the closest instructions and determine:

- pinned Node.js and package-manager versions, module system, lockfile, and frozen install command
- service entrypoints, framework, configuration schema, health endpoints, and startup command
- deployment topology, termination signal, shutdown budget, restart owner, and resource limits
- external dependencies, queues, durable state, retry and idempotency rules, and trust boundaries
- logging, metrics, tracing, diagnostic, test, lint, type-check, build, and audit commands

Do not infer a backend service merely from `package.json`. Confirm that the target is a server,
worker, consumer, scheduler, or operational process.

## Route The Work

Read only the references needed for the task:

- For configuration, readiness, planned shutdown, uncaught exceptions, unhandled rejections,
  signals, restart behavior, or process state, read `references/runtime-lifecycle.md`.
- For event-loop delay, worker-pool contention, CPU work, streams, backpressure, memory, queues,
  worker threads, child processes, or overload, read `references/performance-and-resources.md`.
- For HTTP limits, security boundaries, dependency installation, publishing, observability,
  production diagnostics, and service-level testing, read `references/production-readiness.md`.

Read multiple references when the change crosses those boundaries.

## Implement From Invariants

1. State the user-visible and operational invariants before selecting a library or pattern.
2. Validate external input and configuration before it reaches domain behavior or expensive work.
3. Give every promise, timer, listener, socket, stream, connection, worker, and child process an
   owner, bound, cancellation path, error path, and cleanup path.
4. Keep event-loop callbacks and worker-pool tasks bounded. Partition, offload, reject, or apply
   backpressure rather than accepting unlimited work.
5. Make timeouts, retries, queue sizes, body limits, concurrency, and shutdown deadlines explicit.
6. Preserve the project's architecture unless evidence shows it cannot uphold the invariants. Do
   not introduce a universal three-tier layout, framework, proxy, process manager, or container.
7. Add observability at the same boundary where failure, saturation, or delay is controlled.
8. Prefer the smallest change that has a deterministic test and a production failure story.

## Handle Fatal And Untrusted Conditions Safely

- Do not resume normal operation after an uncaught exception. Restrict emergency cleanup to
  synchronous, bounded work and rely on an external supervisor for restart.
- Prevent unhandled promise rejections through explicit promise ownership; do not depend on a
  runtime-version default.
- Do not use `node:vm` as a sandbox for untrusted code. Use an operating-system or workload
  isolation boundary with capability and resource limits.
- Avoid shell execution. Pass a validated argument array to child processes and bound their time,
  output, environment, and cleanup.
- Treat install scripts, loaders, native addons, code generators, and dynamic imports as executable
  dependency code.

## Verify In Layers

Run the repository's smallest focused check first, then broaden proportionally:

1. focused unit or component test for the changed behavior
2. type check, lint, and format check
3. relevant integration tests with real service entrypoints and controlled dependencies
4. production-like startup, readiness, request/job, termination signal, drain, and exit smoke test
5. full test/build gate and frozen dependency installation when manifests or locks changed
6. dependency audit, package-content check, load test, or diagnostic measurement when relevant

For lifecycle and resource changes, record exact timeouts, concurrency, payload, resource limits,
signals, exit codes, and observations. A test that proves only the happy response is incomplete.

## Report The Result

Summarize:

- the runtime and deployment assumptions confirmed from the repository
- the service invariant and failure mode addressed
- bounds, timeouts, cleanup, isolation, or observability decisions introduced
- exact verification commands and results
- any production or version-specific behavior that remains unverified

Do not present an upstream checklist as universal policy. Explain why each applied rule belongs to
this service and its deployment contract.

## Primary Sources

- Node.js: https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop
- Node.js process API: https://nodejs.org/api/process.html
- Node.js HTTP API: https://nodejs.org/api/http.html
- Node.js security best practices: https://nodejs.org/en/learn/getting-started/security-best-practices
- npm clean installs: https://docs.npmjs.com/cli/commands/npm-ci/
- npm trusted publishing: https://docs.npmjs.com/trusted-publishers/
