# Template Taxonomy

AI Central separates reusable project context into two main categories.

## Project Templates

Project templates are stack, language, platform, or domain specific.

Examples:

- `templates/steering/angular-steering.md`
- `templates/steering/javascript-esm-steering.md`
- `templates/steering/frontend-design-steering.md`
- `templates/cursor-rules/payload-overview.md`

Use these when a project has a concrete technology or domain signal.

Future project template categories:

- Languages: Rust, Go, Python, TypeScript, JavaScript
- Frameworks: Angular, React, Next.js, Payload, NestJS
- Platforms: Cloudflare, AWS, Azure, Kubernetes, Tauri
- Domains: data pipelines, browser extensions, SaaS dashboards, local-first apps
- Repo shapes: monorepo, package library, CLI, worker/service, PWA

## Reusable Skills

Reusable skills are task or persona oriented. They usually do not need project-specific edits before installation.

Examples:

- product manager and discovery skills
- designer/frontend review skills
- architect/API review skills
- debugger, reviewer, tester, security, and source-driven development skills

Skills are installed into `.codex/skills` through bundles.

## Selection Model

The setup CLI uses:

- detected project facts for recommendations
- explicit profile/bundle flags for repeatable setup
- skip flags for exclusion
- non-overwriting copies for safety

The long-term direction is to add machine-readable metadata for templates and skills so richer UIs can filter by language, domain, persona, task, risk, license, and dependencies.

Initial machine-readable metadata lives in `templates/catalog.json`.
