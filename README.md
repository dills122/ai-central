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

A focused Reef review on 2026-07-31 promoted a reusable Kotlin/JVM steering profile and skill. Reef's
trading-platform and repository-specific source context was reviewed locally but is not retained in
the reusable library. A broader 44-checkout review promoted Rust and shell/scripting profiles while
likewise leaving project-specific source context in its originating repositories.

A primary-source language review on 2026-07-31 strengthened the JavaScript/TypeScript, Kotlin/JVM,
Rust, and POSIX shell templates with strict, domain-neutral engineering and verification standards.

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

Bundles: `core`, `brevity`, `engineering`, `jvm`, `rust`, `product`, `planning`, `frontend`, `frontend-tooling`, `frontend-vue`, `hallmark`, `infra`, `workflow`, `all`.

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
- [Language steering research (2026-07-31)](docs/language-steering-research-2026-07-31.md)
- [External source policy](docs/external-source-policy.md)
- [Skill attribution](docs/skill-attribution.md)
- [Contributing](CONTRIBUTING.md)
- [Security notes](SECURITY.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)
