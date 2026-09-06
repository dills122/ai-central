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
shared common directory. The Git hook below invokes that wrapper directly; it also remains
available as a Codex Local Environment setup script.

## Install The Git Hook

Install once per consuming repository's local clone, using the checkout that owns its local
AI Central context as the source:

```sh
/path/to/ai-central/scripts/install-worktree-context-hook.sh /path/to/primary-checkout --dry-run
/path/to/ai-central/scripts/install-worktree-context-hook.sh /path/to/primary-checkout
```

If `post-checkout` already exists, pass `--replace-hook` explicitly (also during the preview).
The installer backs up the old hook beside it and preserves other commands. Repeat installation
is a no-op when the managed block is current. Requires POSIX shell, Git, and Python 3.9+; CCE
is not required. Keep both the source checkout and AI Central at their installed absolute paths,
or reinstall the hook after moving them. Hooks are local configuration, not transferred by clone.

Git invokes the hook during ordinary `git worktree add` after checkout. The hook recognizes the
new-worktree invocation, clears inherited Git repository environment variables in a subshell,
then seeds and audits context synchronously using the configured source. Errors remain visible
and return a failure to Git; the newly created worktree may still exist, so fix the cause and rerun
`setup-codex-worktree.sh` on that worktree. Ordinary branch switches do not reseed context.

Git has one `post-checkout` file. The context and CCE installers maintain separate blocks in it.
When both are installed, context seeding comes first regardless of installation order; the CCE
block then prepares its independent index. Both managed blocks precede unmanaged commands,
including existing early exits. The relative order of the unmanaged commands is preserved.
Installing the context block does not add or remove CCE.

The installer refuses relative `core.hooksPath`, external shared hook managers, symlinked hook files,
and non-shell hooks. Integrate `templates/worktree/context-post-checkout.sh` into the existing hook
manager for those layouts; resolve its placeholders and arrange synchronous execution before CCE.
To undo installation, inspect subsequent hook edits before restoring the saved backup.

Hooks do not cover `git worktree add --no-checkout`, disabled hooks, or worktree creation that
bypasses Git's hook dispatch. Keep the setup script as an idempotent fallback and verify a real
Codex-created worktree in the consuming repository before removing any existing fallback.
The tests here exercise Git dispatch; they do not prove every Codex app creation path invokes it.

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

Real files and directories are copied. Relative symlinks within the source checkout keep their
relative targets, while relative links outside it are anchored to their original absolute paths
so deeply nested worktrees can still reach shared AI Central skills. Whole allowlisted skills,
steering, and agent directory symlinks are supported. Seeding refuses writes through symlinked
target parent directories. Supplied directory roots that are dangling or point to files fail the
final audit. If a project still has only legacy `.codex/skills` entries, the
seeder adds non-overwriting canonical `.agents/skills` links to them so current Codex discovery can
find those skills.

A whole `.agents/skills` directory link is authoritative. Legacy entries are still copied to
`.codex/skills`, but automatic alias adoption is skipped with a diagnostic rather than writing
through the shared canonical directory. Add legacy-only skills to the shared selection explicitly
if they should be available through canonical discovery.

Relative-link rewriting applies to manifest-level links: whole allowlisted directory links or
immediate entries. Symlinks nested inside a copied real directory retain their existing link text.
External relative links at those deeper levels can still break after relocation; recursive
rewriting is a pre-existing limitation outside this hook change. Check that layout before rollout.

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

## CCE Index Preparation

For projects using Code Context Engine, add `--cce` to the setup command to reuse the primary
checkout's embedding cache and build an independent worktree index. See
[CCE worktree seeding](cce-worktrees.md) for version requirements, MCP binding, and validation.
