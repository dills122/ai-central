# AI Central

Central library for AI steering files, agent instructions, Cursor rules, and Codex skills collected from local projects.

## Layout

- `collected/` preserves raw source files copied from existing projects with provenance kept in the folder names.
- `templates/` contains normalized starters intended for reuse in new or existing projects.
- `templates/skills/` contains reviewed imported and adapted skills.
- `templates/catalog.json` describes available profiles and bundles.
- `packages/apm/` contains generated Agent Package Manager manifests for every skill bundle.
- `docs/` contains inventory, classification, and review notes.
- `docs/source-manifest.sha256` records hashes for collected source files.
- `scripts/` contains local helpers for scaffolding AI context into project repos.

## First Pass Sources

Scanned `/Users/dsteele/repos` on 2026-06-04 and collected:

- 17 Codex steering files from `footy-data-kit` and `trove`
- 10 `AGENTS.md` files from project and app roots
- 13 Cursor/Payload CMS rules from `breakerflow-platform/apps/cms`
- 33 first-party Codex skills from `wap-labs/.codex/skills`

A focused Reef review on 2026-07-31 promoted a reusable Kotlin/JVM steering profile and skill. Reef's
trading-platform and repository-specific source context was reviewed locally but is not retained in
the reusable library. A broader 44-checkout review promoted Rust and shell/scripting profiles while
likewise leaving project-specific source context in its originating repositories.

A primary-source language review on 2026-07-31 strengthened the JavaScript/TypeScript, Kotlin/JVM,
Rust, and POSIX shell templates with strict, domain-neutral engineering and verification standards.

## What Is Included

AI Central has two reusable layers:

- **Profiles** install durable repository guidance such as `AGENTS.md`, language rules, testing
  expectations, and frontend or infrastructure steering.
- **Bundles** install task-oriented Codex skills under `.agents/skills/`, with compatibility
  symlinks under `.codex/skills/`. Skills load when relevant; they are not runtime dependencies.

The current checkout contains 131 reusable `SKILL.md` definitions under `templates/skills/`. The
`all` meta-bundle installs 134 named skill directories because three imported skills are retained
but intentionally unbundled, while Playwright and five compact-bundle dependencies are also
exposed under historical prefixed names by older broad bundles. Another 33 Wap Labs skills are
preserved as collected source material and are not installed by any bundle.

For provenance and licenses, see [Skill attribution](docs/skill-attribution.md) and
[Third-party notices](THIRD_PARTY_NOTICES.md).

### Choose A Starting Point

