---
name: humanizer
description: Audit and revise existing prose so it reads naturally, specifically, and consistently with the author's voice while preserving every supported fact, number, citation, code block, link target, and intentional technical term. Use for a final editorial pass on blog posts, documentation, essays, announcements, or other prose that feels generic, repetitive, inflated, or recognizably machine-shaped; do not use as the primary research or drafting workflow or to evade disclosure requirements.
---

# Humanizer

Improve prose by removing clustered, predictable writing habits without flattening legitimate style. Preserve information and authorial intent rather than optimizing for an AI detector.

Adapted and condensed from `blader/humanizer` at commit `523374dee72d67c7b2b5f858ea0094ffda49c3ac`, MIT license. This adaptation replaces hard punctuation bans with voice-relative checks, removes detector-oriented framing, and moves the pattern catalog into a reference.

## Establish The Invariants

Before editing, inventory:

- factual claims, names, numbers, dates, units, quotations, and citations
- code blocks, commands, frontmatter, data, Markdown structure, and link targets
- terms of art and deliberate wording
- the requested audience, register, and author perspective
- any supplied voice sample

Never add a fact, anecdote, quote, source, reaction, date, name, or specific detail that is not present in the source or explicitly supplied by the user. If specificity would improve a sentence but the source lacks it, keep the plain version or mark the gap.

## Calibrate To The Author

When a sample exists, note sentence-length distribution, vocabulary, contractions, paragraph openings, punctuation, recurring phrases, formality, point of view, humor, uncertainty, and asides. Match those tendencies instead of imposing a generic house style.

Without a sample, preserve the document's appropriate register. Neutral technical or reference prose does not need manufactured personality. Blogs and essays may retain judgment, mixed feelings, humor, and irregular rhythm when the source supports them.

## Audit Clusters, Not Tokens

Read [references/pattern-catalog.md](references/pattern-catalog.md) when a full pass is needed. Treat it as a diagnostic catalog, not a banned-word list.

Flag a pattern when it is repeated, obscures meaning, inflates a claim, breaks the author's voice, or combines with other formulaic habits. Do not rewrite a clean sentence merely because it contains an em dash, a transition word, passive voice, formal vocabulary, a three-item list, or polished grammar.

Preserve signs of an actual author:

- concrete and unusual details supported by the source
- mixed feelings and unresolved tension
- defensible first-person judgment
- genuine asides and self-correction
- deliberate repetition
- varied cadence and domain-specific vocabulary

## Rewrite In Two Passes

### Pass 1: Structure And Substance

- Remove throat-clearing, generic significance, promotional claims, vague attribution, unsupported conclusions, and sections that exist only because a template expects them.
- Compress dull repetition and allow important material more room.
- Reorder or combine paragraphs when the information survives more clearly in a different shape.
- State the concrete mechanism or claim directly.

### Pass 2: Voice And Rhythm

- Vary sentence and paragraph shape where the source is monotonous.
- Replace inflated or abstract wording with precise language.
- Reduce repeated contrast formulas, rhetorical hooks, signposts, punchlines, list shapes, and heading patterns.
- Keep punctuation and quirks that match the author; reduce them only when they have become a visible tic.
- Read the result aloud and remove phrases the intended author would not plausibly say.

## Verify Preservation

Compare the revision to the invariant inventory.

- Every retained factual value and citation must still be exact.
- No claim may become stronger or more causal.
- Quotations and code must remain unchanged unless the user explicitly requested edits to them.
- Frontmatter keys, link targets, and structured data must remain intact.
- Omissions must remove redundancy or unsupported material, not silently change the meaning.
- The revision should still sound appropriate for its genre and audience.

## Deliver By Context

- For pasted prose, return the clean revision and a short note about the most important changes only when useful.
- For a requested review, identify the strongest pattern clusters with examples before proposing changes.
- For a file, create a revised copy by default. Edit in place only when the user explicitly requests it.
- When embedded in a larger writing task, return only the revised prose unless the caller asks for an audit.

If the piece lacks a defensible story, evidence, or structure, say so and hand it back to `$technical-blog-writer`; surface polish cannot repair a missing argument.
