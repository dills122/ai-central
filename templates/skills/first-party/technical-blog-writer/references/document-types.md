# Technical Document Types

Choose one primary form. A piece may borrow elements from another form, but it should have one main reader job.

## Engineering story or retrospective

Answer: What happened, why did the first answer fail, and what changed?

Use a concrete turning point, original assumption, complicating evidence, wrong suspect or failed approach, pivot, result, proof boundary, and transferable lesson.

## Technical explanation

Answer: How should the reader understand this system or concept?

Move from a concrete problem or misconception to a mental model, mechanism walkthrough, tradeoffs, edge cases, and the limit of the model. Use at most one controlling analogy and keep the real mechanism visible.

## Architecture or design note

Answer: What decision was made under which constraints, and why?

Cover context, hard constraints, old shape and failure evidence, considered alternatives, chosen design, data or control flow, consequences, validation, and unresolved risks. Prefer explicit responsibility boundaries and before/after diagrams.

## Benchmark analysis

Answer: What does this experiment actually prove?

State the hypothesis, benchmark mode, environment, duration, workload, accepted or completed rate, counters, latency, failure classes, lag, interpretation, threats to validity, and next experiment. Do not headline attempted rate when accepted or completed rate is the claim.

## Tutorial

Answer: Can the reader learn this while building something?

State prerequisites, create visible progress, introduce concepts when they become useful, verify each meaningful stage, and finish with a working result plus sensible next experiments.

## How-to guide

Answer: How does the reader complete this known task?

Start with the goal and prerequisites. Give direct steps, expected results, verification, and troubleshooting. Keep conceptual detours short.

## Reference

Answer: What is the exact behavior, option, schema, or contract?

Optimize for lookup with consistent headings, tables, definitions, signatures, defaults, constraints, examples, and edge cases. Avoid narrative padding.

## Series

Assign one role to each post: story, method, architecture, evidence, or tutorial. Repeat only enough context for independent reading, then link to the specialist post.
