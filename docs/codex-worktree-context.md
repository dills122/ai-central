# Codex Worktree Context

Codex-managed worktrees start from committed Git content. Project guidance, skills, and steering
that exist only in the primary checkout's local Git exclusions are therefore absent unless they are
seeded explicitly.

AI Central provides a two-stage, non-overwriting bridge:

1. `create-worktree-context-manifest.sh` inspects the primary checkout and records allowlisted,
   locally ignored Codex context.
2. `seed-worktree-context.sh` copies real files and directories or recreates symlinks in the new
   worktree.

`setup-codex-worktree.sh` composes both stages and auto-discovers the primary checkout from Git's
shared common directory. Use that wrapper as the setup script for a Codex Local Environment.

## Configure Codex

In the ChatGPT desktop app, open the project's Codex Local Environment settings and use:

```sh
/path/to/ai-central/scripts/setup-codex-worktree.sh "$PWD"
```

Codex runs the setup command after creating a managed worktree and before beginning the task. The
wrapper exits successfully without changing anything when invoked in the primary checkout.

Preview an existing worktree without writing:

```sh
/path/to/ai-central/scripts/setup-codex-worktree.sh /path/to/worktree --dry-run
```

Pass the source explicitly when the primary checkout cannot be inferred:

```sh
/path/to/ai-central/scripts/setup-codex-worktree.sh /path/to/worktree \
  --source /path/to/primary-checkout
```

## What Is Seeded

The manifest includes only paths that Git reports as ignored in the primary checkout and that match
this allowlist:

- `AGENTS.md` and `AGENTS.override.md`;
- immediate entries under `.agents/skills/`;
- immediate entries under `.codex/skills/`;
- immediate entries under `.codex/steering/`; and
- immediate entries under `.codex/agents/`.

The scanner does not copy every ignored file. In particular, it does not seed `.env` files,
credentials, build outputs, caches, or arbitrary locally excluded paths.

Real files and directories are copied. Symlinks are recreated with the same target, preserving the
shared AI Central link pattern. If a project still has only legacy `.codex/skills` entries, the
seeder adds non-overwriting canonical `.agents/skills` links to them so current Codex discovery can
find those skills.

## Safety And Refresh Behavior

- Existing target paths are skipped, never replaced.
- Source and target must belong to the same Git repository unless the lower-level manifest and
  seeder commands are invoked directly.
- Manifest paths are validated against the same allowlist before they are applied.
- A symlink is rejected if its source target changed after manifest creation.
- The final AI context audit reports broken links, missing skill metadata, and unresolved template
  placeholders.

This process mirrors the primary checkout's selected context. Refresh the primary checkout's AI
Central integration when changing profiles or bundles; subsequent Codex worktrees will inherit the
new selection automatically.
