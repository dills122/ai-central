---
name: research-to-decision
description: Run bounded technical or product research and turn it into a decision-ready repository artifact. Use when a spec, architecture choice, dependency, standard, feasibility gate, or implementation plan depends on external evidence or a controlled experiment, especially when research is delegated to another agent or chat.
---

# Research To Decision

Answer one decision question with retained evidence. Keep research, inference, and the final decision distinct.

## Frame The Packet

State before searching or experimenting:

- question and decision owner;
- why the answer matters now;
- authorized scope and prohibited actions;
- preferred source hierarchy;
- comparison or success criteria;
- stop condition and expected repository artifact.

Do not broaden a research task into implementation authority.

## Gather Evidence

Prefer primary and current sources. For repository experiments, record the exact commit, environment, inputs, commands, and artifact paths. Separate each conclusion into:

- **Documented fact:** directly supported by a cited source;
- **Observation:** reproduced in the named environment;
- **Inference:** reasoned from facts or observations;
- **Unknown:** material uncertainty that remains.

Avoid long source dumps. Retain the smallest excerpt or result needed to make the conclusion auditable.

## Compare Against The Decision Criteria

Evaluate credible options consistently. Record constraints, trade-offs, failure modes, reversibility, and what evidence would change the recommendation. A failed candidate is not proof that every alternative works.

## Retain The Result

Write the result into the repository's existing research, feasibility, or decision location. Include:

- scoped status;
- executive conclusion;
- method and source index;
- evidence with fact/observation/inference labels;
- option comparison;
- confidence, limitations, and unresolved questions;
- recommendation and required decision owner;
- implementation consequences and next gate.

If the conclusion changes architecture, security posture, public behavior, or an expensive-to-reverse choice, create or update the governing ADR or spec after approval. Chat history alone is not retained evidence.
