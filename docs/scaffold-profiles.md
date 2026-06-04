# Scaffold Profiles

The scaffold script installs non-overwriting AI context into a target project.

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile base
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

## Payload

Includes everything from `base`, plus:

- `.cursor/rules/payload-overview.md`

Use for Payload CMS projects or app folders.

## Idempotency

The script skips existing files. It does not merge or overwrite.

For existing projects, inspect skipped files manually before deciding whether to copy template changes across.