| Project or task | Profiles | Bundles | Notes |
| --- | --- | --- | --- |
| Any repository | `base` | `core` | Safe default for planning, testing, review, debugging, and source-driven work. |
| Larger spec-driven project coordinated from a lead task | matching project profiles | `core,orchestration` | Adds multi-agent dispatch, traceability, retained research, handoffs, and reconciliation without the full catalog. |
| Documentation or architecture maintenance | matching project profiles | `core,documentation` | Adds doc-drift auditing, ADRs, READMEs, Mermaid, and C4 architecture. |
| Implementation through release readiness | matching project profiles | `core,delivery` | Adds incremental delivery, Git workflow, simplification, CI, self-evaluation, ship gates, and launch checks. |
| JavaScript or TypeScript | `base,javascript-typescript` | `core` | Adds strict typing, ESM, dependency, async, boundary, security, and verification rules. |
| User-facing frontend | `base,javascript-typescript,frontend-design` | `core,frontend` | Adds UI implementation, accessibility, browser testing, Playwright review, and web-quality skills. |
| Angular frontend | `base,angular,frontend-design` | `core,frontend` | Adds Angular steering on top of the frontend baseline. |
| Vue or Nuxt frontend | `base,javascript-typescript,frontend-design` | `core,frontend,frontend-vue` | Adds Vue, Nuxt, Pinia, Vue Router, VueUse, UnoCSS, and Vue testing guidance. |
| Frontend using most of Vite, Vitest, pnpm, and Turborepo | matching language/frontend profiles | `frontend-tooling` | The bundle also includes VitePress and Slidev; skip it when most of the toolset is irrelevant. |
| Payload CMS | `base,javascript-typescript,payload` | `core` plus `frontend` when UI work is in scope | Adds Payload-specific Cursor rules without making them global frontend policy. |
| Kotlin/JVM | `base,kotlin-jvm` | `core,jvm` | Guided setup detects Kotlin and Gradle Kotlin DSL automatically. |
| Rust | `base,rust` | `core,rust` | Guided setup detects Cargo workspaces automatically. |
| Shared shell, CI, bootstrap, or release automation | `base,shell-scripting` | `core` | Adds POSIX-first interfaces, quoting, cleanup, portability, and safety boundaries. |
| Terraform or OpenTofu | `base,infrastructure-opentofu` | `core,infra` | Separates durable infrastructure policy from detailed implementation workflow. |
| Long-running or multi-session work | matching project profiles | `core,planning` | Adds the full persistent planning-files workflow. |
| Technical blog, engineering retrospective, or project journey | matching project profiles | `writing` | Mines a sourced project timeline, drafts the technical story, and offers an optional final prose audit. |
| Architecture, handoffs, API contracts, or React workflow | matching project profiles | `core,workflow` | Adds diagrams, requirements, QA, README, OpenAPI, and React skills. |
| Product discovery or strategy | `base` or matching project profiles | `core,product` | Adds research, analytics, GTM, product strategy, and code-to-PRD skills. |
| Distinctive landing page, redesign, or design study | matching frontend profiles | `core,frontend,hallmark` | Keeps the creative-direction workflow opt-in instead of applying it to routine product UI. |
| Broad specialist engineering work | matching project profiles | `core,engineering` | Large opt-in bundle for architecture, CI, security, observability, migrations, and shipping. |

Prefer the smallest relevant selection. Repository-specific instructions take precedence over
reusable profiles and skills, and the installers skip existing files instead of overwriting them.

### Steering Profiles

| Profile | Installs or covers | Choose it when |
| --- | --- | --- |
| `base` | Generic `AGENTS.md`, repository scope, and testing/quality-gate steering | Every repository |
| `javascript-typescript` | Strict JS/TS runtime, typing, async, dependency, API, security, performance, and verification guidance | The repository contains JS, TS, Node.js, or browser code |
| `angular` | Angular architecture and implementation guidance, plus the JS/TS baseline | The repository contains Angular apps or packages |
| `kotlin-jvm` | Kotlin, Gradle, JVM toolchains, coroutines, APIs, compatibility, and layered testing | The repository contains Kotlin or Gradle Kotlin DSL |
| `rust` | Rust toolchains, ownership, APIs, unsafe code, dependencies, concurrency, and verification | The repository contains Rust crates or workspaces |
| `shell-scripting` | POSIX-first scripting, quoting, cleanup, destructive boundaries, portability, and testing | Shared shell, CI, container, bootstrap, or release scripts are substantial |
| `frontend-design` | UI quality, accessibility, responsiveness, content hierarchy, and interaction states | The repository has user-facing UI |
| `payload` | Payload CMS Cursor rules and implementation guidance | The repository uses Payload CMS |
| `infrastructure-opentofu` | State, secrets, plan/apply, recovery, lifecycle, and network-safety steering | The repository manages Terraform or OpenTofu infrastructure |

### Skill Bundles

