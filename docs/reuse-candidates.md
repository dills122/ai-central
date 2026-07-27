# Reuse Candidates

## Promote To Templates

These are broadly reusable with placeholders:

- Repository scope and priorities
- Safe refactor boundaries
- Contract-first files
- Local command map
- JavaScript/ESM rules
- Testing and quality gates
- Angular coding standards
- Payload CMS rules
- Branch and PR metadata expectations
- OpenTofu lifecycle boundaries: exact tool/provider pins, committed cross-platform locks,
  credential-free static checks, runtime-only backend configuration, protected plan/apply,
  state recovery, least-privilege ingress, and explicit live-operation authority

## Keep As Source Reference

These are valuable, but should not be installed verbatim into most projects:

- `trove` product-specific bookmark cleanup steering
- `footy-data-kit` football data pipeline details
- `wap-labs` WAP emulator architecture and layer map
- Project-specific infrastructure paths, provider/region choices, state keys, ticket gates,
  hostnames, cost thresholds, and incident ownership
- `paylet` and app-specific AGENTS content until reviewed for private domain details
- Cursor rules that embed Payload-specific examples when the target project is not Payload

## Promote As Skills

These look useful across multiple repositories:

- `find-bugs`
- `gha-security-review`
- `property-based-testing`
- `differential-review`
- `variant-analysis`
- `coverage-analysis`
- `harness-writing`
- `create-prd`
- `release-notes`
- `sprint-plan`
- `user-stories`

Suggested next review question: decide whether these should live as Codex skills in this repo, a personal plugin, or just source material copied into target projects.

## Gaps To Fill

- A project detector that reads `package.json`, `rush.json`, `Cargo.toml`, `go.mod`, `.github/workflows`, and app folders before selecting templates.
- A merge/update mode that preserves local project additions instead of overwriting generated files.
- A provenance manifest with source path, hash, and last collected date for every raw file.
- Templates for Rust, Go, shell scripting, monorepos, CI, and security that are not tied to one project.

## Infrastructure And OpenTofu Review

The reusable infrastructure steering template promotes the common safety boundary rather than a
provider-specific stack. Review evidence came from active OpenTofu implementations in `wap-labs`,
`reef`, and `liars-dice-private`, plus Trove's steering-index and precedence model.

The normalized Wap source is preserved at
`collected/misc/wap-labs/.codex/steering/infrastructure-opentofu-steering.md`, collected on
2026-07-26 from feature commit `acee3c772f885d957dc85d7d116fa08c73d3e2f8` and draft PR
`dills122/wap-labs#441`. This is feature-source provenance, not a claim that the source was already
merged to `wap-labs` main at collection time.

Promoted:

- explicit ownership and environment/lifecycle boundaries;
- exact runtime/provider review and committed multi-platform dependency locks;
- backend capability verification, runtime-only backend inputs, state/plan encryption, locking,
  and recovery;
- credential-free static validation separated from protected plan/apply;
- default-deny ingress, bounded public services, safe bootstrap, and tested disable/rollback;
- non-overwriting installation, with repository guidance taking precedence over reusable skills.

Not promoted:

- project names, paths, regions, state keys, ticket IDs, budgets, and hostnames;
- local state as a general default for shared/durable infrastructure;
- unpinned CI actions, unattended destructive operations, or secret-bearing user data;
- assumptions that every S3-compatible backend supplies AWS S3 locking, versioning, or recovery.

## External Skill Sources

See `docs/external-skill-review.md` for recommendations from locally cloned upstream skill repositories.

Imported and adapted skills now live under `templates/skills/`. Attribution is maintained in `docs/skill-attribution.md` and `THIRD_PARTY_NOTICES.md`.

### `JuliusBrussee/caveman`

Why: Portable token-saving skills fit this repo's goal of reusable agent context across projects. The main `caveman` skill can be installed everywhere without running machine-wide hooks, while commit/review/help/compress skills give focused workflows for shorter outputs and lower context cost.

Integration status: imported upstream skills and agent presets under `templates/skills/imported/caveman/`; exposed portable skills through the `brevity` bundle. The upstream global installer, Claude Code hooks/statusline, and optional MCP shrink proxy are not scaffolded by default.
