# AI Central

AI Central is a reusable library of AI coding guidance for software repositories. It combines:

- **steering profiles** for durable project guidance such as `AGENTS.md`, language rules, testing
  expectations, frontend standards, and infrastructure policy;
- **skill bundles** for task-oriented workflows such as planning, implementation, review,
  documentation, delivery, product work, and specialist engineering; and
- **non-overwriting installers** that add selected guidance to new or existing repositories.

Project-owned instructions always take precedence. AI Central supplies a reviewed starting point;
it is not intended to replace repository-specific context.

## Quick Start

From an AI Central checkout, run the guided setup against a new or existing project:

```sh
./scripts/setup-ai-context.sh /path/to/project
```

The setup script detects concrete project signals, recommends profiles and bundles, and prompts
before installing anything. Preview the same recommendations without writing files:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --dry-run
```

For a compact general-purpose installation, install the `core` bundle directly:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

Install the smallest relevant selection. The `all` bundle is intended for inventory audits, not
routine project setup.

## What Is Available

AI Central currently contains 131 reviewed reusable `SKILL.md` definitions. Related skills are
distributed as bundles so a project can expose only the capabilities it needs.

### Recommended Layers

| Bundle | Skills | Use it for |
| --- | ---: | --- |
| `core` | 9 | Context, specifications, planning, TDD, review, debugging, source-driven work, and safe GitHub authentication |
| `orchestration` | 6 | Multi-agent planning, dispatch, traceability, handoffs, retained research, and reconciliation |
| `documentation` | 5 | Documentation drift, ADRs, READMEs, Mermaid, and C4 architecture |
| `delivery` | 7 | Incremental implementation, Git workflow, simplification, CI, self-evaluation, ship gates, and launch readiness |

`core` is the universal default. Add the other layers only when that work is in scope.

### Specialist Bundles

| Bundle | Skills | Use it for |
| --- | ---: | --- |
| `brevity` | 5 | Terse replies, help, commits, review comments, and context compression |
| `engineering` | 42 | Architecture, APIs, CI, security, observability, migrations, performance, and shipping |
| `jvm` | 1 | Kotlin/JVM and Gradle implementation workflow |
| `rust` | 8 | Rust implementation, syntax, linting, debugging, security, Pest, and RON |
| `product` | 25 | Discovery, analytics, market research, GTM, product strategy, and code-to-PRD |
| `planning` | 2 | Lightweight and full persistent planning-file workflows |
| `frontend` | 12 | UI implementation, accessibility, browser testing, Playwright, performance, SEO, and Core Web Vitals |
| `frontend-tooling` | 6 | Vite, Vitest, pnpm, Turborepo, VitePress, and Slidev |
| `frontend-vue` | 8 | Vue, Nuxt, Pinia, Vue Router, VueUse, UnoCSS, and Vue testing |
| `hallmark` | 1 | Opt-in creative direction for distinctive pages, redesigns, audits, and design studies |
| `infra` | 1 | Terraform/OpenTofu review, debugging, state, CI, testing, security, and rollback |
| `writing` | 3 | Project-history research, technical story drafting, editing, and prose review |
| `workflow` | 13 | Architecture, handoffs, requirements, QA, documentation, OpenAPI, and React workflows |
| `all` | 134 installed names | Every bundle above, including compatibility aliases; useful for auditing only |

Some skills appear in more than one bundle, and a few older broad bundles expose historical
prefixed aliases. That is why bundle totals and installed names do not equal the number of source
definitions. See [Skill bundles](docs/skill-bundles.md) for selection guidance and
[`packages/apm/`](packages/apm/) for exact generated package contents.

### Steering Profiles

Profiles complement skills by installing durable repository guidance.

| Profile | Covers |
| --- | --- |
| `base` | Generic `AGENTS.md`, testing expectations, and repository policy |
| `javascript-typescript` | JavaScript, TypeScript, Node.js, browser, typing, async, dependency, security, and verification guidance |
| `angular` | Angular architecture and implementation guidance |
| `kotlin-jvm` | Kotlin, Gradle, JVM toolchains, coroutines, APIs, compatibility, and testing |
| `rust` | Rust toolchains, ownership, APIs, unsafe code, dependencies, concurrency, and verification |
| `shell-scripting` | POSIX-first scripting, quoting, cleanup, portability, and safety boundaries |
| `frontend-design` | UI quality, accessibility, responsiveness, content hierarchy, and interaction states |
| `payload` | Payload CMS Cursor rules and implementation guidance |
| `infrastructure-opentofu` | State, secrets, plan/apply, recovery, lifecycle, and network-safety guidance |

The machine-readable profile and bundle registry is [`templates/catalog.json`](templates/catalog.json).

## How Content Is Stored

AI Central keeps reusable material separate from historical source material:

| Location | Purpose |
| --- | --- |
| [`templates/`](templates/) | Reviewed, normalized steering and reusable templates |
| [`templates/skills/first-party/`](templates/skills/first-party/) | Skills authored for AI Central |
| [`templates/skills/imported/`](templates/skills/imported/) | Reviewed upstream skills retained substantially as published |
| [`templates/skills/adapted/`](templates/skills/adapted/) | Rewritten or condensed derivatives designed for portable use |
| [`packages/apm/`](packages/apm/) | Generated Agent Package Manager manifests for every bundle |
| [`collected/`](collected/) | Raw historical source material with provenance preserved |
| [`docs/`](docs/) | Setup, design, attribution, audit, and maintenance documentation |

Skills install canonically into `.agents/skills/<name>` in the target project. The shell
installers also create per-skill compatibility links under `.codex/skills/<name>` for older Codex
layouts. Existing files and directories are skipped rather than overwritten.

## Retrieving Skills And Steering

### Guided Project Setup

Use the guided entrypoint when you want both repository steering and skill recommendations:

```sh
./scripts/setup-ai-context.sh /path/to/project
```

For repeatable automation, accept detected recommendations or provide explicit selections:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,javascript-typescript,frontend-design \
  --bundles core,frontend,delivery \
  --yes
```