| Bundle | Skill count | Use it for |
| --- | ---: | --- |
| `core` | 9 | Small default for context, specifications, planning, TDD, review, debugging, source-driven work, and safe GitHub authentication |
| `orchestration` | 6 | Brain-task planning, multi-agent dispatch, traceability, handoffs, research, and doubt-driven investigation |
| `documentation` | 5 | Canonical docs, drift audits, ADRs, READMEs, Mermaid, and C4 architecture |
| `delivery` | 7 | Incremental implementation, Git workflow, simplification, CI, self-evaluation, ship gates, and launch readiness |
| `brevity` | 5 | Opt-in terse responses, help, commit messages, review comments, and context compression |
| `engineering` | 42 | Full engineering lifecycle plus architecture, CI, security, dependencies, observability, migrations, SLOs, and shipping |
| `jvm` | 1 | Kotlin/JVM and Gradle implementation workflow |
| `rust` | 8 | Rust implementation, syntax, linting, debugging, security, Pest, and RON |
| `product` | 25 | Product discovery, analytics, market research, GTM, strategy, design systems, and code-to-PRD |
| `planning` | 2 | Lightweight and full persistent planning-file workflows |
| `frontend` | 12 | UI implementation and review, browser testing, accessibility, Playwright, performance, SEO, and Core Web Vitals |
| `frontend-tooling` | 6 | Vite, Vitest, pnpm, Turborepo, VitePress, and Slidev |
| `frontend-vue` | 8 | Vue, Nuxt, Pinia, Vue Router, VueUse, UnoCSS, and Vue testing |
| `hallmark` | 1 | Opt-in creative direction for distinctive pages, redesigns, audits, and design studies |
| `infra` | 1 | Terraform/OpenTofu review, debugging, state, CI, testing, security, and rollback |
| `writing` | 3 | Project-story evidence mining, technical blog drafting and editing, and final prose auditing |
| `workflow` | 13 | Architecture diagrams, handoffs, requirements, QA planning, READMEs, OpenAPI TypeScript, and React |
| `all` | 134 installed directories | Every bundle above; useful for auditing, not recommended as a routine project default |

### Complete Bundled Skill Catalog

Installed names are shown below. Prefixes such as `claude-`, `pm-`, `rust-`, `toolkit-`, and
`web-` prevent collisions between imported sources.

<details>
<summary><code>core</code> — 9 skills</summary>

- `github-keychain-auth`
- `planning-files-lite`
- `context-engineering`
- `spec-driven-development`
- `planning-and-task-breakdown`
- `test-driven-development`
- `code-review-and-quality`
- `debugging-and-error-recovery`
- `source-driven-development`

</details>

<details>
<summary><code>orchestration</code> — 6 skills</summary>

- `orchestrated-delivery`
- `spec-traceability`
- `session-handoff`
- `research-to-decision`
- `planning-with-files`
- `doubt-driven-development`

</details>

<details>
<summary><code>documentation</code> — 5 skills</summary>

- `repository-doc-drift`
- `documentation-and-adrs`
- `crafting-effective-readmes`
- `mermaid-diagrams`
- `c4-architecture`

</details>

<details>
<summary><code>delivery</code> — 7 skills</summary>

- `incremental-implementation`
- `git-workflow-and-versioning`
- `code-simplification`
- `ci-cd-and-automation`
- `shipping-and-launch`
- `self-eval`
- `ship-gate`

</details>

<details>
<summary><code>brevity</code> — 5 skills</summary>

- `caveman`
- `caveman-help`
- `caveman-commit`
- `caveman-review`
- `caveman-compress`

</details>

<details>
<summary><code>engineering</code> — 42 skills</summary>

Engineering lifecycle skills:

- `api-and-interface-design`
- `browser-testing-with-devtools`
- `ci-cd-and-automation`
- `code-review-and-quality`
- `code-simplification`
- `context-engineering`
- `debugging-and-error-recovery`
- `deprecation-and-migration`
- `documentation-and-adrs`
- `doubt-driven-development`
- `frontend-ui-engineering`
- `git-workflow-and-versioning`
- `idea-refine`
- `incremental-implementation`
- `interview-me`
- `performance-optimization`
- `planning-and-task-breakdown`
- `security-and-hardening`
- `shipping-and-launch`
- `source-driven-development`
- `spec-driven-development`
- `test-driven-development`
- `using-agent-skills`

Specialist engineering skills:

- `claude-a11y-audit`
- `claude-api-design-reviewer`
- `claude-api-test-suite-builder`
- `claude-browser-automation`
- `claude-ci-cd-pipeline-builder`
- `claude-dependency-auditor`
- `claude-env-secrets-manager`
- `claude-feature-flags-architect`
- `claude-migration-architect`
- `claude-monorepo-navigator`
- `claude-observability-designer`
- `claude-performance-profiler`
- `claude-review`
- `claude-runbook-generator`
- `claude-self-eval`
- `claude-ship-gate`
- `claude-slo-architect`
- `claude-spec-driven-workflow`
- `claude-terraform-patterns`

