# Repository AI Context Audit — 2026-07-31

## Scope

This refresh reviewed the 44 local checkout directories under `/Users/dsteele/repos` whose
`origin` points to `dills122` on GitHub. The scan covered root AI entrypoints and the common
repository-owned context locations:

- `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`;
- `.codex/steering/`, `.codex/skills/`, `.codex/agents/`, and `.codex/prompts/`;
- `.claude/agents/`, `.claude/commands/`, and `.claude/rules/`;
- `.cursor/rules/`;
- `.github/copilot-instructions.md`, `.github/instructions/`, and `.github/prompts/`;
- canonical `docs/steering/` and `docs/agents/` trees referenced by AI entrypoints.

Dependency, build, coverage, generated, vendor, temporary, and nested worktree directories were
pruned. The audit also compared symlinks and exact copies against existing AI Central templates so
they would not be re-imported as new source.

## Result

Current first-party AI context was found in AI Central itself and these active project checkouts:

- `reef`
- `wap-labs`
- `forage`
- `capsule-corp`
- `liars-dice`
- `footy-data-kit`
- `trove`
- `paylet`

The earlier collection already preserves useful sources from Footy Data Kit, Trove, Paylet, and
other projects. The focused Reef review is documented in `docs/inventory.md`. This refresh adds 16
committed source files from Wap Labs, Forage, Capsule Corp, and Liars Dice.

No additional project-owned files were found under `.claude/agents/`, `.claude/commands/`,
`.claude/rules/`, `.codex/agents/`, `.codex/prompts/`, `.github/instructions/`, or
`.github/prompts/`. Those locations are now included in the collector so future additions are not
missed.

## Imported Sources And Provenance

All files below were copied from the named commit, not from an uncommitted working-tree version.

### Wap Labs

- repository: `dills122/wap-labs`
- branch: `codex/post-533-planning-sync`
- commit: `642e8e0cf192c6d105114a15e2d8838154f1efeb`
- AI source status at collection: clean
- imported: root and spec-processing `CLAUDE.md`, plus six canonical files under `docs/agents/`

The root `CLAUDE.md` imports `AGENTS.md` and the `docs/agents/` files. The new source material covers
repository-wide agent standards, Rust engine and transport boundaries, portable shell, repository
scripting, and trustworthy compliance-context retrieval. The earlier focused infrastructure import
remains separate historical source with its original feature-branch provenance.

### Forage

- repository: `dills122/forage`
- branch: `codex/docs-audit-cleanup`
- commit: `67059a68d1df2be397998431b62b2f3b339aae1d`
- worktree status at collection: clean
- imported: `AGENTS.md`, repository steering, and testing/quality-gate steering

Forage's JavaScript and frontend-design steering files were skipped because they are byte-identical
to existing AI Central templates.

### Capsule Corp

- repository: `dills122/capsule-corp`
- branch: `codex/license-free-spikes`
- commit: `1f9f55bf2c7cc25b936dc9e2ceb343113f398c3c`
- worktree status at collection: dirty outside the selected AI files
- imported from committed `HEAD`: `AGENTS.md`, `CLAUDE.md`, repository steering, and
  testing/quality-gate steering

The JavaScript steering symlink back to AI Central was skipped. Uncommitted implementation and
documentation changes in the checkout were not collected.

### Liars Dice

- repository: `dills122/liars-dice`
- branch: `main`
- commit: `f4b4d201252ac038bf5853cbedf85adf8297f3b9`
- worktree status at collection: dirty, including a modified `CLAUDE.md`
- imported from committed `HEAD`: `CLAUDE.md`

Local `AGENTS.md` and `.codex/` content are excluded through the checkout's `.git/info/exclude`, and
the probabilistic-bot steering references untracked research. Those local files were reviewed as
candidates but were not imported because they are not committed project source.

## Reusable Promotions

This audit promotes two normalized templates:

- `templates/steering/rust-steering.md`, distilled mainly from Wap Labs' Rust engine and untrusted
  transport guidance. It adds a `rust` scaffold profile; guided setup selects the profile and the
  existing Rust skill bundle when it detects `Cargo.toml`.
- `templates/steering/shell-scripting-steering.md`, distilled from Wap Labs' shell and scripting
  standards. It is an explicit profile because the presence of a few shell files alone does not
  prove that a repository wants a broad scripting policy.

Both templates replace project paths and commands with placeholders and leave repository-local
instructions authoritative.

## Future Candidates

- Capsule Corp's untrusted-execution and security-boundary rules are a strong candidate for a
  general secure-execution steering template after a focused normalization review.
- Forage's local-first and privacy boundaries could become a small reusable data-ownership or
  local-first profile.
- Liars Dice could supply Python, `uv`, `pytest`, and deterministic simulation guidance after its
  current local AI files and referenced research are reviewed and committed upstream.
- Its probabilistic-agent guidance is valuable but specialized; keep it project-local until the
  research dependency has stable provenance.
- Wap Labs' compliance-context retrieval guidance may become a reusable skill for evidence trust,
  source ranking, and citation hygiene after testing it outside the Wap protocol domain.

## Exclusions

- `pnpm` is a fork/upstream-derived repository and needs a separate provenance and licensing review.
- `origin-liars-dice` points to another GitHub owner and is not a first-party source.
- AI Central symlinks and byte-identical template copies were not duplicated.
- nested `.claude/worktrees/`, `.worktrees/`, and duplicate Reef worktree checkouts were pruned.
- temporary third-party material under Wap Labs `tmp/` was excluded.
- dependencies, generated output, implementation files, broad product documentation, and
  uncommitted or ignored local-only guidance were not collected.
