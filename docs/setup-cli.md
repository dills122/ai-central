# Setup CLI

Use `scripts/setup-ai-context.sh` as the guided entrypoint for installing steering files and skills into a new or existing project.

```sh
./scripts/setup-ai-context.sh /path/to/project
```

The setup script:

- detects concrete project signals such as a root `package.json` or `angular.json`, Kotlin/Gradle
  Kotlin DSL files, `Cargo.toml`, Terraform/OpenTofu files, Payload config files, and active
  Vue/Nuxt or frontend source files
- recommends steering profiles and skill bundles
- prompts for custom inclusion/exclusion
- calls the existing non-overwriting installers

The current profile and bundle catalog is documented in `templates/catalog.json`.

See `docs/link-mode.md` for the symlink strategy and tradeoffs.

## Non-Interactive Mode

Use detected recommendations without prompts:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes
```

Use symlinks for reusable skills and generic steering:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode link
```

Use explicit selections:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,angular,frontend-design \
  --bundles core,brevity,frontend,product
```

Tailor bundle output by exact installed skill name:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,angular,frontend-design,infrastructure-opentofu \
  --bundles core,node,orchestration,brevity,engineering,frontend,frontend-tooling,hallmark,infra \
  --skip-skills vite,vitest,turborepo,vitepress,slidev,claude-browser-automation \
  --mode link \
  --sync \
  --yes \
  --dry-run
```

`--skills` adds comma-separated installed names after bundle expansion. `--skip-skills` removes
installed names after both bundle expansion and exact additions, so an exclusion wins if a name is
present in both options. The setup command validates every exact name before it writes profile
files.

Use `--bundles none --skills name-a,name-b` for a fully explicit skill selection. `none` cannot be
combined with another bundle.

For a Kotlin/JVM project, explicitly pull both layers with:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,kotlin-jvm \
  --bundles core,jvm \
  --yes
```

When Kotlin source or Gradle Kotlin DSL is detected, the guided defaults select both
`kotlin-jvm` and `jvm` automatically.

When a root `package.json` is detected, the guided defaults select the `javascript-typescript`
profile and the compact `node` package-inspection bundle automatically.

Exclude recommendations:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --yes \
  --skip-bundles product
```

Preview without writing:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --dry-run
```

The preview reports each final create, link, skip, and managed-link removal exactly once. It does
not create parent directories or otherwise change the target.

## Synchronizing A Link Installation

Normal setup remains additive and non-overwriting. In link mode, opt into exact reconciliation of
AI Central-managed skill links with `--sync`:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --yes \
  --bundles core,frontend-tooling \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --mode link \
  --sync \
  --dry-run
```

Sync is deliberately conservative. It removes a deselected canonical link only when its installed
name is in the current AI Central catalog and its symlink target exactly matches that name's source
in the current checkout. It removes the matching `.codex/skills` compatibility link only when that
link has the expected canonical target. It leaves real directories, copied skills, adopted legacy
skills, broken or foreign links, and project-repointed links untouched. This proof is why `--sync`
requires `--mode link`.

## Profiles

Profiles install steering/context files:

| Profile | Purpose |
| --- | --- |
| `base` | Generic AGENTS and Codex steering |
| `javascript-typescript` | Strict JavaScript/TypeScript typing, ESM, boundary, async, dependency, security, performance, and verification steering |
| `angular` | Angular-specific steering |
| `kotlin-jvm` | Strict Kotlin/JVM and Gradle toolchain, dependency, API, coroutine, boundary, security, performance, and verification steering |
| `rust` | Strict Rust toolchain, ownership, API, unsafe, dependency, concurrency, performance, and verification steering |
| `shell-scripting` | Strict POSIX-first interfaces, quoting, failure handling, cleanup, security, portability, and verification steering |
| `payload` | Payload CMS Cursor rules |
| `frontend-design` | Frontend UI quality, accessibility, responsive, and interaction-state steering |
| `infrastructure-opentofu` | OpenTofu state, secrets, validation, plan/apply, recovery, and network-safety steering |

## Bundles

Bundles install reusable skills:

| Bundle | Purpose |
| --- | --- |
| `core` | Small universal baseline for context, specs, planning, tests, review, debugging, source-driven work, and safe GitHub authentication |
| `node` | Installed Node package API, declaration, export-condition, and subpath inspection |
| `orchestration` | Brain-task planning, multi-agent dispatch, spec traceability, durable handoffs, research, and reconciliation |
| `documentation` | Canonical documentation, ADRs, drift audits, READMEs, Mermaid, and C4 architecture |
| `delivery` | Incremental implementation, Git workflow, simplification, CI, self-evaluation, ship gates, and launch readiness |
| `brevity` | Caveman token-saving skills for terse replies, commit messages, review comments, help, and memory-file compression |
| `engineering` | Broader engineering lifecycle, architecture, CI, security, observability, migration, and tooling skills |
| `jvm` | Kotlin/JVM implementation, Gradle toolchain, coroutine, architecture, persistence, contract, and verification skill |
| `rust` | Rust implementation, lint, debug, security, Pest, and RON skills |
| `product` | PM, research, analytics, GTM, strategy, and code-to-PRD skills |
| `planning` | Full and lightweight planning-file workflows |
| `frontend` | General frontend design, browser testing, accessibility, Playwright review, design-system, and web quality skills |
| `frontend-tooling` | Vite, Vitest, pnpm, Turborepo, VitePress, and Slidev; select only for matching projects |
| `frontend-vue` | Vue, Nuxt, Pinia, Vue Router, VueUse, UnoCSS, and Vue testing skills |
| `hallmark` | Creative-direction workflow for intentional pages, redesigns, audits, and design studies |
| `infra` | Terraform/OpenTofu review, debugging, CI, state, security, testing, and rollback guidance |
| `writing` | Project-story evidence mining, technical blog drafting and editing, and final prose auditing |
| `workflow` | Architecture diagrams, handoffs, requirements clarity, QA planning, docs, Mermaid, OpenAPI TypeScript, and React workflow skills |
| `all` | Everything above |

## Overwrite Policy

All underlying installers skip existing files and directories.

Skills are installed canonically under `.agents/skills`. Fresh installs also receive per-skill
compatibility symlinks under `.codex/skills`. Existing real legacy skills are left untouched and
linked into canonical discovery instead of being moved or duplicated.

This makes setup safe for existing projects, but updates to skipped files still require manual
review. `--sync` changes only the narrow managed-link case described above; it is not a general
delete or update mode. Use `scripts/audit-ai-context.sh /path/to/project` to find layout and
placeholder problems.

Every bundle also has a generated APM manifest under `packages/apm/<bundle>/`. See `docs/apm.md`
for managed installation, aliases, lockfiles, and audit limitations.
