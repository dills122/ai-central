# Finding Ledger, Validation, And GitHub Issues

## Candidate Ledger

Maintain one ledger across all rounds outside the audited repository unless the requester asks for a durable in-repo artifact. Give each candidate a stable ID.

| Field | Required content |
| --- | --- |
| ID | Stable audit-local identifier |
| Round and category | Discovery origin and normalized type |
| Status | `suspected`, `uncertain`, `validated`, `rejected`, `merged`, or `held-sensitive` |
| Location | Current path plus line, symbol, endpoint, config key, or flow |
| Claim | One falsifiable statement about the problem |
| Scenario | Preconditions and steps that expose it |
| Evidence | Code path, contract, test, command output, or history |
| Counter-evidence | Guards, tests, docs, callers, or assumptions checked |
| Impact | Who or what is affected and how |
| Priority | P0, P1, P2, or P3 with rationale |
| Confidence | High, medium, or low before final disposition |
| Root cause | Underlying independently actionable cause |
| Duplicate status | New, matched existing issue, or merged candidate |
| Publication | Draft, approved, created URL, existing URL, held, or omitted |

Never discard a candidate without a disposition and short reason. Do not put secrets, working exploit payloads, personal data, or unnecessary sensitive detail in the ledger.

## Priority Scale

- **P0 — Critical:** active or readily exploitable compromise, irreversible data loss, safety impact, or broadly catastrophic outage requiring immediate coordination.
- **P1 — High:** serious vulnerability, core correctness failure, major data-integrity risk, unsafe migration, or likely high-impact regression.
- **P2 — Medium:** reproducible bounded bug, meaningful reliability or maintainability hazard, important missing protection, or operational risk that should be scheduled.
- **P3 — Low:** concrete, bounded improvement with demonstrated maintenance or quality value. Exclude cosmetic nits and personal preferences.

Priority reflects impact and urgency, not how difficult the fix is. Explain uncertainty rather than inflating priority.

## Final Validation Checklist

A candidate becomes `validated` only when the available evidence supports all applicable checks:

1. The cited code and behavior still exist in the frozen target.
2. The path is reachable in a supported or realistically deployed configuration.
3. The scenario's preconditions are concrete and not contradicted by callers, guards, framework behavior, or repository policy.
4. Expected behavior is grounded in a contract, invariant, requirement, established convention, or clear user/operational need.
5. The consequence is observable or logically demonstrated; speculative impact is labeled as such.
6. A focused test, safe reproduction, static trace, or equivalent evidence confirms the claim when feasible.
7. Existing tests were checked for genuine coverage rather than name similarity.
8. The finding is not generated/vendor behavior owned elsewhere, already fixed on the target, or an accepted documented tradeoff.
9. Priority and scope match the evidence.
10. The root cause is distinct from other validated findings.
11. The proposed correction is feasible enough to make the issue actionable without prescribing an unverified redesign.
12. GitHub duplicate search found no issue covering the same root cause and outcome.

If a check cannot be established, keep the candidate uncertain or reject it. Medium confidence is acceptable only when the remaining uncertainty is explicitly material and the issue is still actionable; default publication requires high confidence.

## Duplicate Reconciliation

Search open and recently closed issues using more than the proposed title:

- path and symbol names;
- error text, endpoint, component, or configuration key;
- failing scenario and root-cause terms;
- security classification or affected behavior.

Treat an issue as a duplicate when resolving it would resolve the candidate's root cause and affected outcome. Record the existing URL. Do not create a competing issue merely because the proposed priority differs.

## Label Mapping

Inspect the repository's actual labels first. Prefer its established taxonomy. When equivalent labels exist, map each issue to:

- one priority label, such as `priority:P1` or the repository equivalent;
- one primary type, such as `bug`, `security`, `maintainability`, `performance`, `testing`, or `documentation`;
- optionally one component/area label supported by clear ownership.

Avoid label piles. Missing labels are a separate repository mutation: propose exact names, descriptions, and colors in the publication preview or use an approved existing fallback.

## Exact Issue Preview

Preview every issue exactly as it will be created:

```markdown
Title: [<P0-P3>] <specific observable problem>
Labels: <existing or explicitly proposed labels>

## Summary
<What is wrong, in concrete terms.>

## Evidence
- `<path:line or symbol>` — <relevant behavior>
- <test, command, contract, trace, or history evidence>

## Failing Scenario
1. <precondition>
2. <trigger>
3. <observed or logically demonstrated result>

## Impact
<Affected users/systems, severity rationale, and scope.>

## Recommended Direction
<Smallest credible correction or invariant to restore; avoid an unproven implementation mandate.>

## Acceptance Criteria
- [ ] <observable corrected behavior>
- [ ] <regression or verification evidence>
- [ ] <documentation, migration, or observability update when applicable>

## Audit Metadata
- Priority: <P0-P3>
- Category: <type>
- Confidence: <high/medium>
- Target: <commit/ref or working-tree boundary>
- Candidate ID: <ID>
```

Omit sections that genuinely do not apply, but never omit evidence, scenario, impact, acceptance criteria, or target. Use private/security-advisory wording rather than this public template for sensitive vulnerabilities.

## Publication Reconciliation

At completion, every validated candidate must map to exactly one disposition:

- created issue URL;
- existing issue URL;
- held for private security reporting;
- requester-declined publication;
- publication failure with a retained exact draft.

Read back created issues to verify title, body, labels, and URL. Report partial completion precisely; never imply that drafts or failed writes were published.
