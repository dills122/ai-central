# Inventory

Scan root: `/Users/dsteele/repos`

Scan date: 2026-06-04

## Summary

| Category | Count | Source |
| --- | ---: | --- |
| Codex steering files | 17 | `footy-data-kit/.codex/steering`, `trove/.codex/steering` |
| `AGENTS.md` files | 10 | Project roots and app roots |
| Cursor rules | 13 | `breakerflow-platform/apps/cms/.cursor/rules` |
| Codex skills | 33 | `wap-labs/.codex/skills` |

## Collected Paths

### Codex Steering

- `collected/codex-steering/footy-data-kit/`
- `collected/codex-steering/trove/`

Notable reusable themes:

- repository scope and safe refactor boundaries
- JavaScript/ESM conventions
- data contracts and pipeline testing
- Angular architecture and coding standards
- accessibility, security/privacy, PWA/offline, Cloudflare platform

### AGENTS Files

- `collected/agents/footy-data-kit/AGENTS.md`
- `collected/agents/wap-labs/AGENTS.md`
- `collected/agents/wap-labs-spec-processing/AGENTS.md`
- `collected/agents/wap-labs-sentry-skills/AGENTS.md`
- `collected/agents/trove/AGENTS.md`
- `collected/agents/trove-bookmark-cleaner/AGENTS.md`
- `collected/agents/paylet/AGENTS.md`
- `collected/agents/breakerflow-platform-cms/AGENTS.md`
- `collected/agents/angular-mat-tailwind-starter/AGENTS.md`
- `collected/agents/collatix/AGENTS.md`

Notable reusable themes:

- purpose and priority framing
- architecture boundaries
- contract-first files
- branch and commit policy
- useful local commands
- framework-specific implementation standards

### Cursor Rules

- `collected/cursor-rules/breakerflow-platform-cms/`

Files cover Payload CMS development, access control, fields, hooks, endpoints, adapters, queries, components, plugins, and security-critical rules.

### Codex Skills

- `collected/codex-skills/wap-labs/`

High-value reusable skills include:

- `find-bugs`
- `gha-security-review`
- `property-based-testing`
- `differential-review`
- `variant-analysis`
- `coverage-analysis`
- `harness-writing`
- `create-prd`
- `release-notes`
- `sprint-plan`
- `user-stories`

## Things Not Collected Yet

- AI files below ignored dependency folders.
- Generic repository docs unless they were in known AI context locations.
- Temporary third-party skill dumps under `wap-labs/tmp`; these should be reviewed separately before importing because provenance and licensing may differ.

## Promoted Infrastructure Steering

- `templates/steering/infrastructure-opentofu-steering.md` is a normalized, provider-neutral
  starter for OpenTofu lifecycle, state, secret, CI, recovery, and network-safety rules.
- The `infra` bundle supplies the reviewed `terraform-skill` procedural workflow and now carries
  its Apache-2.0 license into installed project copies.
- Raw provider configuration, state, plans, backend inputs, tfvars, and secrets are excluded.

### Focused Wap Labs Refresh — 2026-07-26

Feature-source provenance:

- repository: `dills122/wap-labs`
- branch: `codex/inf-101-opentofu-steering-followup`
- commit: `acee3c772f885d957dc85d7d116fa08c73d3e2f8`
- review: draft PR `dills122/wap-labs#441`
- base checkpoint: merged INF-101 commit `26d50a88`
- status at collection: feature source under review; not represented as landed `main`

Collected through a temporary project-name-preserving allowlist root with
`scripts/collect-ai-context.sh`:

- `collected/misc/wap-labs/AGENTS.md`
- `collected/misc/wap-labs/.codex/steering/infrastructure-opentofu-steering.md`

Only these two AI-context files were collected. The source tree's implementation HCL, workflows,
runtime backend inputs, generated artifacts, state, plans, tfvars, and credentials were not copied.

### Focused Reef Review — 2026-07-31

Source provenance:

- repository: `dills122/reef`
- local path: `/Users/dsteele/repos/reef`
- branch: `master`
- commit: `7237004deb087bff802bb7c60a9c49ecf4187750`
- worktree status at collection: clean

Collected 14 project-owned AI-context files under `collected/misc/reef/`:

- root `AGENTS.md` and the `CLAUDE.md` redirect to canonical guidance;
- two real files from `.codex/steering/`;
- all ten files from the canonical `docs/steering/` index, including Kotlin, Go, architecture,
  repository, data-platform, API-boundary, and inter-service guidance.

Skipped:

- three `.codex/steering/` symlinks that point back to AI Central templates;
- `.codex/skills/` symlinks that point back to AI Central skill bundles;
- duplicate files in `.claude/worktrees/` and `.worktrees/`;
- large product plans, implementation evidence, generated sources, and project-specific runtime
  documentation outside the canonical steering surface.

Promoted from the review:

- `templates/steering/kotlin-jvm-steering.md`, a normalized Kotlin/JVM starter covering Gradle
  wrapper/toolchain discipline, framework-light architecture, thin routes, structured concurrency,
  persistence, contracts, and layered tests;
- the `kotlin-jvm` scaffold profile and automatic detection for Kotlin source or Gradle Kotlin DSL
  files;
- the `kotlin-jvm-engineering` skill and automatically detected `jvm` bundle for the guided setup
  path.

### Cross-Repository Refresh — 2026-07-31

After the focused Reef import, a broader refresh reviewed 44 local checkout directories whose
GitHub origin belongs to `dills122`. It added 16 committed raw source files:

- eight Wap Labs files: two `CLAUDE.md` entrypoints and six canonical `docs/agents/` files;
- four Capsule Corp files: root `AGENTS.md`, `CLAUDE.md`, and two project steering files;
- three Forage files: root `AGENTS.md` and two project steering files;
- one committed Liars Dice `CLAUDE.md`.

The refresh promoted normalized Rust and shell/scripting steering profiles and expanded the
collector's recognized AI locations. Exact source commits, dirty-worktree handling, exclusions,
and future candidates are documented in
`docs/repository-ai-context-audit-2026-07-31.md`.
