# Skill Bundles

Use `scripts/install-skill-bundle.sh` to copy reviewed skills into a target project's `.codex/skills` directory.

The installer is non-overwriting: existing skill folders are skipped.

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

## Bundles

| Bundle | Contents |
| --- | --- |
| `core` | Lightweight planning, frontend review, context engineering, spec, planning, TDD, review, debugging, source-driven development |
| `engineering` | All `addyosmani/agent-skills` plus selected engineering skills from `alirezarezvani/claude-skills` |
| `rust` | All imported Rust Agentic Skills, prefixed as `rust-*` |
| `product` | Selected non-duplicate PM Skills plus selected product-team Claude Skills |
| `planning` | `planning-files-lite` and full `planning-with-files` |
| `frontend` | Frontend design review, frontend UI engineering, browser testing, a11y, Playwright review, UI design system |
| `all` | Installs every bundle above |

## Naming

Some imported skills are prefixed during installation to avoid collisions:

- `rust-*` for Rust Agentic Skills
- `pm-*` for PM Skills
- `claude-*` for selected Claude Skills

The original copied sources remain under `templates/skills/imported/`.
