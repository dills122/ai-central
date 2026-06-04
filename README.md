# AI Central

Central library for AI steering files, agent instructions, Cursor rules, and Codex skills collected from local projects.

## Layout

- `collected/` preserves raw source files copied from existing projects with provenance kept in the folder names.
- `templates/` contains normalized starters intended for reuse in new or existing projects.
- `templates/skills/` contains reviewed imported and adapted skills.
- `templates/catalog.json` describes available profiles and bundles.
- `docs/` contains inventory, classification, and review notes.
- `docs/source-manifest.sha256` records hashes for collected source files.
- `scripts/` contains local helpers for scaffolding AI context into project repos.

## First Pass Sources

Scanned `/Users/dsteele/repos` on 2026-06-04 and collected:

- 17 Codex steering files from `footy-data-kit` and `trove`
- 10 `AGENTS.md` files from project and app roots
- 13 Cursor/Payload CMS rules from `breakerflow-platform/apps/cms`
- 33 first-party Codex skills from `wap-labs/.codex/skills`

## Quick Start

Run the guided setup for a new or existing project:

```sh
./scripts/setup-ai-context.sh /path/to/project
```

Create baseline Codex context in another project:

```sh
./scripts/scaffold-ai-context.sh /path/to/project --profile angular
```

Use `--profile base` for stack-neutral files, `--profile angular` for Angular-oriented steering, `--profile frontend-design` for UI quality steering, or `--profile payload` for Payload CMS Cursor rules.

Install reviewed skill bundles:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

Bundles: `core`, `engineering`, `rust`, `product`, `planning`, `frontend`, `all`.

Refresh collected source material from local repos:

```sh
./scripts/collect-ai-context.sh /Users/dsteele/repos
```

Run local checks:

```sh
./scripts/check.sh
```

## Maintenance Commands

```sh
./scripts/check.sh
./scripts/setup-ai-context.sh /path/to/project --yes --dry-run
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
- [Setup CLI](docs/setup-cli.md)
- [Scaffold profiles](docs/scaffold-profiles.md)
- [Template authoring](docs/template-authoring.md)
- [Template taxonomy](docs/template-taxonomy.md)
- [Skill bundles](docs/skill-bundles.md)
- [External skill review](docs/external-skill-review.md)
- [External source policy](docs/external-source-policy.md)
- [Skill attribution](docs/skill-attribution.md)
- [Contributing](CONTRIBUTING.md)
- [Security notes](SECURITY.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)
