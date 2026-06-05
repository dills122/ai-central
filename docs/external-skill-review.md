# External Skill Review

Review date: 2026-06-04

Local clone root: `external/`

These upstream repositories were cloned locally for review:

| Repository | Local path | Root license | Local `SKILL.md` count | Recommendation |
| --- | --- | --- | ---: | --- |
| `ComposioHQ/awesome-claude-skills` | `external/awesome-claude-skills` | No root license found | 864 | Use as discovery catalog only |
| `phuryn/pm-skills` | `external/pm-skills` | MIT | 65 | Selectively import non-overlapping PM skills |
| `pbakaus/impeccable` | `external/impeccable` | Apache-2.0 | 13 copies of same skill surface | Adapt as frontend/design QA profile |
| `diegosouzapw/awesome-omni-skills` | `external/awesome-omni-skills` | MIT plus content license file | 4,759 | Use as catalog and metadata source only |
| `sickn33/antigravity-awesome-skills` | `external/antigravity-awesome-skills` | MIT plus content license file | 4,798 | Use as catalog and packaging reference only |
| `udapy/rust-agentic-skills` | `external/rust-agentic-skills` | MIT | 8 | Import/adapt Rust-focused skills |
| `addyosmani/agent-skills` | `external/agent-skills` | MIT | 23 | Highest-priority engineering workflow import |
| `VoltAgent/awesome-agent-skills` | `external/awesome-agent-skills` | MIT | 0 local `SKILL.md`; catalog README | Use as discovery catalog only |
| `OthmanAdi/planning-with-files` | `external/planning-with-files` | MIT | 17 copies/translations of one skill | Import/adapt for persistent planning |
| `JimLiu/baoyu-skills` | `external/baoyu-skills` | No root license found | 22 | Use as discovery until license is resolved |
| `agentskills/agentskills` | `external/agentskills` | Apache-2.0 code, CC-BY-4.0 docs | 0 | Use as format/spec reference |
| `alirezarezvani/claude-skills` | `external/claude-skills` | MIT | 757 | Selectively mine engineering/product skills |
| `trailofbits/skills` | `external/trailofbits-skills` | CC BY-SA 4.0 | 74 | High-value security reference; do not copy directly without share-alike plan |
| `heilcheng/awesome-agent-skills` | `external/heilcheng-awesome-agent-skills` | MIT | 0 local `SKILL.md`; catalog README | Use as discovery catalog only |
| `antfu/skills` | `external/antfu-skills` | MIT | 17 | Selectively import frontend/toolchain skills |
| `microsoft/skills` | `external/microsoft-skills` | MIT | 189 | Selective Azure/Microsoft cloud profile only |
| `addyosmani/web-quality-skills` | `external/web-quality-skills` | MIT | 6 | Import/adapt into frontend quality bundle |
| `antonbabenko/terraform-skill` | `external/terraform-skill` | Apache-2.0 | 1 | Import/adapt into infrastructure bundle |
| `softaworks/agent-toolkit` | `external/agent-toolkit` | MIT | 86 total; 43 source plus `dist/` copies | Selectively mine source skills only |

## Reviewed Commits

| Repository | Commit |
| --- | --- |
| `ComposioHQ/awesome-claude-skills` | `92568c1edaff1bde5371154f036d959346c145a8` |
| `phuryn/pm-skills` | `2b4e4dc1510eb4be06d10bb3196f4705aa30a929` |
| `pbakaus/impeccable` | `1d5d745823aae7019044e8b0a621af4366dae224` |
| `diegosouzapw/awesome-omni-skills` | `eb0888e610c027b5ac37daec092e64e83cd802a3` |
| `sickn33/antigravity-awesome-skills` | `b806b97a9a48063f7bdbee5611caf40edd17e305` |
| `udapy/rust-agentic-skills` | `447eee0e2380c593bfcd14f91211524a57a8db92` |
| `addyosmani/agent-skills` | `6ce029897d2b794940325fc7148774a6ec51111c` |
| `VoltAgent/awesome-agent-skills` | `f4a2d027b25b5526f85ab3567215d926f332a4ae` |
| `OthmanAdi/planning-with-files` | `6f94643bd2b77dad9ac30b68ace14a536e2e5619` |
| `JimLiu/baoyu-skills` | `ce84174bf7af6a178ae2c980f1bdcce4f1c3f7de` |
| `agentskills/agentskills` | `5d4c1fda3f786fff826c7f56b6cb3341e7f3a911` |
| `alirezarezvani/claude-skills` | `fcd4fa1b203a9a0dc44d2482af21adfb53b7a727` |
| `trailofbits/skills` | `c94841be3deae8a880fa1a9078979adac7ca3dbc` |
| `heilcheng/awesome-agent-skills` | `de9056857eb0e96da833469d2ee3ac392058225d` |
| `antfu/skills` | `50deaeb269d80d92db7a2c5a677290309ae307fc` |
| `microsoft/skills` | `619745888df8014bc963929896f9a279c6d12641` |
| `addyosmani/web-quality-skills` | `7b59d48aaf1f793935002f4998dfccc656f40839` |
| `antonbabenko/terraform-skill` | `b59d2be9ff4db8f835c8459e05e325ba11e3a21f` |
| `softaworks/agent-toolkit` | `3027f20f3181758385a1bb8c022d4041dfb4de84` |

