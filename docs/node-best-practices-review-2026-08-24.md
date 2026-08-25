# Node Best Practices Review — 2026-08-24

## Source And Import Decision

- Repository: `goldbergyoni/nodebestpractices`
- Upstream URL: https://github.com/goldbergyoni/nodebestpractices
- Reviewed commit: `dc3d60c29d5483d9ea99cf261bbd6203516a2ba7`
- Commit date: 2026-06-15
- Local review checkout: ignored `external/nodebestpractices/`
- License: Creative Commons Attribution-ShareAlike 4.0 International
- Review date: 2026-08-24

The upstream repository was used as a discovery index only. No upstream prose, examples, diagrams,
templates, or executable content were copied or adapted. That boundary avoids introducing a
share-alike payload into the reusable template catalog without an explicit repository-wide import
strategy. The promoted files are first-party guidance independently written from official Node.js
and npm documentation and AI Central's existing project-neutral JavaScript/TypeScript policy.

## What Was Reviewed

The review sampled the architecture, error handling, code style, testing, production, security,
performance, and Docker sections, including:

- component and layer organization, configuration, framework choice, and TypeScript;
- promise ownership, `Error` objects, centralized error handling, operational versus programmer
  failures, uncaught exceptions, and unhandled rejections;
- test structure, fixture isolation, ports, API/component tests, and expected test outcomes;
- logging, monitoring, health endpoints, process state, memory, dependency locks, clean installs,
  release lines, scaling, and graceful deployment;
- input limits, secrets, injection, dependency risk, rate limits, privileges, regular expressions,
  dynamic execution, child processes, and error disclosure;
- event-loop work, worker-pool work, and container build/run practices.

## Existing Coverage And Gaps

`templates/steering/javascript-typescript-steering.md` already covers strict typing, modules,
boundary validation, promise and resource ownership, stream backpressure, dependency discipline,
security, performance, and layered verification. Duplicating that material would make policy drift.

The reusable gap was operational Node.js service guidance: startup/readiness, signal-driven drain,
fatal process state, event-loop fairness, HTTP timeout relationships, strong isolation boundaries,
production diagnostics, and service-level resilience tests. These concerns justify a composable
service profile and a task skill rather than a larger universal JavaScript profile.

## Primary Sources Used For Promotion

The independent guidance was checked against current official sources:

- Node.js event-loop and worker-pool guidance:
  https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop
- Node.js process and error APIs: https://nodejs.org/api/process.html and
  https://nodejs.org/api/errors.html
- Node.js HTTP API: https://nodejs.org/api/http.html
- Node.js stream backpressure guidance:
  https://nodejs.org/en/learn/modules/backpressuring-in-streams
- Node.js worker threads and asynchronous context APIs:
  https://nodejs.org/api/worker_threads.html and https://nodejs.org/api/async_context.html
- Node.js security best practices:
  https://nodejs.org/en/learn/getting-started/security-best-practices
- npm clean installs, audits, provenance, and trusted publishing:
  https://docs.npmjs.com/cli/commands/npm-ci/,
  https://docs.npmjs.com/cli/audit/,
  https://docs.npmjs.com/viewing-package-provenance/, and
  https://docs.npmjs.com/trusted-publishers/

## Promoted Outputs

- `templates/steering/node-service-steering.md`: an explicit profile composed with the shared
  JavaScript/TypeScript baseline for servers, workers, consumers, schedulers, and operational CLIs.
- `templates/skills/first-party/node-service-engineering/`: a task workflow with focused references
  for lifecycle, resource/performance, and production-readiness work.
- The `node` and `engineering` skill bundles include `node-service-engineering`.

The profile is intentionally explicit. A root `package.json` still selects only the general
`javascript-typescript` profile and `node` skill bundle because the same signal describes frontend
applications, libraries, tooling repositories, and services.

## Patterns Not Promoted As Universal Policy

- A fixed three-tier or business-component directory layout. Cohesion and dependency direction
  matter; the correct shape depends on the codebase and change pressure.
- Advice to use TypeScript only sparingly. AI Central preserves the target repository's language
  decision and applies strict TypeScript safety when TypeScript is selected.
- A required framework, reverse proxy, process manager, container runtime, or one-process-per-core
  rule. These are deployment choices that require measured load and platform evidence.
- `NODE_ENV` as the complete configuration model. Configuration requires a validated schema and
  explicit deployment contract.
- `npm ci` as a universal command. npm projects should use it; other package managers should use
  their equivalent frozen or immutable mode.
- A lockfile as sufficient supply-chain protection. It improves reproducibility but does not remove
  install-script, maintainer, registry, provenance, or reachable-vulnerability risk.
- `node:vm` or an in-process sandbox package as a security boundary for hostile code. Stronger
  process, container, virtual-machine, or purpose-built isolation is required.
- Named tools and version-sensitive defaults whose maintenance status or behavior may change.

## Verification Requirements

The profile must install only when explicitly selected, compose the JavaScript/TypeScript baseline,
remain non-overwriting, and avoid appearing in ordinary package detection. The skill must pass the
repository's quick skill validator, install through `node`, `engineering`, and `all`, and appear in
the generated APM manifests. `./scripts/check.sh` exercises those invariants.
