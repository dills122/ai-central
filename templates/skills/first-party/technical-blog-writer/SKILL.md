---
name: technical-blog-writer
description: Draft, rewrite, review, or structure technical blog posts, engineering retrospectives, architecture explainers, benchmark analyses, project stories, tutorials, how-to guides, and related series from a brief, evidence packet, notes, or source files. Use when prose must remain technically accurate, preserve facts and proof boundaries, explain why engineering details matter, and sound conversational and recognizably authored rather than generic or promotional.
---

# Technical Blog Writer

Produce technically serious writing that an engineer would choose to publish. Optimize for accuracy, reader value, a defensible point of view, and natural prose. Never invent experience to make a post feel personal.

## Load Only What Helps

- Read [references/document-types.md](references/document-types.md) to choose the primary form and structure.
- Read [references/editorial-method.md](references/editorial-method.md) for rewrites, series work, or a full editorial pass.
- Read [references/voice-calibration.md](references/voice-calibration.md) when the user provides writing samples or wants the default technical voice.
- Copy [assets/article-brief.md](assets/article-brief.md) when the user wants a reusable intake brief. Do not block on its optional fields.

If the story is still scattered across repository history, ask `$project-story-miner` to produce an evidence brief when that skill is available. Otherwise reconstruct the same claim-and-source ledger before drafting.

## Choose The Mode

Infer the mode from the request and existing material.

- **Draft:** Turn a brief, evidence packet, notes, benchmark output, or design record into a complete first draft.
- **Rewrite:** Improve an existing draft while preserving supported facts, terminology, code, links, citations, and limitations.
- **Review:** Diagnose the highest-impact structural, evidence, audience, and voice problems without rewriting unless requested.
- **Series edit:** Give each post one distinct job, reduce repeated evidence, and recommend order and cross-links.

## Establish The Editorial Contract

Identify the audience, primary document type, central claim, desired reader outcome, evidence boundary, author perspective, tone, length, and output location. Infer conservative defaults from the material instead of asking the user to restate known information.

Write one private purpose sentence:

> This piece helps [audience] understand [claim] so they can [useful outcome].

If it promises two unrelated outcomes, narrow the piece or propose a series.

## Lock The Evidence

Treat supplied material as the factual boundary unless the user requests research.

- Preserve exact numbers, units, dates, names, terms of art, code, links, and citations.
- Do not silently reconcile conflicting sources, round values, or strengthen causal language.
- Distinguish observation, source-backed fact, inference, and author opinion.
- State what a benchmark mode proves and what it does not.
- Do not convert diagnostic evidence into a production or end-to-end claim.
- Use `I` or `we` only when the sources establish that perspective.
- Add personal reactions, motives, dialogue, and anecdotes only when supplied. Otherwise write neutrally or mark `[NEEDS AUTHOR DETAIL]`.
- When outside research is requested, cite it and keep sourced fact separate from inference and author judgment.

## Find The Spine Before Drafting

For a project story or retrospective, locate:

1. starting target or assumption
2. friction, failure, or surprising result
3. evidence that narrowed the problem
4. plausible suspect or approach that was cleared or abandoned
5. decision, pivot, or tradeoff
6. supported result
7. remaining boundary
8. transferable takeaway

Open with the strongest concrete moment when one exists. Do not spend several paragraphs announcing that the topic matters.

For non-narrative pieces, follow the matching structure in `references/document-types.md` and keep one primary reader job.

## Draft For Technical Readers

- Prefer concrete nouns and active verbs.
- Put measurements next to the claim they support.
- Explain why a mechanism or decision matters instead of dumping facts.
- Make judgment visible where the source supports it.
- Define uncommon terms near first use without over-explaining common engineering concepts.
- Use lists for comparison, reference, or sequence rather than as the default rhythm.
- Use tables when readers must compare results or options.
- Use a compact diagram only when it materially clarifies architecture or flow.
- State limitations once, clearly, near the affected claim.
- Keep humor tied to the engineering reality; never manufacture jokes or drama.

## Run The Editorial Passes

1. Fix structure before polishing sentences.
2. Compare the draft to the fact ledger.
3. Calibrate voice against supplied samples or the requested register.
4. Vary paragraph and sentence rhythm without manufacturing fragments.
5. Remove generic openings, inflated significance, vague praise, repetitive contrast formulas, ritual summaries, and unsupported certainty.
6. Check that headings advance the argument rather than merely label subjects.
7. Make the ending add a final implication, decision rule, remaining question, or next experiment instead of restating the introduction.

Use `$humanizer` only as an optional final audit after the evidence and structure are sound. Its job is to catch repetitive surface patterns, not to decide the story or facts.

## Deliver The Right Artifact

For a new draft, provide title options when useful, the complete draft, and only the assumptions or factual gaps that need attention.

For a rewrite, provide the revised text or file plus a concise summary of major editorial changes and any unsupported material removed or marked.

For a review, provide what works, the highest-impact problems with examples, a recommended structure, and the next editing action.

For a series, also define each post's role, repeated material to consolidate, publishing order, and cross-linking plan.

When the user requests a file, preserve existing frontmatter, code fences, link targets, and repository conventions. Do not overwrite the only copy of a draft unless the user explicitly asks for in-place editing.
