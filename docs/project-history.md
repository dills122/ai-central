# Project History

This document preserves dated collection and promotion context that was previously included in the
project README. It describes how AI Central's reusable library emerged; it is not the current setup
or installation guide.

For current usage, see the [README](../README.md). For a detailed source inventory, see
[Inventory](inventory.md), [Reuse candidates](reuse-candidates.md), and
[Skill attribution](skill-attribution.md).

## Initial Collection

The first repository scan covered `/Users/dsteele/repos` on 2026-06-04. It collected:

- 17 Codex steering files from `footy-data-kit` and `trove`;
- 10 `AGENTS.md` files from project and application roots;
- 13 Cursor and Payload CMS rules from `breakerflow-platform/apps/cms`; and
- 33 first-party Codex skills from `wap-labs/.codex/skills`.

These counts describe that collection event. They should not be interpreted as the current
installable catalog.

## Promotion Reviews

### Reef And Cross-Repository Review

A focused Reef review on 2026-07-31 promoted a reusable Kotlin/JVM steering profile and skill.
Reef's trading-platform and repository-specific source context was reviewed locally but was not
retained in the reusable library.

A broader review of 44 checkouts promoted Rust and shell/scripting profiles while leaving
project-specific source context in its originating repositories.

### Language Steering Review

A primary-source language review on 2026-07-31 strengthened the JavaScript/TypeScript, Kotlin/JVM,
Rust, and POSIX shell templates with strict, domain-neutral engineering and verification
standards. The supporting research is recorded in
[Language steering research](language-steering-research-2026-07-31.md).

### Workflow Skill Review

The 2026-08-12 workflow audit established smaller task-oriented layers for orchestration,
documentation, and delivery instead of requiring consumers to install broad catalogs. The
decision record is [Workflow skill audit and bundle decision](workflow-skill-audit-2026-08-12.md).

## Historical Collected Skills

The initial Wap Labs collection preserved the following 33 skills as raw source material. They
were not normalized templates and were not selected by an installable bundle at the time:

- `analyze-feature-requests`
- `brainstorm-experiments-existing`
- `brainstorm-ideas-existing`
- `brainstorm-okrs`
- `cargo-fuzz`
- `coverage-analysis`
- `create-prd`
- `differential-review`
- `dummy-dataset`
- `find-bugs`
- `gha-security-review`
- `grammar-check`
- `harness-writing`
- `identify-assumptions-existing`
- `job-stories`
- `metrics-dashboard`
- `outcome-roadmap`
- `pre-mortem`
- `prioritization-frameworks`
- `prioritize-assumptions`
- `prioritize-features`
- `property-based-testing`
- `release-notes`
- `retro`
- `sprint-plan`
- `sql-queries`
- `stakeholder-map`
- `summarize-interview`
- `summarize-meeting`
- `test-scenarios`
- `user-stories`
- `variant-analysis`
- `wwas`

This list records the original review state. A similarly named workflow may now exist as an
imported, adapted, or first-party skill; consult the current bundle manifests before drawing
conclusions from the historical list.

## Historical Catalog Notes

At the time this history was moved out of the README, AI Central contained 131 reusable
`SKILL.md` definitions under `templates/skills/`. The `all` meta-bundle exposed 134 installed
directories because:

- some skills were shared by both compact and broad bundles;
- Playwright and several compact-bundle dependencies also appeared under historical prefixed
  aliases; and
- three reviewed imported skills were retained for manual use but intentionally left unbundled.

Those unbundled skills were:

- `web-design-guidelines` from `antfu/skills`;
- `cavecrew` from `JuliusBrussee/caveman`; and
- `caveman-stats` from `JuliusBrussee/caveman`.

Current bundle membership is defined by [`scripts/install-skill-bundle.sh`](../scripts/install-skill-bundle.sh)
and the generated manifests under [`packages/apm/`](../packages/apm/), not by these historical
counts.

## Preservation Model

AI Central intentionally separates three stages of material:

1. `collected/` preserves raw source material and provenance.
2. Review notes record whether material should be promoted, adapted, or left project-specific.
3. `templates/` contains normalized guidance approved for reuse.

Collected files are not hand-edited as part of ordinary template work. If collected material
changes, its source manifest must be refreshed with:

```sh
./scripts/refresh-source-manifest.sh
```

See [Collection workflow](collection-workflow.md) for the current collection process and
[`source-manifest.sha256`](source-manifest.sha256) for tracked source hashes.
