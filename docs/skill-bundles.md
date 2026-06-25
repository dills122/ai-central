# Skill Bundles

Use `scripts/install-skill-bundle.sh` to copy reviewed skills into a target project's `.codex/skills` directory.

The installer is non-overwriting: existing skill folders are skipped.

For guided project setup, prefer `scripts/setup-ai-context.sh`.

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core
```

Use `--mode link` to symlink reusable skill directories instead of copying them:

```sh
./scripts/install-skill-bundle.sh /path/to/project --bundle core --mode link
```

## Bundles

| Bundle | Contents |
| --- | --- |
| `core` | Lightweight planning, frontend review, context engineering, spec, planning, TDD, review, debugging, source-driven development |
| `brevity` | Caveman token-saving skills for terse replies, help, commit messages, code review comments, and memory-file compression |
| `engineering` | All `addyosmani/agent-skills` plus selected engineering skills from `alirezarezvani/claude-skills` |
| `rust` | All imported Rust Agentic Skills, prefixed as `rust-*` |
| `product` | Selected non-duplicate PM Skills plus selected product-team Claude Skills |
| `planning` | `planning-files-lite` and full `planning-with-files` |
| `frontend` | Frontend design review, frontend UI engineering, browser testing, a11y, Playwright review, UI design system, web quality, Vite, Vitest, pnpm, Turborepo, VitePress, Slidev |
| `frontend-vue` | Vue, Vue best practices, Vue Router, Vue testing, Nuxt, Pinia, VueUse, UnoCSS |
| `infra` | Terraform/OpenTofu review, debugging, CI, state, security, testing, and rollback guidance |
| `workflow` | Architecture diagrams, handoff docs, requirements clarity, QA planning, README writing, Mermaid diagrams, OpenAPI TypeScript, React workflow skills |
| `all` | Installs every bundle above |

`brevity` intentionally installs only portable skill content. It does not run the upstream global installer, add Claude Code hooks/statusline files, or register the optional MCP shrink proxy.

## Naming

Some imported skills are prefixed during installation to avoid collisions:

- `rust-*` for Rust Agentic Skills
- `pm-*` for PM Skills
- `claude-*` for selected Claude Skills
- `web-*` for Web Quality Skills
- `toolkit-*` for selected Agent Toolkit skills

The original copied sources remain under `templates/skills/imported/`.
