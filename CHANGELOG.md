# Changelog

All notable changes to this repository will be documented here.

## Unreleased

- Added repository-wide semantic versioning and Release Please automation, approval-gated major
  releases, annotated APM release tags, release metadata validation, and stable-tag defaults for
  downstream project manifests.
- Reviewed the APM integration against APM 0.29.0, made generated project manifests pin explicit
  targets and the current AI Central commit by default, documented the production and CI workflow,
  and added pinned APM package integration checks to CI.
- Added an explicit `.NET Clean Architecture` steering profile and an adapted `dotnet-architecture`
  skill based on a provenance-recorded review of the full and minimal `ardalis/CleanArchitecture`
  templates, with proportionate boundary selection, transaction/event cautions, architecture
  enforcement, and layered verification.
- Added generated Microsoft APM manifests for every skill bundle plus `all`, preserving prefixed
  installed names through explicit aliases and validating full-catalog installs plus alias-free
  frozen replay and drift audits.
- Added an opt-in `writing` bundle with first-party project-story mining and technical blog writing
  skills plus a compact, attributed adaptation of `blader/humanizer` for final prose audits.
- Made `.agents/skills` the canonical project skill location with non-overwriting
  `.codex/skills` compatibility symlinks and a project AI-context audit command.
- Added compact `orchestration`, `documentation`, and `delivery` bundles and five first-party skills
  for coordinated delivery, traceability, handoffs, retained research, and documentation drift.
- Tightened automatic bundle detection to avoid docs-folder product selection and nested legacy
  Angular/frontend false positives.
- Replaced the light JavaScript/ESM template with a strict, separately detected
  JavaScript/TypeScript profile and made `base` language-neutral.
- Strengthened Kotlin/JVM, Rust, and POSIX shell steering with primary-source, domain-neutral
  maintainability, safety, efficiency, and verification requirements.
- Initial source collection from local AI guidance files.
- Added reusable AGENTS, steering, Angular, JavaScript/ESM, testing, and Payload templates.
- Added scaffold helper for base, Angular, and Payload profiles.
- Added inventory, reuse review notes, and source hash manifest.
