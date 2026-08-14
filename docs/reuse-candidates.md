# Reuse Candidates

## Promote To Templates

These are broadly reusable with placeholders:

- Repository scope and priorities
- Safe refactor boundaries
- Contract-first files
- Local command map
- JavaScript/TypeScript strict typing, ESM, boundary validation, async ownership, dependency, security,
  performance, and verification rules
- Testing and quality gates
- Angular coding standards
- Kotlin/JVM Gradle/toolchain alignment, project-fit module boundaries, language design, structured
  concurrency, compatibility, optional external boundaries, and layered testing
- Rust architecture, typed failures, contract/codegen discipline, bounded untrusted input,
  deterministic concurrency, and layered verification
- POSIX-first repository scripting, explicit interfaces, safe destructive boundaries, cleanup,
  portability, and representative-environment testing
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

Promoted as a first-party core skill:

- `github-keychain-auth`: use the existing macOS Keychain-backed GitHub CLI credential across
  projects, prevent stale token environment variables from overriding it, and prohibit exposing or
  transferring the credential itself.

Promoted as a first-party Node tooling skill:

- `inspect-node-package-api`: resolves the installed package version and public entry points,
  traces declaration re-exports, distinguishes conditional and subpath exports, and provides static
  runtime export hints without importing dependency code. It lives in the auto-detected `node`
  bundle and the broader opt-in `engineering` bundle. A local skill and deterministic helper were
  chosen over MCP because inspection is project-local and one-shot; persistent indexing or
  cross-project symbol queries would be the threshold for revisiting an MCP server.

Promoted as first-party workflow skills after the 2026-08-12 cross-repository workflow audit:

- `independent-review`: separates a maintainer-facing author explanation from a brand-new task's
  evidence-backed review of both the implementation and its plan;
- `orchestrated-delivery`: keeps a lead task responsible for requirements, dispatch contracts,
  reconciliation, and parent-level verification across agents or chats;
- `spec-traceability`: connects requirements and decisions to tasks, tests, evidence, and status;
- `session-handoff`: persists repo-neutral continuation state without making chat history canonical;
- `research-to-decision`: turns bounded investigation into cited, decision-ready repository output;
- `repository-doc-drift`: checks canonical documentation against code, tests, configuration, and
  recent history before making minimal corrections.

These are intentionally compact and first-party because the imported library already covers most
execution mechanics; the reusable gap was the contract between planning, delegation, independent
review, retained truth, and final integration. They are grouped into `orchestration` and
`documentation` rather than expanding the universal `core` bundle.

Promoted for evidence-bound technical storytelling:

- `project-story-miner`: builds a claim ledger and project timeline from repository evidence before
  prose drafting begins;
- `technical-blog-writer`: turns that evidence into a readable technical journey while separating
  fact, inference, and author recollection;
- `humanizer`: a compact adaptation of `blader/humanizer` used only as an optional final prose audit,
  with factual and technical precision taking precedence over stylistic smoothing.

These are grouped in the opt-in `writing` bundle so editorial guidance does not affect routine
engineering work.

Suggested next review question: decide whether these should live as Codex skills in this repo, a personal plugin, or just source material copied into target projects.

## Gaps To Fill

- Extend the project detector for `rush.json`, `go.mod`, Swift packages/Xcode projects,
  `.github/workflows`, and active monorepo manifests without letting archived nested apps create
  false positives.
- A merge/update mode that preserves local project additions instead of overwriting generated files.
- A provenance manifest with source path, hash, and last collected date for every raw file.
- Templates for Go, monorepos, CI, and security that are not tied to one project.

## Cross-Repository Refresh

The 2026-07-31 refresh is documented in
`docs/repository-ai-context-audit-2026-07-31.md`. It promoted:

- `templates/steering/rust-steering.md` and automatic `Cargo.toml` profile detection, alongside the
  existing Rust skill bundle;
- `templates/steering/shell-scripting-steering.md` as an explicit profile for repositories with
  substantial shared automation.

High-value candidates identified during local review for a later focused review:

- Capsule Corp's untrusted-execution and security-boundary guidance;
- Forage's local-first and privacy boundary guidance;
- Liars Dice Python/`uv`/`pytest` and deterministic simulation guidance, after its local-only AI
  files and research are committed upstream;
- Wap Labs' compliance-context retrieval and evidence-trust workflow.

## Reef Review

Reef keeps its current AI direction in `docs/steering/`, not only under `.codex/`. Those files were
reviewed locally but are not retained here because most of their content describes Reef's trading
domain and repository architecture rather than reusable JVM practice.

Promoted now:

- `templates/steering/kotlin-jvm-steering.md` and the `kotlin-jvm` profile. The normalized template
  retains general Kotlin/JVM and Gradle engineering rules while removing Reef paths, commands,
  framework choices, market concepts, and prescriptive domain architecture.
- `templates/skills/adapted/kotlin-jvm-engineering/` and the `jvm` bundle. Guided setup selects the
  profile and bundle together when Kotlin source or Gradle Kotlin DSL is detected.

Other Reef language, data, API, and architecture documents were not imported. Any future template
should start with a fresh domain-neutral review rather than copying those project policies.

## Strict Language Steering Review

The 2026-07-31 primary-source review is documented in
`docs/language-steering-research-2026-07-31.md`. It promoted:

- a separate, automatically detected `javascript-typescript` profile instead of installing
  JavaScript rules from the stack-neutral `base` profile;
- strict, consistently structured JavaScript/TypeScript, Kotlin/JVM, Rust, and POSIX shell
  templates covering reproducibility, maintainability, input and resource safety, dependencies,
  concurrency, performance, tests, and executable quality gates;
- regression checks that keep domain terminology out, require shared enforcement sections, verify
  direct and detected installation, and prevent JavaScript steering from leaking into pure Rust or
  base installations.

The templates use placeholders for repository commands and supported versions. They avoid imposing
frameworks, service layouts, product domains, or one universal architecture.

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
