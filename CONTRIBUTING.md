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

## Review Checklist

- Raw source material and reusable templates are not mixed.
- New templates have clear placeholders.
- Scaffold behavior is idempotent.
- Documentation reflects new profiles, scripts, or workflows.
