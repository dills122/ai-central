# AGENTS

AI coding guidance for this repository.

## Purpose

This repository is a central library for AI steering files, agent instructions, Cursor rules, Codex skills, and scaffold helpers collected from local projects.

Optimize for:

- preserving raw collected source material with clear provenance
- promoting only reviewed patterns into reusable templates
- small, explicit changes over broad rewrites
- scaffold behavior that avoids overwriting target project context

## Repository Layout

- `collected/`: raw source material copied from project repositories
- `templates/`: normalized reusable starters
- `docs/`: inventory, review notes, and workflow documentation
- `scripts/`: local shell helpers

## Rules

- Treat `collected/` as historical source material. Do not hand-edit collected files unless explicitly correcting collection metadata.
- Put reusable guidance in `templates/` and document the reason in `docs/reuse-candidates.md`.
- Keep scripts POSIX `sh` compatible unless a stronger shell is explicitly justified.
- Scaffold scripts must not overwrite existing files by default.
- Use placeholders like `{{PROJECT_NAME}}` for project-specific details in templates.
- Update `docs/source-manifest.sha256` after changing collected source files.

## Validation

- Full local check: `./scripts/check.sh`
- Refresh manifest: `./scripts/refresh-source-manifest.sh`
- Guided setup dry run: `./scripts/setup-ai-context.sh /path/to/project --yes --dry-run`