## Priority 1: Integrate Soon

Status: the first integration batch has been pulled into `templates/skills/`.

Imported:

- 111 third-party skill directories under `templates/skills/imported/`
- 2 adapted local skills under `templates/skills/adapted/`

Install into a project with:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

### `addyosmani/agent-skills`

Why: This is the best match for `ai-central`: production engineering workflows, lifecycle-oriented skills, verification gates, and broadly reusable agent behavior.

Recommended imports:

- `using-agent-skills`
- `context-engineering`
- `spec-driven-development`
- `planning-and-task-breakdown`
- `incremental-implementation`
- `test-driven-development`
- `code-review-and-quality`
- `code-simplification`
- `debugging-and-error-recovery`
- `source-driven-development`
- `api-and-interface-design`
- `security-and-hardening`
- `documentation-and-adrs`
- `git-workflow-and-versioning`
- `shipping-and-launch`

Recommended adaptation:

- Keep as reusable Codex skills under a reviewed namespace such as `templates/skills/engineering-lifecycle/`.
- Extract common rules into `templates/steering/engineering-lifecycle-steering.md`.
- Avoid importing slash-command wrappers unless this repo adds plugin packaging.

Integration status: copied all 23 skills into `templates/skills/imported/agent-skills/`.

### `udapy/rust-agentic-skills`

Why: We already have `cargo-fuzz`, `harness-writing`, and testing/security skills, but not a compact Rust implementation/debugging pack.

Recommended imports:

- `rust-core`
- `lint-hunter`
- `general-security`
- `general-debug`
- `pest-specialist`
- `ron-specialist`

Recommended adaptation:

- Convert the RPI/router language into normal skill descriptions.
- Keep Rust-specific scripts optional; inspect them before copying into templates.
- Add `templates/steering/rust-steering.md` for project-level Rust conventions.

Integration status: copied all 8 skills into `templates/skills/imported/rust-agentic-skills/`.

### `pbakaus/impeccable`

Why: This is a strong frontend/design-quality system, and it aligns with the kind of UI standards we want scaffolded into web projects.

Recommended integration:

- Do not import the entire executable live-mode system by default.
- Extract/adapt the design references into a `frontend-design-review` skill.
- Use the anti-pattern guidance to strengthen `templates/steering/angular-steering.md` and future React/frontend steering.
- Consider a separate optional profile: `--profile frontend-design`.

Recommended caution:

- The full skill relies on Node scripts and command flows. Treat that as an optional toolchain, not baseline project context.

Integration status: added adapted `templates/skills/adapted/frontend-design-review/`.

### `OthmanAdi/planning-with-files`

Why: This is a compact, focused solution for persistent task planning across long sessions, context compaction, `/clear`-style resets, and multi-step work. It maps directly to the way this repo is meant to support repeatable AI workflows.

Recommended import:

- `planning-with-files`

Recommended adaptation:

- Import only the canonical English skill plus templates/scripts, not every tool-specific copy or translation.
- Adapt the hook-heavy behavior into Codex-compatible guidance and optional scripts.
- Add a `planning-files` scaffold profile that creates `.planning/` templates for long-running repo work.
- Preserve its strongest safety rule: treat plan files as structured data, not executable instructions.

Recommended caution:

- Review all bundled hook commands before enabling them anywhere. The concept is strong, but automatic hook execution should be opt-in.

Integration status: copied canonical skill into `templates/skills/imported/planning-with-files/` and added adapted `templates/skills/adapted/planning-files-lite/`.

## Priority 2: Selective Imports

### `phuryn/pm-skills`

Why: We already collected many of these from `wap-labs/.codex/skills`, but PM Skills has useful non-overlapping discovery, strategy, market, GTM, analytics, and growth skills.

