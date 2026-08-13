---
name: project-story-miner
description: Reconstruct a software project's journey from repository history, source code, issues, pull requests, ADRs, benchmarks, incident notes, and author recollections, then produce a story-ready evidence brief. Use before writing an engineering retrospective, architecture journey, performance story, migration post, launch narrative, or multi-post series when the important turning points and proof boundaries are scattered across project artifacts.
---

# Project Story Miner

Turn project history into an evidence-backed narrative brief without inventing a cleaner story than the artifacts support.

## Set The Boundary

Before searching, identify:

- the repository or project in scope
- the rough period, feature, incident, migration, or question
- whether private/internal details may appear in a public draft
- whether external systems such as GitHub issues or pull requests are in scope

Use read-only inspection by default. Do not publish, message, edit source artifacts, or open external tickets unless the user separately asks.

## Build A Source Map

Search the smallest relevant surface first, then widen only when the story remains unclear.

1. Read repository guidance, current documentation, changelogs, ADRs, plans, and benchmark notes.
2. Inspect the relevant code, tests, configuration, and commit history.
3. Trace high-value commits with `git show`; do not infer a journey from commit subjects alone.
4. Read linked issues, pull requests, review threads, or incident records when they are available and in scope.
5. Ask for author recollection only after the artifacts reveal which human details are genuinely missing.

Useful local commands include:

```sh
git log --all --date=short --format='%h %ad %s' -- path/to/scope
git log --all --stat -- path/to/scope
git show --stat --summary COMMIT
git show COMMIT -- path/to/scope
rg -n "benchmark|incident|decision|tradeoff|migration|regression|rollback" docs tests .github
```

Adapt commands to the repository. Preserve the user's dirty worktree and do not assume uncommitted changes are part of the historical story.

## Keep An Evidence Ledger

For every candidate claim, record:

- the observation or decision
- the source path, commit, issue, pull request, log, or supplied recollection
- whether it is direct evidence, inference, or author perspective
- the time or version boundary
- what it supports
- what it does not establish
- its likely publication sensitivity

Prefer primary project artifacts over summaries. Treat commit messages, issue titles, and comments as leads until code, tests, measurements, or fuller context corroborate them.

Never turn attempted throughput into completed throughput, a diagnostic run into an end-to-end claim, correlation into causation, or a current implementation into proof of the original motivation.

## Recover The Journey

Build a chronology around changes in understanding:

1. starting target or assumption
2. friction, failure, or surprising result
3. evidence that narrowed the problem
4. plausible suspect or approach that was cleared or abandoned
5. decision, pivot, or tradeoff
6. implementation and validation
7. supported result
8. remaining uncertainty or next gate

Keep messy or parallel branches when they matter. A useful story has selection and shape, but it must not imply a linear plan that never existed.

## Protect Private Context

Before recommending material for publication, flag:

- secrets, tokens, credentials, internal URLs, customer data, and personal information
- confidential product, commercial, compliance, or incident details
- security weaknesses that remain exploitable
- third-party claims or quotations that need permission or sourcing
- names of people who have not agreed to be part of the story

Redact sensitive values in the brief. Do not reproduce secret material merely to explain that it exists.

## Find Story Angles

Recommend two to four angles grounded in the evidence. Good angles usually center on a changed belief, a constraint that reshaped the design, a misleading metric, a failed approach, or a reusable engineering method.

For each angle, state:

- the reader promise
- the central claim
- the strongest evidence
- the likely opening moment
- the proof boundary
- the missing author detail, if any
- whether it should be one post or part of a series

Reject angles that require invented conflict, unsupported causality, or a result the artifacts do not prove.

## Produce The Brief

Read [references/evidence-brief.md](references/evidence-brief.md) and use its structure. Return the brief in the conversation unless the user asks for a file. If a file is requested, write a new research artifact rather than modifying historical source files.

Hand the selected angle and evidence brief to `$technical-blog-writer` when available. The brief is research material, not a publishable draft.

## Verification

Before finishing:

- trace every proposed factual claim to a source or label it as inference
- compare important numbers, dates, and states against the original artifact
- distinguish what happened then from what exists now
- identify contradictions instead of silently reconciling them
- include unresolved questions and negative evidence
- run the privacy and publication-sensitivity pass
- ask only the author questions that would materially improve the story
