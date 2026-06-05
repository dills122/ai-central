# Link Mode

AI Central supports symlink-based installation for reusable content.

Use link mode when you want projects to reference centrally maintained skills and generic steering instead of copying those files into every repository.

```sh
./scripts/setup-ai-context.sh /path/to/project --yes --mode link
```

## Hybrid Behavior

Link mode is intentionally hybrid:

- Repo-specific files are still copied so they can be customized.
- Reusable files and skills are symlinked back to AI Central.

Copied in link mode:

- `AGENTS.md`
- `.codex/steering/repository-steering.md`
- `.codex/steering/testing-quality-gates-steering.md`

Symlinked in link mode:

- reusable steering such as JavaScript/ESM, Angular, frontend-design
- Payload Cursor rules
- `.codex/skills/*` installed from skill bundles

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