</details>

<details>
<summary><code>jvm</code> — 1 skill</summary>

- `kotlin-jvm-engineering`

</details>

<details>
<summary><code>rust</code> — 8 skills</summary>

- `rust-general-debug`
- `rust-general-security`
- `rust-general-syntax`
- `rust-lint-hunter`
- `rust-pest-specialist`
- `rust-ron-specialist`
- `rust-router`
- `rust-rust-core`

</details>

<details>
<summary><code>product</code> — 25 skills</summary>

- `claude-code-to-prd`
- `claude-spec-to-repo`
- `claude-ui-design-system`
- `pm-ab-test-analysis`
- `pm-brainstorm-experiments-new`
- `pm-brainstorm-ideas-new`
- `pm-business-model`
- `pm-cohort-analysis`
- `pm-competitive-battlecard`
- `pm-competitor-analysis`
- `pm-customer-journey-map`
- `pm-gtm-strategy`
- `pm-ideal-customer-profile`
- `pm-identify-assumptions-new`
- `pm-interview-script`
- `pm-lean-canvas`
- `pm-market-sizing`
- `pm-north-star-metric`
- `pm-opportunity-solution-tree`
- `pm-positioning-ideas`
- `pm-pricing-strategy`
- `pm-product-strategy`
- `pm-product-vision`
- `pm-user-personas`
- `pm-value-prop-statements`

</details>

<details>
<summary><code>planning</code> — 2 skills</summary>

- `planning-files-lite`
- `planning-with-files`

</details>

<details>
<summary><code>frontend</code> — 12 skills</summary>

- `frontend-design-review`
- `frontend-ui-engineering`
- `browser-testing-with-devtools`
- `claude-a11y-audit`
- `claude-playwright-review`
- `claude-ui-design-system`
- `web-accessibility`
- `web-best-practices`
- `web-core-web-vitals`
- `web-performance`
- `web-seo`
- `web-web-quality-audit`

</details>

<details>
<summary><code>frontend-tooling</code> — 6 skills</summary>

- `vite`
- `vitest`
- `pnpm`
- `turborepo`
- `vitepress`
- `slidev`

</details>

<details>
<summary><code>frontend-vue</code> — 8 skills</summary>

- `vue`
- `vue-best-practices`
- `vue-router-best-practices`
- `vue-testing-best-practices`
- `nuxt`
- `pinia`
- `vueuse-functions`
- `unocss`

</details>

<details>
<summary><code>hallmark</code> — 1 skill</summary>

- `hallmark-design`

</details>

<details>
<summary><code>infra</code> — 1 skill</summary>

- `terraform-skill`

</details>

<details>
<summary><code>writing</code> — 3 skills</summary>

- `project-story-miner`
- `technical-blog-writer`
- `humanizer`

</details>

<details>
<summary><code>workflow</code> — 13 skills</summary>

- `toolkit-backend-to-frontend-handoff-docs`
- `toolkit-c4-architecture`
- `toolkit-crafting-effective-readmes`
- `toolkit-database-schema-designer`
- `toolkit-design-system-starter`
- `toolkit-frontend-to-backend-requirements`
- `toolkit-mermaid-diagrams`
- `toolkit-openapi-to-typescript`
- `toolkit-qa-test-planner`
- `toolkit-react-dev`
- `toolkit-react-useeffect`
- `toolkit-requirements-clarity`
- `toolkit-session-handoff`

</details>

### Reusable Skills Not Included In A Bundle

These imported skills are available under `templates/skills/` for review or manual installation,
but `install-skill-bundle.sh` does not currently select them:

- `web-design-guidelines` from `antfu/skills`
- `cavecrew` from `JuliusBrussee/caveman`
- `caveman-stats` from `JuliusBrussee/caveman`

### Collected Skills Not Yet Promoted

