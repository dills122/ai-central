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
