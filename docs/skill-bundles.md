# Skill Bundles

Use `scripts/install-skill-bundle.sh` to install reviewed skills into a target project's canonical
`.agents/skills` directory. The installer also creates per-skill compatibility symlinks under
`.codex/skills`, so older Codex configurations continue to resolve the same skill.

The installer does not overwrite either path. On a fresh install, `.agents/skills/<name>` owns the
copy or source link and `.codex/skills/<name>` points to it. If only a real legacy skill already
exists, the installer exposes it at the canonical path without moving or changing it.

For guided project setup, prefer `scripts/setup-ai-context.sh`.

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
./scripts/install-skill-bundle.sh /path/to/project --bundle orchestration --mode link
```

## Recommended Layers

| Bundle | Count | Contents |
| --- | ---: | --- |
| `core` | 9 | Small default for context, specs, planning, TDD, review, debugging, source-driven work, and safe GitHub authentication |
| `orchestration` | 6 | Brain-task planning, multi-agent dispatch, spec traceability, persistent handoffs, bounded research, and doubt-driven investigation |
| `documentation` | 5 | Repository doc-drift audits, ADRs, READMEs, Mermaid, and C4 architecture |
| `delivery` | 7 | Incremental implementation, Git workflow, simplification, CI, self-evaluation, ship gates, and launch readiness |

Install `core` in routine projects. Add `orchestration` when a lead task coordinates several agents,
tasks, or sessions. Add `documentation` and `delivery` only when that work is in scope. This keeps
the discovered skill surface small while preserving focused capabilities.

## Specialist Bundles

| Bundle | Contents |
| --- | --- |
| `brevity` | Caveman skills for terse replies, help, commits, reviews, and memory-file compression |
| `engineering` | All imported `addyosmani/agent-skills` plus selected engineering skills from `alirezarezvani/claude-skills` |
| `jvm` | Kotlin/JVM implementation, Gradle toolchains, modules, coroutines, compatibility, boundaries, and verification |
| `rust` | Imported Rust Agentic Skills, prefixed as `rust-*` |
| `product` | Selected non-duplicate PM Skills and product-team Claude Skills |
| `planning` | `planning-files-lite` and full `planning-with-files` |
| `frontend` | Frontend design review, UI engineering, browser testing, accessibility, Playwright, design systems, and web quality |
| `frontend-tooling` | Vite, Vitest, pnpm, Turborepo, VitePress, and Slidev |
| `frontend-vue` | Vue, Vue best practices, Vue Router, Vue testing, Nuxt, Pinia, VueUse, and UnoCSS |
| `hallmark` | Opt-in creative direction for distinctive pages, redesigns, audits, and design studies |
| `infra` | Terraform/OpenTofu review, debugging, CI, state, security, testing, and rollback |
| `writing` | Project-story evidence mining, technical blog drafting, and an optional final prose audit |
| `workflow` | The older broad Agent Toolkit grouping for architecture, handoffs, requirements, QA, docs, OpenAPI, and React |
| `all` | Every bundle; intended for inventory audits, not normal project setup |

`core` is the only universal default selected by `setup-ai-context.sh`. Other automatic selections
require concrete stack signals. A `docs/` or `product/` folder alone does not select `product`, and
nested legacy Angular files do not classify the repository as an active Angular project.

`brevity` installs only portable skill content. It does not run the upstream global installer or
add hooks, statusline files, or an MCP proxy.

## Naming And Provenance

Imported skills may be prefixed to avoid collisions:

- `rust-*` for Rust Agentic Skills
- `pm-*` for PM Skills
- `claude-*` for selected Claude Skills
- `web-*` for Web Quality Skills
- `toolkit-*` for selected Agent Toolkit skills

Original imported sources remain under `templates/skills/imported/`. Third-party payloads retain
their applicable licenses; the `infra` bundle, for example, installs `terraform-skill/LICENSE`
beside the skill and references.

Run an integration audit with:

```sh
./scripts/audit-ai-context.sh /path/to/project
```

The audit catches unresolved `AGENTS.md` placeholders, missing or broken canonical skills,
legacy-only layouts, broken compatibility links, and unusually large project skill catalogs.

Every bundle has a generated Microsoft APM manifest. See `docs/apm.md` and run
`scripts/check-apm.sh` when APM is installed.
