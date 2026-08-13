# Agent Package Manager Integration

[Microsoft Agent Package Manager](https://microsoft.github.io/apm/) is an optional distribution
and verification layer for AI Central's compact skill bundles. It adds manifests, transitive local
dependency resolution, lockfiles, deployed-file hashes, frozen replay, and drift auditing.

The shell setup remains the default for project detection, steering, non-overwriting copy/link
mode, and `.codex/skills` compatibility links. APM is the reproducible managed-install path for
the canonical `.agents/skills` layout.

## Packages

| Bundle | Manifest | Skills |
| --- | --- | ---: |
| `core` | `packages/apm/core/apm.yml` | 9 |
| `orchestration` | `packages/apm/orchestration/apm.yml` | 6 |
| `documentation` | `packages/apm/documentation/apm.yml` | 5 |
| `delivery` | `packages/apm/delivery/apm.yml` | 7 |

The manifests reference the reviewed skill directories under `templates/`; they do not maintain a
second copy of skill content. APM records resolved local paths and content hashes in the consuming
project's lockfile.

## Install

Install APM using its
[official installation guide](https://microsoft.github.io/apm/getting-started/installation/).
After these packages are merged to the selected ref, install the smallest required set from the
consuming project:

```sh
apm install dills122/ai-central/packages/apm/core#main --target agent-skills
apm install dills122/ai-central/packages/apm/orchestration#main --target agent-skills
```

Documentation and delivery are independently selectable:

```sh
apm install dills122/ai-central/packages/apm/documentation#main --target agent-skills
apm install dills122/ai-central/packages/apm/delivery#main --target agent-skills
```

Commit the generated `apm.yml` and `apm.lock.yaml`. Do not commit `apm_modules/`. APM's converged
skills target deploys to `.agents/skills`; see the
[targets matrix](https://microsoft.github.io/apm/reference/targets-matrix/).

APM does not create AI Central's `.codex/skills` compatibility symlinks. Projects that still need
those links should use `install-skill-bundle.sh`; running the matching shell bundle after an APM
install preserves the managed canonical directories and adds only missing compatibility links.

## Verify

In a consuming project:

```sh
apm install --frozen
apm audit
```

In AI Central, run the disposable integration test:

```sh
./scripts/check-apm.sh
```

The test installs all four packages with APM's `agent-skills` target, verifies the exact 27 names,
replays the lockfile with `--frozen`, and requires a clean non-CI drift audit. The normal
`./scripts/check.sh` also verifies that each APM manifest has exact source-and-name parity with its
shell bundle.

## APM 0.28.0 Findings

The 2026-08-12 integration test found:

- all four packages resolve from the repository-local source tree and deploy 27 unique skills;
- initial installs and frozen replays are stable;
- non-CI audit replay reports no drift;
- object-form dependency aliases deploy correctly initially but lose the alias during audit replay,
  producing false orphaned/unintegrated drift. The compact bundles therefore use natural unique
  skill names and do not rely on APM aliases;
- `apm audit --ci` reports `config-consistency` failures because each transitive local `SKILL.md`
  package lacks its own `apm.yml`, even after a successful frozen replay and clean drift audit.

`check-apm.sh` accepts only that final known CI-audit signature as a warning; any other APM failure
fails the test. Do not make `apm audit --ci` a required repository gate until the local-skill
behavior is resolved upstream or AI Central adopts a package layout that does not duplicate the
reviewed template source tree.

OpenAPM remains a pre-1.0 working draft, so package behavior should be retested when upgrading the
CLI. See the [OpenAPM v0.1 specification](https://microsoft.github.io/apm/specs/openapm-v01/).
