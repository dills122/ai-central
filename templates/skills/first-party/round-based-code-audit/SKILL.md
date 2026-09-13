---
name: round-based-code-audit
description: Conduct a configurable repository or scoped-path code audit in focused rounds, maintain one evidence ledger, adversarially validate every candidate, and prepare or create prioritized GitHub issues for confirmed findings. Use for broad senior-engineer audits covering correctness, security, architecture, maintainability, code smells, tests, operations, or documentation. Do not use for ordinary diff review, a single known bug, or a request to implement fixes.
---

# Round-Based Code Audit

Audit one stable target through distinct engineering lenses. Discovery is read-only. Do not fix code, edit project files, or publish issues unless the requester separately authorizes that action.

## Configure The Audit

Resolve the following from the request and repository. Use the defaults when the choice does not materially change scope; ask only when it does.

- **Target:** repository, commit/ref, and included paths. Default to the current checkout and exclude generated, vendored, dependency, fixture, and build-output paths unless they are relevant to a finding.
- **Lenses:** requested concern groups. Default to all lenses in [references/audit-lenses.md](references/audit-lenses.md).
- **Depth:** `survey`, `standard`, or `deep`. Default to `standard`. Depth changes evidence breadth, not the validation threshold.
- **Finding floor:** default to every validated, issue-worthy P0-P3 finding; exclude subjective nits and unsupported suspicions.
- **Evidence budget:** applicable tests, static tools, history, and runtime checks that are safe and proportionate. Never claim an unexecuted check passed.
- **Output:** report only, issue drafts, or approved GitHub publication. Default to drafts when publication intent is unclear.
- **GitHub destination:** repository plus allowed existing labels. Do not infer authority to create labels, assign people, add milestones/projects, or disclose sensitive vulnerabilities.

State the resolved configuration and exclusions before discovery. Freeze the target ref or working-tree boundary so evidence does not silently drift during the audit.

## Design The Rounds

Read [references/audit-lenses.md](references/audit-lenses.md), group the selected lenses into coherent rounds, and define a short charter for each round:

```text
Round <N>: <name>
Questions: <specific failure or quality properties>
Scope emphasis: <paths, boundaries, or flows>
Evidence: <code, tests, configs, history, tools>
Out of scope: <explicit exclusions>
```

Each round must inspect the complete frozen target through its own lens. Avoid dividing rounds only by arbitrary file batches unless the requester chose path-based partitioning. Keep an explicit coverage map so important paths and selected lenses cannot disappear between rounds.

## Establish Repository Ground Truth

Before judging code:

1. Read applicable `AGENTS.md`, security policy, contribution guidance, architecture records, and language or framework conventions.
2. Map entry points, trust boundaries, persistence, external interfaces, background work, tests, build and deployment paths, and ownership boundaries relevant to the selected lenses.
3. Identify generated and vendored code, active migrations, compatibility commitments, and repository-specific verification commands.
4. Record environmental limits and evidence that cannot be obtained.

Repository rules and observable behavior outrank generic taste. Treat comments and docs as claims to verify, not proof.

## Run Every Discovery Round

For each round:

1. Announce the round charter and the evidence you will inspect.
2. Trace behavior across the smallest sufficient surrounding context, not isolated lines.
3. Add every plausible issue to the shared candidate ledger described in [references/finding-and-issue-workflow.md](references/finding-and-issue-workflow.md).
4. Look for counter-evidence immediately: callers, guards, invariants, tests, configuration, generated contracts, and supported platform behavior.
5. Mark weak candidates as rejected or uncertain rather than quietly forgetting them.
6. Summarize coverage, candidates, rejected hypotheses, and blind spots before moving to the next round.

Do not publish issues during discovery. Do not let an early finding narrow later rounds to the same files or pattern. Use static analyzers and linters as leads; independently establish whether their output is reachable and consequential.

## Reconcile And Validate All Candidates

After all discovery rounds, stop discovery and perform one cross-round validation pass using [references/finding-and-issue-workflow.md](references/finding-and-issue-workflow.md).

- Re-read every candidate against the frozen target.
- Reproduce or prove the failing scenario with the strongest proportionate evidence available.
- Challenge the preconditions, reachability, supported configuration, expected behavior, impact, and proposed priority.
- Merge candidates with the same root cause and separate findings that require independently actionable fixes.
- Search for related tests, prior fixes, commits, docs, and existing GitHub issues that contradict or supersede the claim.
- Reject false positives, downgrade overstated impact, and retain uncertainty explicitly.

Only `validated` candidates may enter the validated-findings section or issue queue. A useful audit may produce no validated findings. Never file weak items to fill a quota.

## Prepare The Publication Gate

For every validated finding, prepare an exact issue preview containing title, body, priority, type, labels, and any sensitive-disclosure handling. Inspect the destination repository's existing labels and open issues before proposing labels or publication.

Use one issue per independently actionable root cause. Do not create duplicates; link the existing issue in the audit result. If an existing issue is incomplete, propose a comment or body update separately rather than silently mutating it.

Do not place exploitable details, credentials, personal data, or an unpatched sensitive vulnerability in a public issue by default. Hold it from public publication and request a private reporting path or explicit disclosure decision.

Show the complete publication preview and request explicit approval immediately before the GitHub write. Initial authorization to conduct the audit is not approval of an issue set that did not yet exist. Include any proposed label creation or other metadata mutation in the same gate.

## Publish Safely

After approval of the exact preview:

1. Recheck the target finding and duplicate search if repository state changed.
2. Create issues sequentially so failures are attributable and duplicate checks remain current.
3. Apply only approved, available labels and metadata.
4. Read each created issue back and record its URL and final metadata.
5. Before retrying an uncertain failure, search for the exact issue to avoid duplicate creation.
6. Stop on authentication, permission, disclosure, or systematic validation failures; preserve the remaining drafts.

Do not close, edit, assign, or comment on existing issues unless that mutation was explicitly included in the approved preview.

## Return The Audit Result

Report:

```markdown
## Audit Configuration And Frozen Target
## Round Coverage And Evidence
## Validated Findings
## Rejected Or Merged Candidates
## Verification Performed
## Existing-Issue Matches
## Created Issues Or Publication-Ready Drafts
## Blind Spots And Residual Risk
```

Order validated findings by P0-P3 priority. Distinguish observed evidence from inference, include exact commands and outcomes, and reconcile every validated finding with a created issue, an existing issue, a held-sensitive item, or an explicit decision not to publish.
