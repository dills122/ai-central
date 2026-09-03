# Contributing

This repo has two different kinds of content:

- Collected source material copied from existing projects.
- Reviewed templates and scripts intended for reuse.

Keep those separate.

## Collected Material

- Preserve source files under `collected/` as copied.
- Keep provenance visible in the folder path.
- Regenerate `docs/source-manifest.sha256` after changing collected files.
- Do not promote third-party or temporary material until provenance and licensing are understood.

## Templates

- Put reusable guidance under `templates/`.
- Use placeholders for project-specific details, for example `{{PROJECT_NAME}}`.
- Prefer small, composable files over one large instruction file.
- Keep examples generic unless the template is explicitly stack-specific.
- Update `docs/reuse-candidates.md` when promoting or rejecting a candidate.

## Third-Party Skills

- Review license and provenance before importing.
- Put copied third-party skills under `templates/skills/imported/`.
- Put rewritten or condensed derivatives under `templates/skills/adapted/`.
- Update `docs/skill-attribution.md` and `THIRD_PARTY_NOTICES.md`.
- Copy upstream license files into `templates/skills/imported/licenses/`.

## Scripts

- Prefer POSIX `sh`.
- Do not overwrite target project files by default.
- Print every created or skipped file.
- Validate with `sh -n scripts/*.sh`.
- Smoke test scaffold changes against a temporary directory.

Use the combined check script when possible:

```sh
./scripts/check.sh
```

## Pull Requests And Releases

Use a Conventional Commit pull request title. Squash merges retain that title and Release Please
uses it to classify the next repository-wide release:

- `feat(skills): ...` for a new skill or material compatible skill change;
- `fix(skills): ...` for a narrow compatible correction;
- `feat(skills)!: ...` for a breaking skill or bundle contract change;
- `docs: ...`, `test: ...`, or `chore: ...` for non-releasing maintenance.

Major version changes require the `release:major-approved` label. See
[Release and versioning workflow](docs/releases.md) for the automated release process and consumer
versioning policy.

## Review Checklist

- Raw source material and reusable templates are not mixed.
- New templates have clear placeholders.
- Scaffold behavior is idempotent.
- Documentation reflects new profiles, scripts, or workflows.
- The pull request title communicates the intended release impact.
