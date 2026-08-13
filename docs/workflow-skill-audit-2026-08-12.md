# Workflow Skill Audit — 2026-08-12

## Scope

Review AI Central and the recurring local-repository workflow: repository specs are authoritative,
a lead or "brain" task plans larger outcomes, bounded work moves to agents or separate tasks, and
results return as verified repository changes and durable handoffs.

The review favored a small reusable surface over installing every available skill. It compared the
existing 123 skill definitions, installer behavior, detector behavior, prior cross-repository audit
notes, and current primary documentation for Codex skills and subagents.

## Primary-Source Findings

- Codex now scans repository skills from `.agents/skills` between the current directory and repo
  root and supports symlinked skill directories. Repository-local direct skills remain appropriate
  for repo-scoped workflows. See [Build skills](https://learn.chatgpt.com/docs/build-skills).
- Codex initially exposes only skill names and descriptions, with a bounded initial-list budget;
  large catalogs can have shortened descriptions or omitted skills. This supports narrow default
  bundles rather than installing `all`. See [Build skills](https://learn.chatgpt.com/docs/build-skills).
- Subagents are best suited to independent exploration, tests, triage, and summarization. Parallel
  write-heavy work needs tighter ownership because conflicts and coordination overhead increase.
  The lead task remains responsible for collecting results. See
  [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents).
- Direct skills should define the workflow; plugins are the distribution layer when multiple
  skills or connectors need broad installation. The current need is repo-scoped and source-of-truth
  heavy, so connector plugins remain optional instead of becoming core dependencies.

## Gaps Found

The imported catalog already covered implementation, TDD, code review, debugging, planning files,
ADRs, diagrams, Git, CI, and launch checks. The recurring gaps were coordination contracts rather
than another large library:

1. choosing between an internal subagent, independent task, and research assignment;
2. keeping requirements, decisions, tasks, tests, and evidence traceable across those boundaries;
3. producing a repo-neutral handoff instead of relying on one tool's historical directory;
4. converting delegated research into a retained, decision-ready artifact;
5. auditing canonical documentation against current code and executed evidence.

Five small first-party skills now cover those gaps: `orchestrated-delivery`, `spec-traceability`,
`session-handoff`, `research-to-decision`, and `repository-doc-drift`.

## Bundle Decision

| Layer | Skills | Intended use |
| --- | ---: | --- |
| `core` | 9 | Every project; routine planning, specification, implementation hygiene, and review |
| `orchestration` | 6 | Larger outcomes coordinated through several agents, tasks, or sessions |
| `documentation` | 5 | Canonical docs, ADRs, architecture views, and drift correction |
| `delivery` | 7 | Implementation through CI, self-evaluation, ship gates, and launch readiness |

Existing specialist bundles remain available. `all` is an audit mechanism, not a routine default.
The older `workflow` bundle remains for compatibility but overlaps the tighter new layers.

The four compact bundles are also expressed as local-dependency packages under `packages/apm/`.
An APM 0.28.0 disposable-consumer test installed all 27 unique skills, replayed the generated
lockfile with `--frozen`, and completed a clean drift audit. See `docs/apm.md` for the discovered
alias-replay and CI config-consistency limitations.

## Integration Fixes

- New installs own skills at `.agents/skills/<name>` and add `.codex/skills/<name>` compatibility
  links. Existing real legacy directories are never moved or overwritten; canonical discovery links
  to them until a deliberate migration is performed.
- Automatic `product` selection no longer follows from a `docs/` or `product/` folder alone.
- Nested legacy `angular.json` files no longer classify an unrelated repository as Angular;
  Angular auto-detection requires a root marker.
- JavaScript and frontend auto-selection requires active root project evidence before nested source
  files influence the recommendation.
- Astro source is recognized as active frontend evidence, covering the current marketing-site shape;
  generated, dependency, and build directories do not supply frontend source signals.
- `scripts/audit-ai-context.sh` detects unresolved `AGENTS.md` placeholders, legacy-only discovery,
  broken skill links, missing `SKILL.md`, and unusually large local catalogs.

## Deferred Candidates

- A connector-oriented project-management bundle could later pair repo task IDs with Linear,
  Atlassian, Notion, Slack, or Google Drive, but it should remain separate from source-of-truth
  repository workflows and require a demonstrated recurring need.
- Swift/iOS, Go, Python, monorepo, CI, and security profiles remain project-signal gaps. Add them as
  focused profiles only after reviewing active repositories and executable commands.
- A deliberate migration command for legacy real directories may be useful after project-by-project
  audits. The current installer chooses preservation over filesystem moves.

## Read-Only Project Smoke Test

The revised detector and audit were exercised against three current local shapes without changing
those repositories:

| Repository | Detected default | Audit result |
| --- | --- | --- |
| `booksie` | `base` + `core` | No root `AGENTS.md` or repository skills; Swift/iOS detection remains deferred |
| `safelet` | `base,javascript-typescript` + `core` | No root `AGENTS.md` or repository skills |
| `corp-marketing` | `base,javascript-typescript,frontend-design` + `core,frontend` | Correctly recognizes Astro; unresolved `AGENTS.md` placeholders and a legacy-only skill layout still require a deliberate project update |
