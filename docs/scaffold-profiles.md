# Scaffold Profiles

The scaffold script installs non-overwriting AI context into a target project.

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile base
```

Use `--mode link` to symlink reusable steering while still copying repo-specific files:

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile frontend-design --mode link
```

## Base

Installs:

- `AGENTS.md`
- `.codex/steering/repository-steering.md`
- `.codex/steering/javascript-esm-steering.md`
- `.codex/steering/testing-quality-gates-steering.md`

Use for most JavaScript, TypeScript, or mixed web projects.

## Angular

Includes everything from `base`, plus:

- `.codex/steering/angular-steering.md`

Use for Angular apps and Angular monorepo packages.

## Frontend Design

Includes everything from `base`, plus:

- `.codex/steering/frontend-design-steering.md`

Use for user-facing apps, dashboards, landing pages, frontend components, and design-system work.

## Kotlin/JVM

Includes everything from `base`, plus:

- `.codex/steering/kotlin-jvm-steering.md`

Use for Kotlin/JVM services, libraries, CLI tools, and applications built with Gradle. Replace the
Kotlin root, JVM version, and verification command placeholders before treating the installed file
as project policy.

## Rust

Includes everything from `base`, plus:

- `.codex/steering/rust-steering.md`

Use for Rust crates and workspaces. Guided setup selects this profile and the existing `rust` skill
bundle when it detects `Cargo.toml`.

## Shell And Scripting

Includes everything from `base`, plus:

- `.codex/steering/shell-scripting-steering.md`

Use explicitly for repositories with substantial shared shell, CI, container, VM, hook, bootstrap,
or release automation. Replace the command and scripts-root placeholders before enforcing it.

## Payload

Includes everything from `base`, plus:

- `.cursor/rules/payload-overview.md`

Use for Payload CMS projects or app folders.

## Infrastructure And OpenTofu

Includes everything from `base`, plus:

- `.codex/steering/infrastructure-opentofu-steering.md`

Use for repositories with OpenTofu/Terraform compositions, modules, remote state, provider-backed
CI, or infrastructure operator workflows. Replace its project, version, platform, and command
placeholders before treating the installed file as enforceable policy.

The profile supplies durable repository steering. Pair it with the opt-in `infra` skill bundle
when agents also need the detailed Terraform/OpenTofu diagnosis and implementation workflow.

## Idempotency

The script skips existing files. It does not merge or overwrite.

For existing projects, inspect skipped files manually before deciding whether to copy template changes across.
