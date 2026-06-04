# Setup CLI

Use `scripts/setup-ai-context.sh` as the guided entrypoint for installing steering files and skills into a new or existing project.

```sh
./scripts/setup-ai-context.sh /path/to/project
```

The setup script:

- detects project signals such as `package.json`, `angular.json`, `Cargo.toml`, Payload config files, frontend source files, and docs/product folders
- recommends steering profiles and skill bundles
- prompts for custom inclusion/exclusion
- calls the existing non-overwriting installers

The current profile and bundle catalog is documented in `templates/catalog.json`.

## Non-Interactive Mode

Use detected recommendations without prompts:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes
```

Use explicit selections:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --profiles base,angular,frontend-design \
  --bundles core,frontend,product
```

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
| `payload` | Payload CMS Cursor rules |
| `frontend-design` | Frontend UI quality, accessibility, responsive, and interaction-state steering |

## Bundles

Bundles install reusable skills:

| Bundle | Purpose |
| --- | --- |
| `core` | Safe default task, planning, review, debugging, source-driven, and frontend review skills |
| `engineering` | Broader engineering lifecycle, architecture, CI, security, observability, migration, and tooling skills |
| `rust` | Rust implementation, lint, debug, security, Pest, and RON skills |
| `product` | PM, research, analytics, GTM, strategy, and code-to-PRD skills |
| `planning` | Full and lightweight planning-file workflows |
| `frontend` | Frontend, browser testing, accessibility, Playwright review, and design-system skills |
| `all` | Everything above |

## Overwrite Policy

All underlying installers skip existing files and directories.

This makes setup safe for existing projects, but it also means updates require manual review of skipped files.
