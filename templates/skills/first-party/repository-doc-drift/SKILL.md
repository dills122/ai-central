---
name: repository-doc-drift
description: Audit canonical repository documentation against current code, configuration, tests, generated contracts, and recent Git history, then make minimal evidence-backed corrections. Use after feature merges or releases, when plans and status may be stale, when README or architecture claims are questioned, or when multiple docs disagree about the current source of truth.
---

# Repository Doc Drift

Detect false or stale claims without turning a drift audit into a documentation rewrite.

## Establish Canonical Scope

Read applicable `AGENTS.md` and documentation indexes. Classify documents as canonical, generated view, historical/archive, active plan, decision record, or handoff. Respect explicit precedence and supersession markers.

## Build The Evidence Window

Inspect only the history needed for the audit:

- recent merges, releases, or a user-specified base;
- changed public behavior, contracts, commands, dependencies, and configuration;
- current tests and executable verification;
- generators and their canonical inputs;
- accepted ADRs and active plans.

Do not treat comments, generated projections, or old handoffs as more authoritative than their named source.

## Classify Findings

For each suspected mismatch, report:

- document and exact claim;
- current evidence;
- classification: stale, contradictory, ambiguous, missing, or still accurate;
- impact and smallest safe correction;
- canonical file that should own the truth.

Executed failures and current contracts outrank prose that says work passed. A completed child task does not make an unfinished parent plan complete.

## Correct Minimally

Preserve the document's structure, voice, and useful history. Update exact claims, links, commands, statuses, dates, or supersession notes. Avoid broad reformatting, speculative roadmap changes, and copying canonical facts into multiple views.

When a generated view drifted, fix its canonical input or generator and regenerate it; do not hand-edit the projection. When the code conflicts with an accepted decision, report the conflict instead of silently changing the ADR.

## Verify

Run relevant doc, link, generation, build, or test checks. Re-read changed passages beside their evidence and report any uncertainty or intentionally deferred correction.
