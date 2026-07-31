# Setup CLI

Use `scripts/setup-ai-context.sh` as the guided entrypoint for installing steering files and skills into a new or existing project.

```sh
./scripts/setup-ai-context.sh /path/to/project
```

The setup script:

- detects project signals such as `package.json`, `angular.json`, Kotlin/Gradle Kotlin DSL files,
  `Cargo.toml`, Terraform/OpenTofu files, Payload config files, Vue/Nuxt files, frontend source files,
  and docs/product folders
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

For a Kotlin/JVM project, explicitly pull both layers with:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,kotlin-jvm \
  --bundles core,jvm \
  --yes
```

When Kotlin source or Gradle Kotlin DSL is detected, the guided defaults select both
`kotlin-jvm` and `jvm` automatically.

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

## Profiles

Profiles install steering/context files:

| Profile | Purpose |
| --- | --- |
| `base` | Generic AGENTS and Codex steering |
| `angular` | Angular-specific steering |
| `kotlin-jvm` | Kotlin/JVM architecture, Gradle toolchain, coroutine, persistence, contract, and testing steering |
| `payload` | Payload CMS Cursor rules |
| `frontend-design` | Frontend UI quality, accessibility, responsive, and interaction-state steering |
| `infrastructure-opentofu` | OpenTofu state, secrets, validation, plan/apply, recovery, and network-safety steering |

## Bundles

Bundles install reusable skills:

| Bundle | Purpose |
| --- | --- |
| `core` | Safe default task, planning, review, debugging, source-driven, and frontend review skills |
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
| `workflow` | Architecture diagrams, handoffs, requirements clarity, QA planning, docs, Mermaid, OpenAPI TypeScript, and React workflow skills |
| `all` | Everything above |

## Overwrite Policy

All underlying installers skip existing files and directories.

This makes setup safe for existing projects, but it also means updates require manual review of skipped files.