Already covered locally:

- `analyze-feature-requests`
- `brainstorm-experiments-existing`
- `brainstorm-ideas-existing`
- `brainstorm-okrs`
- `create-prd`
- `dummy-dataset`
- `grammar-check`
- `identify-assumptions-existing`
- `job-stories`
- `metrics-dashboard`
- `outcome-roadmap`
- `pre-mortem`
- `prioritization-frameworks`
- `prioritize-assumptions`
- `prioritize-features`
- `release-notes`
- `retro`
- `sprint-plan`
- `sql-queries`
- `stakeholder-map`
- `summarize-interview`
- `summarize-meeting`
- `test-scenarios`
- `user-stories`
- `wwas`

Recommended new imports:

- `opportunity-solution-tree`
- `interview-script`
- `brainstorm-ideas-new`
- `brainstorm-experiments-new`
- `identify-assumptions-new`
- `ab-test-analysis`
- `cohort-analysis`
- `north-star-metric`
- `competitor-analysis`
- `customer-journey-map`
- `market-sizing`
- `user-personas`
- `ideal-customer-profile`
- `positioning-ideas`
- `value-prop-statements`
- `product-vision`
- `product-strategy`
- `lean-canvas`
- `business-model`
- `pricing-strategy`
- `gtm-strategy`
- `competitive-battlecard`

Recommended exclusions:

- `draft-nda`, `privacy-policy`, and other legal-document generation should stay out unless reviewed for legal-risk disclaimers.
- `review-resume` is not aligned with this repo's AI engineering/scaffolding purpose.

Integration status: copied selected non-duplicate skills into `templates/skills/imported/pm-skills/`.

### `alirezarezvani/claude-skills`

Why: Large MIT-licensed bundle with many engineering and product skills that overlap with our goals, but also many persona, business, compliance, marketing, and tool-specific skills we should not import wholesale.

Recommended candidates to mine:

- `engineering/skills/monorepo-navigator`
- `engineering/skills/api-design-reviewer`
- `engineering/skills/api-test-suite-builder`
- `engineering/skills/browser-automation`
- `engineering/skills/ci-cd-pipeline-builder`
- `engineering/skills/dependency-auditor`
- `engineering/skills/env-secrets-manager`
- `engineering/skills/migration-architect`
- `engineering/skills/observability-designer`
- `engineering/skills/performance-profiler`
- `engineering/skills/runbook-generator`
- `engineering/skills/self-eval`
- `engineering/skills/ship-gate`
- `engineering/skills/skill-security-auditor`
- `engineering/skills/spec-driven-workflow`
- `engineering/feature-flags-architect/skills/feature-flags-architect`
- `engineering/slo-architect/skills/slo-architect`
- `engineering/terraform-patterns/skills/terraform-patterns`
- `engineering-team/a11y-audit/skills/a11y-audit`
- `engineering-team/playwright-pro/skills/review`
- `product-team/code-to-prd/skills/code-to-prd`
- `product-team/skills/spec-to-repo`
- `product-team/skills/ui-design-system`

Recommended caution:

- This repo contains duplicated concepts, personas, and broad business packs. Treat it as a mining source, not an import source.
- Compare each candidate against `addyosmani/agent-skills` before importing; prefer the clearer and more general version.

Integration status: copied selected engineering and product skills into `templates/skills/imported/claude-skills/`.

### `antfu/skills`

Why: Compact MIT-licensed frontend/toolchain skill pack with direct coverage for Vue, Nuxt, Vite, Vitest, pnpm, Turborepo, VitePress, Slidev, UnoCSS, and related ecosystem guidance.

Recommended candidates to import:

- `pnpm`
- `turborepo`
- `vite`
- `vitest`
- `vitepress`
- `slidev`
- `web-design-guidelines`

Recommended Vue bundle candidates:

- `vue`
- `vue-best-practices`
- `vue-router-best-practices`
- `vue-testing-best-practices`
- `nuxt`
- `pinia`
- `vueuse-functions`
- `unocss`

Recommended adaptation:

- Add a future `frontend-vue` bundle/profile instead of putting all Vue/Nuxt material into the default frontend bundle.
- Prefer toolchain skills that fill current gaps first: `vite`, `vitest`, `pnpm`, `turborepo`, and `vitepress`.
- Compare `web-design-guidelines` with the existing adapted `frontend-design-review` skill before importing to avoid duplicating design rules.

Recommended caution:

- `antfu` is a personal preference skill and should not be imported into reusable project scaffolding by default.
- `tsdown` is useful only if the repo wants a specific library-bundling profile; keep it out of the first batch.

