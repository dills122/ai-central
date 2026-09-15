# Agent Package Manager Integration

> Reviewed against the official APM documentation and APM 0.29.0 on 2026-09-02.

[Microsoft Agent Package Manager](https://microsoft.github.io/apm/) is the optional managed
distribution layer for AI Central skill bundles. It gives consuming projects a declarative
`apm.yml`, an integrity-bearing `apm.lock.yaml`, target-aware deployment, frozen replay, drift
auditing, and optional organization policy.

AI Central intentionally keeps a narrower boundary than APM itself:

- APM owns skill dependency resolution and deployment to agent harnesses.
- `setup-ai-context.sh` continues to own repository `AGENTS.md`, steering profiles, project
  detection, non-overwriting copy/link mode, and `.codex/skills` compatibility links.
- Reviewed sources remain authoritative under `templates/`; generated APM manifests never create a
  second source tree.

The current package shape is valid for remote monorepo consumption: each package manifest under
`packages/apm/` points to same-repository skill directories with relative `path:` dependencies.
APM scopes those paths to the package's resolved repository and ref.

## Recommended Project Baseline

A production project should have all of the following:

1. A committed `apm.yml` with explicit `targets:`. Filesystem auto-detection is useful for a local
   experiment but makes committed output machine-dependent.
2. An immutable AI Central source ref: preferably a release tag, otherwise a full commit SHA.
   `#main` is acceptable only while evaluating changes.
3. A committed `apm.lock.yaml`. Do not edit it by hand.
4. Committed target-owned output such as `.agents/skills/`, unless the project has deliberately
   chosen the documented gitignored-output CI model.
5. `apm_modules/` in `.gitignore`.
6. A pinned APM CLI version in CI, plus `apm install --frozen` and `apm audit --ci` where the selected
   packages are compatible with audit replay.

This matches APM's official guidance for
[target determinism](https://microsoft.github.io/apm/reference/manifest-schema/#36-target-and-targets),
[committed artifacts](https://microsoft.github.io/apm/quickstart/#what-to-commit),
[frozen installs](https://microsoft.github.io/apm/consumer/update-and-refresh/#lock-down-for-ci), and
[CI enforcement](https://microsoft.github.io/apm/enterprise/enforce-in-ci/).

## Install APM

Use the [official installation guide](https://microsoft.github.io/apm/getting-started/installation/).
For example, Homebrew users can install with:

```sh
brew install microsoft/apm/apm
apm --version
apm doctor
```

The documentation and CI in this repository are pinned to APM 0.29.0. APM and its working-draft
schemas are still pre-1.0, so test a new CLI version before changing the shared pin.

## Choose Targets Deliberately

APM resolves targets in this order: command-line `--target` or `--all`, project `targets:`, then
filesystem auto-detection. Long-lived projects should commit `targets:` so developers and CI deploy
the same files.

For AI Central's skill-only packages:

| Project need | Recommended target selection |
| --- | --- |
| Shared Agent Skills directory only | `agent-skills` |
| Codex, including future agents, hooks, or MCP dependencies | `codex` |
| Claude Code | `claude` |
| More than one harness | A comma-separated list such as `codex,claude` |
| Kiro or Grok Build native skill directories | `kiro` or `grok-build` |
| GitHub Copilot for JetBrains, including its user-scope MCP integration | `intellij` |

`agent-skills` deploys only to `.agents/skills/`. It is a good fit for the current AI Central
packages and for harnesses that consume that converged directory. Use the actual harness slugs if
the project's broader `apm.yml` also declares instructions, agents, hooks, MCP, or LSP dependencies;
otherwise those target-specific primitives will not be deployed.

If a broader package contains instructions, run `apm compile` after installation for `codex`,
`gemini`, or `opencode`; those targets require a separate root-context compilation step. The
current AI Central packages contain skills only, so they do not require that step.

The exact-selection generator defaults to:

```yaml
targets:
  - agent-skills
```

Override it when needed with `--targets codex,claude`. The generator accepts stable canonical
target names only; deprecated `all`, compatibility aliases such as `vscode`, and experimental
targets are intentionally not emitted.

## Install A Bundle

Every bundle in `templates/catalog.json` has a generated APM package:

| Package path | Skills |
| --- | ---: |
| `packages/apm/core` | 9 |
| `packages/apm/node` | 1 |
| `packages/apm/orchestration` | 7 |
| `packages/apm/documentation` | 5 |
| `packages/apm/delivery` | 7 |
| `packages/apm/brevity` | 5 |
| `packages/apm/engineering` | 44 |
| `packages/apm/dotnet` | 8 |
| `packages/apm/jvm` | 1 |
| `packages/apm/rust` | 8 |
| `packages/apm/security-testing` | 4 |
| `packages/apm/product` | 25 |
| `packages/apm/planning` | 2 |
| `packages/apm/frontend` | 12 |
| `packages/apm/frontend-tooling` | 6 |
| `packages/apm/frontend-vue` | 8 |
| `packages/apm/hallmark` | 1 |
| `packages/apm/infra` | 1 |
| `packages/apm/writing` | 3 |
| `packages/apm/workflow` | 13 |
| `packages/apm/all` | 143 unique sources |

For a stable install, run this from the consuming project:

<!-- x-release-please-start-version -->
```sh
apm install dills122/ai-central/packages/apm/core#v0.2.0 --target agent-skills
```
<!-- x-release-please-end -->

APM creates or updates `apm.yml`, persists the explicit target, writes the lockfile, and deploys the
skills. Use `#main` only for an intentional evaluation of unreleased content. Releases use one
repository-wide version, so every bundle under the same `vX.Y.Z` tag is mutually consistent.

Subsequent installs should be bare:

```sh
apm install
```

Use the complete `all` package only for integration auditing. It is not a sensible default project
dependency.

## Generate An Exact Project Selection

APM supports a `skills:` subset for packages that expose a real skill bundle under `.apm/skills/`
or plugin metadata. AI Central's generated packages are dependency aggregators: their skills are
transitive single-skill packages, so `apm install ... --skill NAME` cannot filter them. Generate a
project manifest with exact direct dependencies instead:

```sh
./scripts/generate-apm-selection.sh \
  --bundle core,frontend-tooling \
  --skills hallmark-design \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --name my-project-ai-context \
  --targets agent-skills \
  --output /path/to/project/apm.yml
```

The generator:

- expands the same bundles and installed-name selectors as the shell installer;
- emits one remote Git dependency per selected skill;
- preserves renamed skills with object-form `alias:` fields;
- uses the matching `vX.Y.Z` tag when the checkout is at a release commit, otherwise pins the
  current commit SHA;
- pins `agent-skills` by default, or the targets supplied with `--targets`;
- refuses to overwrite an existing file or symlink.

Use `--ref <release-tag-or-sha>` to choose a different immutable revision. `--ref main` is an
explicit opt-in to a moving branch.

Then install and commit the managed state:

```sh
cd /path/to/project
apm install
git add apm.yml apm.lock.yaml .agents/skills
```

Adjust the `git add` paths for native targets such as `.claude/` or `.kiro/`.

To change an existing exact selection, generate a separate candidate file, review it, replace the
project manifest deliberately, and reconcile APM-owned state:

```sh
./scripts/generate-apm-selection.sh \
  --bundle core,frontend-tooling \
  --name my-project-ai-context \
  --output /path/to/project/apm.next.yml

cd /path/to/project
# Review apm.next.yml, then replace apm.yml through the project's normal review workflow.
apm install
apm prune --dry-run
apm prune
apm audit
```

`apm prune` removes only orphaned packages and deployed files whose ownership was recorded in the
lockfile. Do not run the shell installer's `--sync` against the same APM-managed skill tree.

APM identifies dependencies by source path and cannot deploy one source twice under two aliases.
When overlapping bundles select the same source with different public names, the generator keeps
the first name in sorted order and reports omitted aliases on stderr. Use `--skip-skills` to choose
the desired public name intentionally.

## Files To Commit

| Path | Commit? | Reason |
| --- | --- | --- |
| `apm.yml` | Yes | Project declaration and target selection |
| `apm.lock.yaml` | Yes | Exact commits, content hashes, and deployment ownership |
| `.agents/`, `.claude/`, `.codex/`, or other target-owned output | Normally yes | Available immediately after clone and auditable for drift |
| `apm_modules/` | No | Rebuilt cache |
| User tokens or `~/.apm/config.json` | No | Machine-local credentials and preferences |

Do not hand-edit APM-deployed copies. Change the authoritative skill, change `apm.yml`, or add a
clearly project-owned skill that does not collide with an APM-owned path.

## CI

For an alias-free project that commits deployed output, the strict CI sequence is:

```yaml
- uses: microsoft/apm-action@v1
  with:
    setup-only: 'true'
    apm-version: '0.29.0'

- run: apm install --frozen
- run: apm audit --ci --no-cache
```

`--frozen` rejects a missing or stale lockfile without resolving new versions. `audit --ci` runs the
baseline lockfile, integrity, deployment-owner, and replay-drift checks. `--no-cache` prevents a
stale organization policy cache from hiding a same-day policy update.

APM 0.29.0 still has an upstream replay limitation for local dependencies with aliases. A fresh
install and frozen install preserve aliases, but the scratch replay used by `apm audit --ci`
materializes their natural source names and reports false drift. For a manifest containing
`alias:`, use this temporary reduced gate:

```sh
apm install --frozen
apm audit --ci --no-cache --no-drift
```

That retains baseline and content-integrity checks but skips scratch replay. Keep the exception
visible in CI and restore the full audit after an APM release fixes alias replay. Do not suppress an
arbitrary audit failure by matching its text.

This repository itself pins APM 0.29.0 in `.github/workflows/ci.yml` and runs
`scripts/check-apm.sh`. The integration check installs the complete alias-rich catalog to verify
names and files, then exercises frozen replay and full CI audit on the alias-free `core` package.

## Authentication

Public GitHub packages require no token. For private GitHub or GitHub Enterprise dependencies, use
`gh auth login` locally or provide `GITHUB_APM_PAT` in the environment. CI tokens need read access
to every referenced repository. GitLab and Azure DevOps use `GITLAB_APM_PAT` and `ADO_APM_PAT`
respectively, or an existing Git credential helper.

Never place tokens in `apm.yml`, dependency URLs, shell history, or committed APM configuration.
See the official [authentication guide](https://microsoft.github.io/apm/consumer/authentication/).

## Updates And Removal

Use distinct commands for distinct jobs:

```sh
apm outdated          # read-only upstream check
apm update --dry-run  # preview dependency changes
apm update            # approve and apply dependency changes
apm install           # reproduce locked versions and reconcile the manifest
apm install --frozen  # CI-safe lockfile-only install
apm prune --dry-run   # preview orphan cleanup
apm prune             # remove lockfile-owned orphans
apm self-update       # update the CLI, not project dependencies
```

For an exact manifest pinned to an AI Central tag or SHA, the clearest update is to check out the
reviewed AI Central revision, regenerate `apm.next.yml`, review the dependency diff, and land the
manifest, lockfile, and deployed-file changes together.

## Releases

AI Central uses one semantic version across all generated APM packages. Release Please derives a
release pull request from Conventional Commit titles; merging that reviewed pull request updates
the changelog and manifests. After successful `main` CI, the Release workflow creates an annotated
`vX.Y.Z` tag and GitHub Release. Major version changes require explicit maintainer approval.

See [Release and versioning workflow](releases.md) for classification rules, repository setup,
bootstrap behavior, and downstream version policies.

## Policy And Governance

APM is secure by default at install time: it scans primitives for hidden Unicode, records hashes,
and restricts transitive self-defined MCP servers. `apm-policy.yml` adds organization rules for
allowed sources, version constraints, MCP transports, required packages, integrity, and drift.

The lockfile and baseline audit are documented as production-ready. The policy engine is still an
early preview, so:

- pin the APM CLI version before making policy a required gate;
- pilot with `enforcement: warn` before moving to `block`;
- prefer an organization policy in `.github-private` or `.github` with CODEOWNERS and branch
  protection over copying divergent policies into every repository;
- set `fetch_failure: block` only after policy discovery is reliable;
- remember that APM policy governs installation, not runtime permissions or sandboxing.

See the official [governance guide](https://microsoft.github.io/apm/enterprise/governance-guide/)
and [policy schema](https://microsoft.github.io/apm/reference/policy-schema/).

## Regenerate And Verify AI Central Packages

`scripts/generate-apm-bundles.sh` derives all package manifests from the shell bundle catalog and
preserves prefixed installed names with explicit aliases.

After changing bundle membership or installed names:

```sh
./scripts/generate-apm-bundles.sh --write
./scripts/check.sh
```

Read-only validation:

```sh
./scripts/generate-apm-bundles.sh --check
./scripts/check-apm.sh
```

The shell `all` bundle exposes 149 installed names. APM identifies local dependencies by source
path and deploys each source once, so the APM `all` package contains 143 unique sources. It keeps
the clearer `claude-playwright-review` name for the one historical Playwright duplicate.

## Remaining Boundaries

- The initial `v0.2.0` tag is created only after this release configuration reaches `main` and its
  CI run succeeds. Until then, use a reviewed full SHA.
- Alias-bearing packages cannot use the APM 0.29.0 scratch drift replay without false positives.
- APM does not create AI Central's `.codex/skills` compatibility links. Run the matching
  non-overwriting shell bundle if a project still needs them.
- Third-party terms still apply. Review `THIRD_PARTY_NOTICES.md`, `docs/skill-attribution.md`, and
  license copies under `templates/skills/imported/licenses/`.
- Re-run `scripts/check-apm.sh` before upgrading the repository's pinned APM version.
