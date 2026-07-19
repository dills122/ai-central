# Context Management Audit — 2026-07-19

## Scope and evidence

Reviewed 120 existing installable `SKILL.md` files, four steering templates, the scaffold/install scripts, and `Nutlope/hallmark` at commit `aeb42fb354ff4efa36ab475773a082315a3af2ce` (MIT). The audit adds one adapted skill.

The governing approach is deliberately layered:

- Keep `AGENTS.md` short and repository-specific; add rules only for recurring mistakes, feedback, commands, and routing. Codex explicitly recommends small project guidance and closest-scope instructions ([OpenAI customization guidance](https://learn.chatgpt.com/docs/customization/overview)).
- Put rich, reusable procedures in skills. Codex exposes skill metadata without preloading the whole workflow, so skills should use concise descriptions and progressive references ([OpenAI skills guidance](https://learn.chatgpt.com/docs/customization/overview)).
- Do not auto-install broad catalogs. Claude likewise loads skill descriptions into session context and keeps invoked skill contents for the rest of the session; excessive bundles consume context and increase instruction conflicts ([Claude Code skills](https://code.claude.com/docs/en/skills)).
- Share stable guidance by symlink where central maintenance matters, while keeping project rules higher priority than personal defaults ([Claude Code memory](https://code.claude.com/docs/en/memory)).

## Findings and actions

| Finding | Decision |
| --- | --- |
| The source library is well-provenanced: imported and adapted material is separated and licenses are tracked. | Keep this model; no wholesale pruning of historical imports. |
| Setup previously installed `core,brevity` for every project and added the full engineering bundle merely because `package.json` existed. | Make `core` the only automatic bundle. `brevity`, `engineering`, product, planning, and infrastructure remain explicit opt-ins. |
| The frontend bundle mixed general UI guidance with Vite/Vitest/pnpm/Turborepo/VitePress/Slidev instructions, regardless of the target framework. | Split toolchain skills into a new explicit `frontend-tooling` bundle; leave general frontend guidance in `frontend`. |
| Existing frontend skills overlap in theme but have distinct roles: `frontend-design-review` is cross-cutting QA, `frontend-ui-engineering` is implementation, and `web-*` covers measurable quality. | Retain all three layers; document Hallmark as a creative-direction specialist rather than duplicate any as a default. |
| Hallmark is a MIT-licensed, reference-heavy design skill. Its full upstream reference library is nearly 1 MB and is valuable only for intentional design work. | Record the reviewed source and add a compact, substantially adapted `hallmark-design` skill in a new opt-in bundle. Preserve the upstream clone under ignored `external/hallmark` for future re-review. |
| No first-party project plugin exists in this repository. | Do not invent a plugin: skills are the authoring unit, plugins are useful only when distributing a bundle or pairing it with tools/connectors. |

## Operating policy

1. Default a project to `AGENTS.md`, steering, and the `core` bundle only.
2. Select additional bundles from actual evidence in the project or a user request—not from a broad ecosystem label such as “Node project.”
3. Keep framework and tool-specific skills out of general bundles.
4. For new external skills, review the license, commit, scripts, overlapping workflows, token cost, and routing description before promotion.
5. Prefer a compact adaptation with progressive references over copying large upstream catalogs. Copy the complete source only where its references are essential and its licence/provenance are recorded.

## Follow-up cadence

Re-audit after a major Codex/Claude customization change, when a bundle grows by 20% or more, or at least every six months. Use recurring user feedback and repeated agent mistakes—not speculative style rules—to decide what belongs in `AGENTS.md`.
