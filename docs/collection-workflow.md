# Collection Workflow

Use this workflow when refreshing source material from local projects.

## Source Root

Default project root:

```sh
/Users/dsteele/repos
```

Run the conservative collector:

```sh
./scripts/collect-ai-context.sh /Users/dsteele/repos
```

The collector copies matching files into `collected/misc/` using source-relative paths and refreshes the source manifest.

## What To Collect

Collect AI guidance and reusable context from:

- `.codex/steering/`
- `.codex/agents/` and `.codex/prompts/`
- `docs/steering/` when the project treats it as canonical AI/engineering direction
- `docs/agents/` when a root AI entrypoint imports it as canonical guidance
- `.codex/skills/`
- `.claude/agents/`, `.claude/commands/`, and `.claude/rules/`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `.cursor/rules/`
- `.github/copilot-instructions.md`
- `.github/instructions/` and `.github/prompts/`

Skip:

- `node_modules/`
- `.git/`
- generated build output
- linked or copied agent worktrees under `.claude/worktrees/` and `.worktrees/`
- temporary third-party imports until reviewed

## After Collection

1. Keep copied files under `collected/`.
2. Preserve source provenance in folder names.
3. Update `docs/inventory.md`.
4. Update `docs/reuse-candidates.md`.
5. Regenerate the manifest:

```sh
./scripts/refresh-source-manifest.sh
```

## Promotion

Do not install collected material directly into projects by default.

Promotion path:

1. Review collected source.
2. Extract reusable rules into `templates/`.
3. Replace project-specific content with placeholders.
4. Add or update a scaffold profile if the template should be installable.
