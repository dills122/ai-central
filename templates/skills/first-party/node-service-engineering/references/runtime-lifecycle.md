# Runtime Lifecycle

Use this reference for startup, configuration, readiness, shutdown, fatal failures, signals, and
restart behavior.

## Confirm The Contract

Inspect the runtime pin, entrypoint, startup command, deployment manifest, health checks, termination
grace period, and supervisor. Record which component owns restart. Application code cannot promise a
safe restart unless an external platform actually performs one.

Validate configuration before opening listeners or consuming jobs. Distinguish missing, malformed,
and unavailable dependency configuration, and keep secret values out of diagnostics.

Readiness should be false during initialization, true only while the process can accept work, and
false before draining starts. Liveness should answer whether restart is useful; it should not become
a duplicate dependency probe that creates restart storms.

## Planned Shutdown

A planned shutdown should:

1. make readiness false and stop accepting new requests or jobs;
2. start a bounded shutdown deadline;
3. drain in-flight work that can safely finish;
4. close servers, consumers, sockets, pools, timers, workers, and telemetry exporters;
5. force or abandon remaining work according to its idempotency and delivery contract; and
6. exit with a deliberate code before the platform sends an uncatchable termination.

Make repeated shutdown signals idempotent. Do not let new work enter through a secondary listener or
consumer after draining begins. Test both an idle process and a process with in-flight work.

## Fatal Failures

An uncaught exception means application state may be undefined. Node.js documentation warns against
resuming normal operation. An `uncaughtException` handler may emit a last-resort diagnostic and do
bounded synchronous cleanup, but it must not turn the event into a recovery mechanism. Use an
external monitor or orchestrator to restart a fresh process.

Prevent unhandled rejections by awaiting, returning, aggregating, or deliberately supervising every
promise. Node.js behavior has changed across release lines, so pin the runtime and do not treat its
default rejection mode as application policy.

`EventEmitter` error events require deliberate handling. A missing `error` listener can terminate
the process; an indiscriminate listener can hide a fatal condition. Handle the error where the
resource owner can close, translate, retry safely, or propagate it.

## Verification Scenarios

- invalid configuration fails before readiness
- slow initialization does not report ready early
- termination stops admission and drains within budget
- a second termination signal does not duplicate cleanup
- dependency failure during shutdown cannot hang exit indefinitely
- uncaught exception exits and is restarted by the real supervisor
- detached work reports rejection and does not outlive its owner silently

Sources: https://nodejs.org/api/process.html and https://nodejs.org/api/errors.html
