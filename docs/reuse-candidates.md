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

## Keep As Source Reference

These are valuable, but should not be installed verbatim into most projects:

- `trove` product-specific bookmark cleanup steering
- `footy-data-kit` football data pipeline details
- `wap-labs` WAP emulator architecture and layer map
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

## External Skill Sources

See `docs/external-skill-review.md` for recommendations from locally cloned upstream skill repositories.

Imported and adapted skills now live under `templates/skills/`. Attribution is maintained in `docs/skill-attribution.md` and `THIRD_PARTY_NOTICES.md`.

### `JuliusBrussee/caveman`

Why: Portable token-saving skills fit this repo's goal of reusable agent context across projects. The main `caveman` skill can be installed everywhere without running machine-wide hooks, while commit/review/help/compress skills give focused workflows for shorter outputs and lower context cost.

Integration status: imported upstream skills and agent presets under `templates/skills/imported/caveman/`; exposed portable skills through the `brevity` bundle. The upstream global installer, Claude Code hooks/statusline, and optional MCP shrink proxy are not scaffolded by default.
