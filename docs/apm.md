# Agent Package Manager Integration

[Microsoft Agent Package Manager](https://microsoft.github.io/apm/) is an optional managed
distribution and verification layer for every AI Central skill bundle. It adds manifests,
transitive local dependencies, lockfiles, content hashes, frozen replay, policy checks, and drift
auditing.

The shell setup remains the default for project detection, steering, non-overwriting copy/link
mode, and `.codex/skills` compatibility links. APM packages skills only and deploys them to the
canonical `.agents/skills` target selected by the consuming project.

## Packages

Every bundle in `templates/catalog.json` has a generated manifest:

| Package path | Skills |
| --- | ---: |
| `packages/apm/core` | 9 |
| `packages/apm/orchestration` | 6 |
| `packages/apm/documentation` | 5 |
| `packages/apm/delivery` | 7 |
| `packages/apm/brevity` | 5 |
| `packages/apm/engineering` | 42 |
| `packages/apm/jvm` | 1 |
| `packages/apm/rust` | 8 |
| `packages/apm/product` | 25 |
| `packages/apm/planning` | 2 |
| `packages/apm/frontend` | 12 |
| `packages/apm/frontend-tooling` | 6 |
| `packages/apm/frontend-vue` | 8 |
| `packages/apm/hallmark` | 1 |
| `packages/apm/infra` | 1 |
| `packages/apm/writing` | 3 |
| `packages/apm/workflow` | 13 |
| `packages/apm/all` | 128 unique sources |

The shell `all` bundle exposes 134 installed names. Several sources are intentionally reused by
the compact bundles and older broad bundles, and the Playwright review source has two historical
aliases. APM 0.28.0 identifies local dependencies by source path and deploys each source once, so
the APM `all` package contains 128 unique sources and keeps the clearer
`claude-playwright-review` name for the Playwright duplicate. Individual packages preserve their
documented installed names.

## Install

Install APM using its
[official installation guide](https://microsoft.github.io/apm/getting-started/installation/), then
install the smallest useful package from a consuming project:

```sh
apm install dills122/ai-central/packages/apm/core#main --target agent-skills
apm install dills122/ai-central/packages/apm/orchestration#main --target agent-skills
apm install dills122/ai-central/packages/apm/writing#main --target agent-skills
```

Any shell bundle name can replace those examples. Install the complete audit catalog only when you
genuinely want every skill:

```sh
apm install dills122/ai-central/packages/apm/all#main --target agent-skills
```

During evaluation, `#main` makes package changes available immediately. Use a release tag once AI
Central publishes immutable package releases. Commit the consuming project's generated `apm.yml`
and `apm.lock.yaml`; do not commit `apm_modules/`.

APM does not create AI Central's `.codex/skills` compatibility links. Projects that still need
those links should run the matching shell bundle after the APM install. The non-overwriting shell
installer preserves APM's canonical directories and adds only missing compatibility links.

## Source Of Truth And Aliases

AI Central's reviewed skills remain authoritative under `templates/`. APM manifests reference
those repository-local paths and never copy them into a second source tree.

`scripts/generate-apm-bundles.sh` derives every manifest from the actual shell installer. When a
shell bundle renames a skill with a `claude-`, `pm-`, `rust-`, `toolkit-`, or `web-` prefix, the
generated APM dependency uses an explicit object-form `alias`.

Regenerate after changing bundle membership or installed names:

```sh
./scripts/generate-apm-bundles.sh --write
```

CI-style validation is read-only:

```sh
./scripts/generate-apm-bundles.sh --check
```

## Verify

For alias-free bundles (`core`, `orchestration`, `documentation`, `delivery`, `brevity`, `jvm`,
`planning`, `frontend-tooling`, `frontend-vue`, `hallmark`, `infra`, and `writing`), the normal
locked verification flow works:

```sh
apm install --frozen
apm audit
```

APM 0.28.0 has a replay limitation for local dependencies with aliases. Fresh installs of
`engineering`, `rust`, `product`, `frontend`, `workflow`, and `all` preserve AI Central's expected
installed names, but frozen or audit replay redeploys those dependencies under their source names
and reports the alias changes as drift. Until that upstream behavior changes, refresh an
alias-bearing bundle with its explicit package install command and review the generated lockfile.

In AI Central, run the disposable integration test:

```sh
./scripts/check-apm.sh
```

It installs `packages/apm/all` and verifies all 128 expected unique names. It separately installs
the alias-free `core` package, replays that lockfile with `--frozen`, and requires a clean drift
audit. The normal `./scripts/check.sh` verifies all 18 generated manifests, source paths, aliases,
and catalog coverage without requiring APM.

`apm audit --ci` may still report `config-consistency` findings because transitive local
`SKILL.md` packages do not each carry their own `apm.yml`. `check-apm.sh` accepts only that known CI
signature as a warning; any other APM failure fails the test.

## Boundaries

- APM packages skills only. Continue using `setup-ai-context.sh` for repository `AGENTS.md`,
  steering profiles, project detection, link mode, and compatibility links.
- APM manages files recorded in its lockfile. Do not hand-edit deployed copies; update the source
  skill or add clearly project-owned context alongside it.
- Third-party terms still apply. Review `THIRD_PARTY_NOTICES.md`,
  `docs/skill-attribution.md`, and license copies under `templates/skills/imported/licenses/`.
- OpenAPM remains pre-1.0. Re-run `scripts/check-apm.sh` when upgrading the CLI.
