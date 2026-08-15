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

Bundle flags may be comma-separated or repeated. The installer computes their union by installed
name, so overlap between selected bundles does not create the same destination twice.

## Exact Skill Selection

Use exact selectors when most of a bundle is useful but a project needs a smaller discovered skill
surface:

```sh
./scripts/install-skill-bundle.sh /path/to/project \
  --bundle core,frontend-tooling \
  --skills hallmark-design \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --mode link \
  --dry-run
```

Resolution order is:

1. expand and union every selected bundle;
2. add every name from `--skills`;
3. remove every name from `--skip-skills`.

Therefore exclusions win. Selectors are exact installed names, not source directory names or fuzzy
matches. Prefixed imported names such as `rust-rust-core`, `pm-create-prd`, `claude-*`, `web-*`,
and `toolkit-*` must include their installed prefix. Unknown names fail before the target changes.

For a bespoke set with no bundle baseline:

```sh
./scripts/install-skill-bundle.sh /path/to/project \
  --bundle none \
  --skills pnpm,hallmark-design
```

`none` cannot be combined with another bundle. Omitting `--bundle` continues to select `core`, so
existing commands retain their behavior.

For an APM-managed project, pass the same selectors to `scripts/generate-apm-selection.sh` to
create an exact `apm.yml`. APM then records the resolved selection and deployment ownership in
`apm.lock.yaml`; see [Agent Package Manager integration](apm.md).

## Safe Link Synchronization

Installation is additive by default. Link-mode projects can opt into pruning deselected managed
links:

```sh
./scripts/install-skill-bundle.sh /path/to/project \
  --bundle core \
  --skills pnpm \
  --mode link \
  --sync \
  --dry-run
```

Dry-run reports exact creates, links, skips, and removals without making directories or changing
the target. After review, omit `--dry-run` to apply the plan.

The installer removes a canonical `.agents/skills/<name>` path only when all of these are true:

- the path is a symlink;
- `<name>` is known to the current AI Central catalog but is not in the resolved selection; and
- the symlink target exactly equals that installed name's source in the current checkout.

The corresponding `.codex/skills/<name>` compatibility link is removed only when its target is
exactly `../../.agents/skills/<name>`. Real directories, copied skills, adopted legacy skills,
unknown or repointed symlinks, and project-owned compatibility paths are never pruned. `--sync`
therefore requires `--mode link`; it is intentionally not a general cleanup command.

## Recommended Layers

| Bundle | Count | Contents |
| --- | ---: | --- |
| `core` | 9 | Small default for context, specs, planning, TDD, review, debugging, source-driven work, and safe GitHub authentication |
| `orchestration` | 7 | Brain-task planning, multi-agent dispatch, independent review, spec traceability, persistent handoffs, bounded research, and doubt-driven investigation |
| `documentation` | 5 | Repository doc-drift audits, ADRs, READMEs, Mermaid, and C4 architecture |
| `delivery` | 7 | Incremental implementation, Git workflow, simplification, CI, self-evaluation, ship gates, and launch readiness |

Install `core` in routine projects. Add `orchestration` when a lead task coordinates several agents,
tasks, or sessions. Add `documentation` and `delivery` only when that work is in scope. This keeps
the discovered skill surface small while preserving focused capabilities.

## Specialist Bundles

| Bundle | Contents |
| --- | --- |
| `node` | Installed Node package entry points, declaration graphs, export conditions, subpaths, and static runtime API hints |
| `brevity` | Caveman skills for terse replies, help, commits, reviews, and memory-file compression |
| `engineering` | Node package API inspection, all imported `addyosmani/agent-skills`, and selected engineering skills from `alirezarezvani/claude-skills` |
| `dotnet` | Official .NET test-platform/filter/run workflows plus MSBuild organization, anti-pattern, and binary-log diagnostics |
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
nested legacy Angular files do not classify the repository as an active Angular project. A root
`package.json` selects the compact `node` bundle.

`brevity` installs only portable skill content. It does not run the upstream global installer or
add hooks, statusline files, or an MCP proxy.

## Naming And Provenance

Imported skills may be prefixed to avoid collisions:

- `rust-*` for Rust Agentic Skills
- `dotnet-*` for official .NET test and MSBuild skills
- `pm-*` for PM Skills
- `claude-*` for selected Claude Skills
- `web-*` for Web Quality Skills
- `toolkit-*` for selected Agent Toolkit skills

These remain separate installed names even when two names ultimately carry overlapping guidance.
The installer deduplicates overlapping bundle selections by installed name, not by source identity
or semantic similarity. Exact exclusions are the current way to hide aliases a project does not
want to expose.

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
