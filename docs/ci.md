# CI

This repo uses GitHub Actions for baseline validation and skill security scanning.

## Workflows

| Workflow | Purpose |
| --- | --- |
| `CI` | Runs local repository checks, validates `templates/catalog.json`, prevents tracked `external/` clones, and verifies imported source license copies. |
| `Skill Security` | Runs Cisco AI Skill Scanner against `templates/skills` when skill templates change. |

## Skill Scanner Policy

`Skill Security` starts with:

- `policy: balanced`
- `fail_on_severity: critical`
- `lenient: true`
- static analysis only; no LLM, cloud, or behavioral analyzers

This is intentionally conservative. The repo imports a large amount of third-party skill content, so the first goal is to establish a stable baseline without blocking normal work on noisy high-severity findings.

After reviewing initial GitHub Actions results, consider:

1. Raising the gate to `fail_on_severity: high`.
2. Enabling `use_behavioral: true`.
3. Adding a custom scanner policy for known acceptable imported patterns.
4. Enabling LLM analysis only if the repo has an agreed secret-management policy for `SKILL_SCANNER_LLM_API_KEY`.

