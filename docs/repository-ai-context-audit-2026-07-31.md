# Repository AI Context Audit — 2026-07-31

## Scope

This refresh reviewed the 44 local checkout directories under `/Users/dsteele/repos` whose
`origin` points to `dills122` on GitHub. The scan covered root AI entrypoints and common
repository-owned context locations:

- `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`;
- `.codex/steering/`, `.codex/skills/`, `.codex/agents/`, and `.codex/prompts/`;
- `.claude/agents/`, `.claude/commands/`, and `.claude/rules/`;
- `.cursor/rules/`;
- `.github/copilot-instructions.md`, `.github/instructions/`, and `.github/prompts/`;
- canonical `docs/steering/` and `docs/agents/` trees referenced by AI entrypoints.

Dependency, build, coverage, generated, vendor, temporary, and nested worktree directories were
pruned. Symlinks and exact copies were compared with existing AI Central templates.

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

The review deliberately does not copy the newly inspected Reef, Wap Labs, Forage, Capsule Corp, or
Liars Dice AI files into `collected/`. Although they contain reusable ideas, the files also encode
product concepts, repository layouts, framework choices, operational commands, and local policy.
AI Central retains only normalized guidance that is useful without that project context.

No additional project-owned files were found under `.claude/agents/`, `.claude/commands/`,
`.claude/rules/`, `.codex/agents/`, `.codex/prompts/`, `.github/instructions/`, or
`.github/prompts/`. Those locations are included in the collector for explicitly authorized future
source collection.

## Review Provenance

### Wap Labs

- repository: `dills122/wap-labs`
- branch: `codex/post-533-planning-sync`
- commit: `642e8e0cf192c6d105114a15e2d8838154f1efeb`
- AI source status at review: clean

The review covered root entrypoints and canonical agent standards for Rust, transport, shell,
scripting, and compliance-context retrieval. Project paths, WAP protocol rules, runtime ownership,
work-item identifiers, and repository commands were not retained.

### Forage

- repository: `dills122/forage`
- branch: `codex/docs-audit-cleanup`
- commit: `67059a68d1df2be397998431b62b2f3b339aae1d`
- worktree status at review: clean

The review found useful local-first and privacy boundaries. The source remains in Forage because it
also defines that product's storage, authorization, and repository behavior.

### Capsule Corp

- repository: `dills122/capsule-corp`
- branch: `codex/license-free-spikes`
- commit: `1f9f55bf2c7cc25b936dc9e2ceb343113f398c3c`
- worktree status at review: dirty outside the selected AI files

Only committed AI files were evaluated. Secure-execution ideas are candidates for a later
domain-neutral template; Capsule architecture and policy were not retained.

### Liars Dice

- repository: `dills122/liars-dice`
- branch: `main`
- commit: `f4b4d201252ac038bf5853cbedf85adf8297f3b9`
- worktree status at review: dirty, including a modified `CLAUDE.md`

The committed file and local-only guidance were reviewed separately. Python tooling ideas may be
useful later, but game rules, player workflows, local modifications, and untracked research were not
imported.

## Reusable Promotions

- `templates/steering/rust-steering.md` contains general Rust project, API, error, input-safety,
  concurrency, testing, and verification guidance. Guided setup selects the profile and existing
  Rust skill bundle when it detects `Cargo.toml`.
- `templates/steering/shell-scripting-steering.md` contains general portable automation guidance. It
  remains an explicit profile because a few shell files do not establish repository-wide policy.

Both templates use placeholders, make optional boundaries conditional, and leave repository-local
instructions authoritative.

## Future Candidates

- a general secure-execution boundary derived from multiple independent sources;
- a local-first or privacy profile that does not assume Forage's product architecture;
- Python, `uv`, `pytest`, and deterministic test guidance from a source with stable committed
  provenance;
- an evidence-retrieval skill that is independent of Wap Labs protocols and work-item identifiers.

## Exclusions

- `pnpm` is a fork/upstream-derived repository and needs separate provenance and licensing review.
- `origin-liars-dice` points to another GitHub owner and is not a first-party source.
- AI Central symlinks and byte-identical template copies were not duplicated.
- nested worktrees and duplicate Reef checkouts were pruned.
- temporary third-party material under Wap Labs `tmp/` was excluded.
- dependencies, generated output, implementation files, broad product documentation, and
  uncommitted or ignored local-only guidance were not collected.