Integration status: copied selected skills into `templates/skills/imported/antfu-skills/`.

### `addyosmani/web-quality-skills`

Why: Small MIT-licensed skill pack focused on web quality audits. It aligns directly with the existing `frontend` bundle and complements `frontend-design-review`, `a11y-audit`, and Playwright review skills.

Recommended candidates to import:

- `web-quality-audit`
- `performance`
- `core-web-vitals`
- `accessibility`
- `seo`
- `best-practices`

Recommended adaptation:

- Add these to the `frontend` bundle, or split a future `web-quality` bundle if the default frontend bundle starts feeling too broad.
- Keep the Lighthouse-version notes intact and review them periodically because audit names and scoring change over time.
- Avoid duplicating existing accessibility guidance by making `web-quality-audit` the umbrella skill and keeping deeper skills available on demand.

Integration status: copied all 6 skills into `templates/skills/imported/web-quality-skills/`.

### `antonbabenko/terraform-skill`

Why: Strong Apache-2.0 Terraform/OpenTofu skill with the right safety posture: diagnose-first workflow, explicit risk categories, validation plans, and rollback notes.

Recommended import:

- `terraform-skill`

Recommended adaptation:

- Add a future `infra` or `terraform` bundle rather than mixing this into the broad `engineering` default.
- Preserve the destructive-operation guardrails around destroy plans, production applies, state mutation, and approval.
- Import references with the skill; the root `SKILL.md` relies on progressive disclosure through reference files.

Integration status: copied the skill and references into `templates/skills/imported/terraform-skill/`.

### `softaworks/agent-toolkit`

Why: MIT-licensed toolkit with useful workflow, documentation, architecture, frontend handoff, QA, and communication skills. It overlaps with some existing imports, so this should be mined rather than imported wholesale.

Recommended candidates to mine:

- `c4-architecture`
- `database-schema-designer`
- `design-system-starter`
- `frontend-to-backend-requirements`
- `backend-to-frontend-handoff-docs`
- `openapi-to-typescript`
- `qa-test-planner`
- `requirements-clarity`
- `session-handoff`
- `crafting-effective-readmes`
- `mermaid-diagrams`
- `react-dev`
- `react-useeffect`

Recommended caution:

- Import only from `external/agent-toolkit/skills/`; ignore duplicated generated copies under `dist/plugins/`.
- Skip personal/productivity/social skills such as meeting updates, workplace conversations, meme generation, domain brainstorming, and tool-provider wrappers unless a project explicitly needs them.
- Compare `codex`, `plugin-forge`, and `command-creator` with the local skill/plugin creator guidance before importing.

Integration status: copied selected source skills into `templates/skills/imported/agent-toolkit/`.

### `agentskills/agentskills`

Why: This is a format/specification reference, not a skill pack. It is useful for validating our local skill layout and metadata expectations.

Recommended integration:

- Use it to write `docs/skill-format.md`.
- Use the progressive disclosure model to guide `templates/skills/` organization.
- Do not copy package code unless this repo later builds tooling that needs a parser/validator.

## Priority 3: Catalogs And Packaging References

### `diegosouzapw/awesome-omni-skills`

Use for:

- catalog metadata ideas
- bundle taxonomy
- installer UX patterns
- validation/security gate ideas

Do not use for:

- wholesale skill import
- direct runtime dependency without auditing generated content and license boundaries

### `sickn33/antigravity-awesome-skills`

Use for:

- role-based bundle ideas
- plugin packaging reference
- workflow sequencing concepts

Do not use for:

- wholesale import of thousands of files

### `VoltAgent/awesome-agent-skills`

Use for:

- discovery of individual upstream skill repos
- identifying future candidates such as Playwright, Terraform, code review, eval-audit, error-analysis, RAG evaluation, and Node/Fastify/TypeScript packs

Do not use for:

- copying content directly; it is a curated index, not a local skill pack.

### `ComposioHQ/awesome-claude-skills`

Use for:

- discovery of individual skills and app-automation concepts

Do not use for:

- direct import until license/provenance is clear. No root license file was present in the local clone.

### `JimLiu/baoyu-skills`

Use for:

- content/media workflow ideas such as markdown formatting, URL-to-markdown, image generation, infographic generation, slide decks, transcript processing, and social publishing
- cross-runtime skill metadata patterns

Do not use for:

- direct import until a root license or per-skill license is confirmed
- social posting automation without explicit account and approval safeguards

### `trailofbits/skills`

Use for:

