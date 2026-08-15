# Link Mode

AI Central supports symlink-based installation for reusable content.

Use link mode when you want projects to reference centrally maintained skills and generic steering instead of copying those files into every repository.

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode link
```

Installation remains additive unless `--sync` is explicitly supplied.

## Hybrid Behavior

Link mode is intentionally hybrid:

- Repo-specific files are still copied so they can be customized.
- Reusable files and skills are symlinked back to AI Central.

Copied in link mode:

- `AGENTS.md`
- `.codex/steering/repository-steering.md`
- `.codex/steering/testing-quality-gates-steering.md`

Symlinked in link mode:

- reusable steering such as JavaScript/TypeScript, Angular, Kotlin/JVM, Rust, shell, and
  frontend-design
- Payload Cursor rules
- `.agents/skills/*` installed from skill bundles
- `.codex/skills/*` compatibility links pointing to the canonical project skill entries

## Tradeoffs

Benefits:

- fewer files committed to every project
- centralized updates to reusable skills
- smaller project diffs
- easier testing of new skill versions across repos

Costs:

- symlinks depend on the local AI Central path
- cloned projects on another machine need to run setup again
- project history will not contain exact copies of linked skill content
- CI systems may need AI Central checked out at the same path if they inspect linked files

## Recommended Use

For personal/local multi-repo workflows:

```sh
./scripts/setup-ai-context.sh /Users/dsteele/repos/my-project --yes --mode link
```

For shared repos or open-source projects:

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode copy
```

Use copy mode when portability matters more than centralized updates.

## Pruning Deselected Managed Links

When a link-mode project's selection changes, preview a synchronized installation:

```sh
./scripts/setup-ai-context.sh /path/to/project \
  --yes \
  --bundles core,frontend-tooling \
  --skip-skills vite,vitest,turborepo,vitepress,slidev \
  --mode link \
  --sync \
  --dry-run
```

The preview includes exact managed-link removals. Sync prunes only canonical skill symlinks whose
installed name is known and whose target exactly matches its source in the current AI Central
checkout. A corresponding compatibility link is pruned only when it points to that canonical
entry. The installer leaves real directories, copied skills, adopted legacy content, and foreign,
repointed, or stale-checkout links untouched.

This conservative target check may require manual cleanup if the AI Central checkout moved after
links were installed. That is intentional: an unverifiable link is treated as project-owned rather
than deleted. Sync is unavailable in copy mode.
