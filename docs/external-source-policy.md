# External Source Policy

Use this policy before importing external skills, templates, scripts, references, or assets into this repository.

## Import Requirements

Every imported external source must record:

- upstream repository URL
- local clone path used for review
- commit SHA
- license
- files copied or adapted
- review date
- whether content was copied verbatim or substantially adapted

## Default Rule

Do not vendor large upstream repositories into this repo.

Use `external/` for local review clones. `external/` is ignored by git.

Promote only reviewed output into:

- `templates/skills/`
- `templates/steering/`
- `docs/`
- `scripts/`

## License Rules

- MIT and Apache-2.0 sources are generally acceptable for adaptation, but keep attribution.
- Repositories without a clear root license are discovery sources only.
- Aggregated catalogs are discovery sources unless the specific target skill's source and license are reviewed.
- Avoid legal, medical, financial, or regulated-domain generation skills unless the repo has explicit guardrails and the use case is intentional.

## Script Rules

External scripts require extra review before import:

- no remote code execution patterns
- no shell piping from network sources
- no secret exfiltration behavior
- no broad filesystem writes
- no destructive commands without explicit user approval
- dependency installation must be documented and optional

## Attribution

When adapting an external skill, include a short note in the new file or nearby manifest:

```md
Adapted from `owner/repo/path`, commit `<sha>`, license `<license>`.
```