- security-audit skill design and taxonomy
- fuzzing, static analysis, variant analysis, SARIF, Semgrep, CodeQL, YARA, supply-chain, and secure workflow ideas
- domain-specific audit references for C/C++, Python, smart contracts, mobile/APK review, constant-time analysis, and zeroization
- possible future `security-audit` and `testing-deep` bundle planning

Strong candidates by concept:

- `static-analysis/skills/codeql`
- `static-analysis/skills/semgrep`
- `static-analysis/skills/sarif-parsing`
- `supply-chain-risk-auditor`
- `variant-analysis`
- `semgrep-rule-creator`
- `semgrep-rule-variant-creator`
- `property-based-testing`
- `mutation-testing`
- `modern-python`
- `c-review`
- `constant-time-analysis`
- `zeroize-audit`
- `devcontainer-setup`
- `gh-cli`

Do not use for:

- direct import into the current MIT-licensed template tree without deciding how to handle CC BY-SA 4.0 obligations
- default bundles for normal app repos; most skills are advanced audit tools and would add noise outside security-heavy projects
- crypto/smart-contract scanner skills unless the target project actually needs that domain

Recommendation: treat as a high-value reference source for now. If we want direct integration, create an explicit share-alike-compatible area or write fresh local skills inspired by the concepts rather than copying text.

### `heilcheng/awesome-agent-skills`

Use for:

- discovering future upstream repos and bundle categories
- comparing catalog organization and README taxonomy against our `templates/catalog.json`
- identifying gaps in personas, engineering workflows, and design/research skills

Do not use for:

- direct import; this clone has no local `SKILL.md` files
- attribution to individual skill authors unless we follow links to the original repos and review those licenses directly

### `microsoft/skills`

Use for:

- Azure SDK and Microsoft AI Foundry project profiles
- language-specific Azure skill discovery for .NET, Java, Python, Rust, and TypeScript
- Azure service areas such as Identity, Cosmos DB, Event Hubs, Service Bus, Key Vault, Storage, Monitor, AI Search, M365 agents, and Foundry models
- installer UX ideas around selective skill loading and cross-agent symlink setup

Potential future profile candidates:

- `azure-typescript`
- `azure-python`
- `azure-dotnet`
- `azure-java`
- `azure-rust`
- `microsoft-foundry`
- `m365-agents`

Do not use for:

- default project scaffolding; the repo is large and cloud-vendor-specific
- wholesale import of all 189 local skills
- non-Azure projects, except as a reference for selective installation patterns

Recommendation: keep as an optional Azure/Microsoft profile source. Import only a small language/service subset when a real target project needs it.

## Proposed Integration Plan

1. Add `templates/skills/` as the reviewed, reusable skill output area.
2. Add `docs/external-source-policy.md` covering license/provenance rules before importing upstream skill content.
3. Import/adapt `addyosmani/agent-skills` lifecycle skills first.
4. Import/adapt `planning-with-files` as the persistent planning profile.
5. Import/adapt Rust skills.
6. Add a `frontend-design` profile based on Impeccable references, not the full executable system.
7. Mine `alirezarezvani/claude-skills` for gaps after Addy/Rust/Planning are in place.
8. Fill PM gaps from `phuryn/pm-skills`, skipping duplicates and legal/resume skills.
9. Add a Vue/frontend-toolchain import batch from `antfu/skills` after deciding whether to add a `frontend-vue` bundle.
10. Add a web quality import batch from `addyosmani/web-quality-skills`.
11. Add an infrastructure bundle seeded by `antonbabenko/terraform-skill`.
12. Mine `softaworks/agent-toolkit` for architecture, handoff, QA, and documentation gaps.
13. Use `microsoft/skills` only for optional Azure/Microsoft profiles.
14. Use `trailofbits/skills` as a security-audit reference until a CC BY-SA import strategy is agreed.
15. Add a catalog manifest with source repo, commit SHA, license, imported files, adaptation notes, and review date.

## Suggested First Import Batch

Smallest useful batch:

- `context-engineering`
- `spec-driven-development`
- `planning-and-task-breakdown`
- `test-driven-development`
- `code-review-and-quality`
- `debugging-and-error-recovery`
- `source-driven-development`
- `planning-with-files`
- `rust-core`
- `lint-hunter`
- `frontend-design-review` adapted from Impeccable
- `opportunity-solution-tree`
- `interview-script`
- `ab-test-analysis`
- `north-star-metric`

This gives the repo a coherent set of engineering lifecycle, Rust, frontend design, and product discovery capabilities without turning it into an unreviewed skill dump.