The following 33 skills are preserved under `collected/codex-skills/wap-labs/`. They are historical
source material, not normalized templates, and are not installed by any bundle:

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

## Quick Start

Run the guided setup for a new or existing project:

```sh
./scripts/setup-ai-context.sh /path/to/project
```

Use symlinks for reusable skills and generic steering:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode link
```

Create baseline Codex context in another project:

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile angular
```

Use `--profile base` for stack-neutral files, `--profile javascript-typescript` for JavaScript and
TypeScript guidance, `--profile angular` for Angular-oriented steering, `--profile kotlin-jvm` for
Kotlin/JVM and Gradle guidance, `--profile rust` for Rust guidance, `--profile shell-scripting` for
portable automation guidance, `--profile frontend-design` for UI quality steering, `--profile
payload` for Payload CMS Cursor rules, or `--profile infrastructure-opentofu` for infrastructure
lifecycle and safety steering.

Install reviewed skill bundles:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

Bundles: `core`, `orchestration`, `documentation`, `delivery`, `brevity`, `engineering`, `jvm`,
`rust`, `product`, `planning`, `frontend`, `frontend-tooling`, `frontend-vue`, `hallmark`, `infra`,
`writing`, `workflow`, `all`.

Audit a project's installed AI context:

```sh
./scripts/audit-ai-context.sh /path/to/project
```

Install any bundle through [Microsoft APM](https://microsoft.github.io/apm/):

```sh
apm install dills122/ai-central/packages/apm/core#main --target agent-skills
apm install dills122/ai-central/packages/apm/orchestration#main --target agent-skills
apm install dills122/ai-central/packages/apm/writing#main --target agent-skills
./scripts/check-apm.sh
```

Use the matching directory under `packages/apm/` for any listed bundle, including `all`. See
[Agent Package Manager integration](docs/apm.md) for aliases, lockfile workflow, compatibility
behavior, and the current APM 0.28.0 audit limitations.

Refresh collected source material from local repos:

```sh
./scripts/collect-ai-context.sh /Users/dsteele/repos
```

Run local checks:

```sh
./scripts/check.sh
./scripts/check-apm.sh
```

## Maintenance Commands

```sh
./scripts/check.sh
./scripts/setup-ai-context.sh /path/to/project --yes --dry-run
./scripts/setup-ai-context.sh /path/to/project --yes --mode link --dry-run
./scripts/refresh-source-manifest.sh
./scripts/collect-ai-context.sh /Users/dsteele/repos
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

## Review Workflow

1. Review `docs/inventory.md` for what was found and where it came from.
2. Review `docs/reuse-candidates.md` for what should be promoted, templated, or kept as project-specific reference.
3. Use `docs/source-manifest.sha256` to spot source changes after future collection runs.
4. Update files in `templates/` first; leave `collected/` as historical source material.
5. Use `scripts/scaffold-ai-context.sh` to install selected templates into target projects.

## Docs

- [Collection workflow](docs/collection-workflow.md)
- [CI](docs/ci.md)
- [Setup CLI](docs/setup-cli.md)
- [Link mode](docs/link-mode.md)
- [Scaffold profiles](docs/scaffold-profiles.md)
- [Template authoring](docs/template-authoring.md)
- [Template taxonomy](docs/template-taxonomy.md)
- [Skill bundles](docs/skill-bundles.md)
- [External skill review](docs/external-skill-review.md)
- [Context-management audit (2026-07)](docs/context-management-audit-2026-07.md)
- [Repository AI-context audit (2026-07-31)](docs/repository-ai-context-audit-2026-07-31.md)
- [Workflow skill audit and bundle decision (2026-08-12)](docs/workflow-skill-audit-2026-08-12.md)
- [Language steering research (2026-07-31)](docs/language-steering-research-2026-07-31.md)
- [External source policy](docs/external-source-policy.md)
- [Skill attribution](docs/skill-attribution.md)
- [Agent Package Manager integration](docs/apm.md)
- [Contributing](CONTRIBUTING.md)
- [Security notes](SECURITY.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)
