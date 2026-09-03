# CI

This repo uses GitHub Actions for baseline validation, skill security scanning, and release
automation.

## Workflows

| Workflow | Purpose |
| --- | --- |
| `CI` | Runs local repository and APM checks, validates pull request titles, release-bearing paths, and version metadata, prevents tracked `external/` clones, and verifies imported source license copies. |
| `Skill Security` | Runs Cisco AI Skill Scanner against `templates/skills` when skill templates change. |
| `Release` | After successful `main` CI, finalizes an annotated version tag and GitHub Release, then maintains the next Release Please pull request. |

See [Release and versioning workflow](releases.md) for required labels, token setup, and the release
sequence.

## Skill Scanner Policy

`Skill Security` starts with:

- `policy: balanced`
- `fail_on_severity: critical`
- `lenient: false`
- static analysis only; no LLM, cloud, or behavioral analyzers

This is intentionally conservative. The repo imports a large amount of third-party skill content, so the first goal is to establish a stable baseline without blocking normal work on noisy high-severity findings.

After reviewing initial GitHub Actions results, consider:

1. Raising the gate to `fail_on_severity: high`.
2. Enabling `use_behavioral: true`.
3. Adding a custom scanner policy for known acceptable imported patterns.
4. Enabling LLM analysis only if the repo has an agreed secret-management policy for `SKILL_SCANNER_LLM_API_KEY`.
