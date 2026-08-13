# Agent Package Manager Pilot

[Microsoft APM](https://microsoft.github.io/apm/) is an optional distribution layer for AI
Central. It complements the existing setup scripts with manifests, transitive dependency
resolution, lockfiles, integrity hashes, policy checks, and deployment to multiple agent
harnesses.

The initial pilot exposes only the existing `core` skill bundle. The shell installers remain the
default for profile detection, steering scaffolding, link mode, and non-overwriting setup.

## Install The Core Bundle

Install APM by following its
[official installation guide](https://microsoft.github.io/apm/getting-started/installation/), then
run this from a consuming project:

```sh
apm install dills122/ai-central/packages/apm/core#main
```

For a specific harness, pass an explicit target:

```sh
apm install dills122/ai-central/packages/apm/core#main --target codex
```

During the pilot, `#main` makes new package revisions available for testing. Production consumers
should switch to a release tag once AI Central starts publishing tagged APM packages. Commit the
generated `apm.yml` and `apm.lock.yaml`; do not commit `apm_modules/`.

APM 0.28.0 installs the pilot's skills into `.agents/skills/` for Codex, Copilot, Cursor, Gemini,
OpenCode, Windsurf, and the explicit `agent-skills` target. Harnesses with native skill directories,
including Claude Code and Kiro, receive their supported layout instead.

## Why The Package Uses Local Dependencies

AI Central's reviewed source of truth remains under `templates/`. APM normally authors primitives
under `.apm/`, but copying 123 reviewed skills there would create a second source tree that could
drift.

The pilot manifest at `packages/apm/core/apm.yml` instead composes repository-local skill paths:

```text
packages/apm/core/apm.yml
        |
        +-- ../../../templates/skills/.../SKILL.md
        |
        +-- consuming project/.agents/skills/...
                           + apm.lock.yaml
```

When a consumer installs the remote package, APM keeps those relative dependencies inside the same
checked-out AI Central repository. The consuming lockfile records the resolved Git commit, deployed
files, and content hashes. This preserves provenance without changing or duplicating the reviewed
templates.

## Scope And Tradeoffs

The pilot is deliberately narrow:

- It packages skills only. Existing steering profiles and the root `AGENTS.md` still use
  `setup-ai-context.sh` because APM's Codex target compiles instructions into a root `AGENTS.md`
  and could conflict with project-owned context.
- It exposes `core` first. Other bundles include installation-time renaming such as `rust-*`,
  `pm-*`, and `claude-*`; those need explicit alias validation before migration.
- APM copies managed skills and does not provide AI Central's local symlink-based development mode.
- APM owns and may update files recorded in its lockfile. Do not hand-edit deployed copies; change
  the source template or add project-owned context alongside it.
- Third-party terms still apply. Review `THIRD_PARTY_NOTICES.md`, `docs/skill-attribution.md`, and
  the license copies under `templates/skills/imported/licenses/` before redistribution.

## Recommended Adoption Path

1. Pilot `core` in a few projects with `--target codex` or `--target agent-skills`.
2. Verify clean replay with `apm install --frozen` and drift checks with `apm audit --ci`.
3. Add tagged AI Central releases so consumers can replace `#main` with immutable version ranges or
   tags while retaining lockfile reproducibility.
4. Model bundle membership once in `templates/catalog.json`, then generate both shell and APM
   package definitions from that data before exposing the larger bundles.
5. Evaluate steering profiles separately, with explicit rules for merging or preserving an existing
   root `AGENTS.md`.

## Validation Performed

The pilot was smoke-tested with APM 0.28.0 against a disposable consumer project using the
`agent-skills` target. APM resolved one direct package plus ten transitive local skill dependencies,
installed all ten skills under `.agents/skills/`, and generated a lockfile with deployed-file hashes.
