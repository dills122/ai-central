# Release And Versioning Workflow

AI Central uses one repository version for every generated Agent Package Manager package. A release
is an immutable, annotated Git tag such as `v0.3.0`; APM consumers install that tag directly or use
a SemVer range that resolves to it.

The current version lives in `version.txt`. All `packages/apm/*/apm.yml` manifests must carry the
same version. `scripts/generate-apm-bundles.sh` reads the central version, and
`scripts/check-release.sh` rejects inconsistent generated output.

## Change Classification

Pull request titles use Conventional Commits because Release Please derives the next version and
changelog from the squash-merge commit:

| Pull request title | Release effect |
| --- | --- |
| `feat(skills): ...` | Minor release; use for a new skill or material backward-compatible behavior change |
| `fix(skills): ...` | Patch release; use for a narrow backward-compatible correction |
| `feat(skills)!: ...` | Breaking release proposal |
| `docs: ...`, `test: ...`, `chore: ...` | No version bump by default |

Use a breaking marker when removing or renaming a public skill, removing bundle membership,
changing deployed paths, adding incompatible required tooling, or changing an established skill
contract incompatibly. The original breaking-change pull request and its resulting major release
pull request cannot pass CI until a maintainer adds the `release:major-approved` label. This makes
the `!` marker an explicit proposal rather than permission to publish a major release.

CI also rejects changes to a `SKILL.md` definition or `templates/catalog.json` when the pull request
title would not produce a release. This prevents a skill behavior change from being hidden inside a
`docs:` or `chore:` release classification.

## Automated Flow

1. Normal pull requests merge to `main` after CI.
2. After successful `main` CI, Release Please creates or refreshes one release pull request. It
   updates `CHANGELOG.md`, `version.txt`, `.release-please-manifest.json`, and every generated APM
   manifest.
3. The release pull request runs the normal checks. Version changes are accepted only from a pull
   request labeled `autorelease: pending` or `release:manual`.
4. Merging the release pull request runs CI again.
5. After that successful CI run, `.github/workflows/release.yml` creates the annotated `vX.Y.Z` tag
   and a GitHub Release if they do not already exist.
6. Release Please then begins accumulating changes for the next release.

Release finalization is idempotent. Re-running the workflow accepts an existing annotated tag and
creates only a missing GitHub Release. It rejects a same-named lightweight tag because APM's
SHA-to-release update path expects an annotated SemVer tag.

## Repository Setup

The Release workflow can use the built-in `GITHUB_TOKEN`, but pull requests created by that token do
not normally trigger other workflows. Configure a fine-grained token or GitHub App token as the
`RELEASE_PLEASE_TOKEN` Actions secret so release pull requests receive the same CI checks as normal
pull requests. The token needs repository contents, issues, and pull-request write access.

The Release workflow creates and maintains these repository labels:

- `release:major-approved` — explicit authorization for a major release;
- `release:manual` — permits a maintainer-authored version-change pull request when Release Please
  is intentionally bypassed.

Protect `main`, require the `Repository checks` and `Skill scanner` checks, and prevent automatic
merging of release pull requests that change the major version. Patch and minor release pull
requests may use auto-merge after required checks pass.

## Bootstrap Release

The first successful `main` CI run containing this release configuration creates the annotated
`v0.2.0` tag and corresponding GitHub Release if the tag is still absent. Subsequent feature and fix
commits are accumulated into the first Release Please pull request after that baseline.

## Consumer Versions

Direct bundle consumers should prefer the latest reviewed tag:

<!-- x-release-please-start-version -->
```sh
apm install dills122/ai-central/packages/apm/core#v0.2.0 --target agent-skills
```
<!-- x-release-please-end -->

An exact-selection manifest generated from a checkout at a release commit uses the matching tag.
An unreleased checkout uses its full commit SHA instead, so a generated manifest never silently
points at older released content.

Consumers can choose an update policy in `apm.yml`:

<!-- x-release-please-start-version -->
```yaml
# Exact release
- dills122/ai-central/packages/apm/core#v0.2.0

# Patch updates within 0.2
- dills122/ai-central/packages/apm/core#~0.2.0

# Object form used by exact generated selections
- git: https://github.com/dills122/ai-central.git
  path: templates/skills/first-party/example
  ref: v0.2.0
```
<!-- x-release-please-end -->

Use `apm outdated` and `apm update --dry-run` to review new compatible releases. Shared or critical
projects should land the `apm.yml`, `apm.lock.yaml`, and deployed-file changes together through a
normal dependency-update pull request.

## Manual Recovery

If a release workflow fails after pushing its tag, rerun it. Do not delete or move a published
version tag. If a bad release has already been published, correct the problem in a new patch release.

Before manually approving a release, run:

```sh
./scripts/check.sh
./scripts/check-apm.sh
```
