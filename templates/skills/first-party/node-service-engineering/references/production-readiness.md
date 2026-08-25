# Production Readiness

Use this reference for HTTP limits, service security, dependencies, publishing, observability,
diagnostics, and production-focused testing.

## HTTP And Abuse Resistance

Configure request, header, idle, keep-alive, upstream, and shutdown timeouts deliberately. Node.js
HTTP defaults and option names vary by supported runtime, so inspect the pinned version's API rather
than copying numbers from a checklist. Align application, proxy, load-balancer, and client timeouts.

Validate method, route, content type, headers, body schema, encodings, and size before expensive
work. Bound uploads, decompression, pagination, redirect following, fan-out, outbound response reads,
and per-principal concurrency. Apply authentication, resource-level authorization, and rate or
concurrency controls as separate decisions.

Use stable public error responses. Keep stack traces, dependency details, credentials, tokens, raw
payloads, and sensitive identifiers out of responses and logs.

## Isolation And Dependencies

`node:vm` is not a security mechanism for untrusted code. Put hostile or tenant-supplied code behind
a process, container, virtual-machine, or purpose-built isolation boundary with CPU, memory, time,
filesystem, network, and capability limits.

Treat dependencies as code with the privileges of the service. Review lockfile changes, lifecycle
scripts, loaders, native addons, code generators, maintenance, transitive size, and provenance. Use
the project's frozen or immutable install mode; `npm ci` is the npm-specific form and requires the
lockfile to match the manifest without rewriting either.

The Node.js permission model may reduce accidental or compromised access in supported runtimes, but
it is defense in depth. Verify compatibility and preserve operating-system and workload isolation.

For publishing, inspect the actual package archive and use an explicit file allowlist where
possible. Prefer trusted publishing with short-lived OIDC credentials and provenance when the npm
registry and CI provider support the project's workflow.

## Observability And Diagnostics

Emit structured events with stable names and bounded fields. Correlate requests or jobs across
async boundaries using the project's supported context mechanism. Measure rate, errors, latency,
saturation, event-loop delay, queue depth, memory, and dependency behavior.

Metric attributes must remain low-cardinality. Logs, heap snapshots, diagnostic reports, profiles,
and traces can contain sensitive data; protect retention and operator access. Keep the inspector off
public and production interfaces.

Health probes should be cheap and should not amplify a dependency outage. Test telemetry during
timeouts, overload, partial failure, and shutdown—not only successful requests.

## Verification Scenarios

- timeout relationships across app, proxy, load balancer, and client
- malformed, unauthorized, oversized, slow, and aborted requests
- dependency install from a clean workspace using the committed lockfile
- dependency audit triage and package archive content inspection
- protected diagnostic capture without public inspector exposure
- bounded log and metric dimensions under attacker-controlled input
- load test with representative payload distribution and deployment resource limits
- release provenance or trusted-publishing workflow when supported

Sources: https://nodejs.org/api/http.html,
https://nodejs.org/en/learn/getting-started/security-best-practices,
https://docs.npmjs.com/cli/commands/npm-ci/, and
https://docs.npmjs.com/trusted-publishers/