### Copy Or Link Mode

Copy mode places independent copies in the target repository and is the default. Link mode keeps
reusable content connected to the AI Central checkout, which is convenient for testing and
centrally managed local projects:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode link
```

See [Link mode](docs/link-mode.md) for portability and versioning trade-offs.

### Individual Bundle Installation

Use the bundle installer when the project already has steering or needs only skills:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
./scripts/install-skill-bundle.sh /path/to/project --bundle documentation --mode link
```

Audit an existing installation with:

```sh
./scripts/audit-ai-context.sh /path/to/project
```

### Codex-Managed Worktrees

When project context is intentionally kept in local Git exclusions, configure the Codex Local
Environment to seed it into every new managed worktree:

```sh
/path/to/ai-central/scripts/setup-codex-worktree.sh "$PWD"
```

The setup wrapper mirrors only allowlisted agent instructions, skills, steering, and Codex agent
definitions from the primary checkout. It preserves real files versus symlinks and never overwrites
worktree-owned paths. See [Codex worktree context](docs/codex-worktree-context.md).

### Agent Package Manager

Every bundle has a generated [Microsoft Agent Package Manager](https://microsoft.github.io/apm/)
package:

```sh
apm install dills122/ai-central/packages/apm/core#main --target agent-skills
apm install dills122/ai-central/packages/apm/orchestration#main --target agent-skills
```

Replace `core` or `orchestration` with any bundle listed above. APM installs skills only; use the
guided shell setup when you also need steering profiles or `.codex/skills` compatibility links.
See [Agent Package Manager integration](docs/apm.md) for lockfiles, aliases, and audit behavior.

## Developing AI Central

Fork or clone the repository, make small changes in the appropriate reusable layer, and run the
full local check:

```sh
git clone https://github.com/dills122/ai-central.git
cd ai-central
./scripts/check.sh
```

Useful development checks include:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --dry-run
./scripts/setup-ai-context.sh /path/to/project --yes --mode link --dry-run
./scripts/install-skill-bundle.sh /path/to/project --bundle core
./scripts/check-apm.sh
```

When contributing:

- treat `collected/` as historical source material rather than editing it directly;
- put reusable guidance in `templates/`;
- use placeholders such as `{{PROJECT_NAME}}` for project-specific values;
- keep shell helpers POSIX `sh` compatible unless a stronger shell is justified;
- preserve non-overwriting scaffold behavior; and
- record provenance, licenses, and promotion decisions for imported or adapted skills.

See [Contributing](CONTRIBUTING.md) and [Template authoring](docs/template-authoring.md) before
adding or promoting reusable material.

## Appendix: Further Reading

### Setup And Distribution

- [Setup CLI](docs/setup-cli.md)
- [Link mode](docs/link-mode.md)
- [Codex worktree context](docs/codex-worktree-context.md)
- [Scaffold profiles](docs/scaffold-profiles.md)
- [Skill bundles](docs/skill-bundles.md)
- [Agent Package Manager integration](docs/apm.md)
- [CI](docs/ci.md)

### Authoring And Governance

- [Contributing](CONTRIBUTING.md)
- [Template authoring](docs/template-authoring.md)
- [Template taxonomy](docs/template-taxonomy.md)
- [External source policy](docs/external-source-policy.md)
- [Skill attribution](docs/skill-attribution.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)
- [Security policy](SECURITY.md)

### Inventory, Decisions, And History

- [Project history](docs/project-history.md)
- [Inventory](docs/inventory.md)
- [Collection workflow](docs/collection-workflow.md)
- [Reuse candidates](docs/reuse-candidates.md)
- [External skill review](docs/external-skill-review.md)
- [Context-management audit (2026-07)](docs/context-management-audit-2026-07.md)
- [Repository AI-context audit (2026-07-31)](docs/repository-ai-context-audit-2026-07-31.md)
- [Workflow skill audit and bundle decision (2026-08-12)](docs/workflow-skill-audit-2026-08-12.md)
- [Language steering research (2026-07-31)](docs/language-steering-research-2026-07-31.md)
