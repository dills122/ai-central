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
| `frontend` | General frontend design review, UI engineering, browser testing, accessibility, Playwright review, UI design systems, and web quality |
| `frontend-tooling` | Vite, Vitest, pnpm, Turborepo, VitePress, and Slidev; install only when those tools are actually in use |
| `frontend-vue` | Vue, Vue best practices, Vue Router, Vue testing, Nuxt, Pinia, VueUse, UnoCSS |
| `hallmark` | Opt-in creative-direction workflow for distinctive landing pages, portfolios, UI redesigns, audits, and design studies |
| `infra` | Terraform/OpenTofu review, debugging, CI, state, security, testing, and rollback guidance |
| `workflow` | Architecture diagrams, handoff docs, requirements clarity, QA planning, README writing, Mermaid diagrams, OpenAPI TypeScript, React workflow skills |
| `all` | Installs every bundle above |

`brevity` intentionally installs only portable skill content. It does not run the upstream global installer, add Claude Code hooks/statusline files, or register the optional MCP shrink proxy.

`core` is the only automatic bundle selected by `setup-ai-context.sh`. All other bundles are opt-in or selected from concrete project signals. This keeps routine context small and avoids loading unrelated tool or persona guidance.

## Naming

Some imported skills are prefixed during installation to avoid collisions:

- `rust-*` for Rust Agentic Skills
- `pm-*` for PM Skills
- `claude-*` for selected Claude Skills
- `web-*` for Web Quality Skills
- `toolkit-*` for selected Agent Toolkit skills

The original copied sources remain under `templates/skills/imported/`.
