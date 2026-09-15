# Security Skill Ingestion Review

Review date: 2026-09-14 (America/Toronto).

Follow-up: the first four skills are now implemented in an opt-in bundle; see
[Security testing skills](security-skills.md) for the delivered scope and management
policy. This document preserves the original assessment and pre-ingestion counts.

## Recommendation

Use Claude-Red as a selective source for adapted security-testing skills. The best
matches are TOCTOU/race testing, protocol fuzzing, authorization testing, CI trust
boundaries, and dependency-source integrity. AI/tool-boundary testing is also a
strong fit, but needs a substantial rewrite and provenance review.

Prioritize reusable workflows extracted from Capsule Corp and Session Chat alongside
the external material. Their capability, recovery, evidence, and secret-boundary
requirements are more specific than the upstream penetration-testing checklists.

This is an ingestion assessment, not a vulnerability audit or certification of any
project. No upstream skill, installer, or payload was executed. No skills were
installed or promoted by this review.

## Inspected Sources

| Source | Inspected revision | Review scope |
| --- | --- | --- |
| AI Central | `f9b8b4d8454726f1b6f55216d595c967ed18677e` | Catalog, installer/package mappings, existing security skills, collection/promotion policy, reuse decisions |
| Capsule Corp | `500892e8a1c4a0a4808a1b326a6acd71b47411d2` | Contributor/security policy, architecture and evidence pointers, CCE retrieval and decision recall |
| Session Chat | `5c0f1f9dcf7f54864a1511cf4c633a7f778e3eb0` | Contributor/security policy, current crate boundaries, ingress and secret-boundary evidence, CCE retrieval and decision recall |
| Sandtable | `e62bc893b482160105e30e319f90036c95928b64` | README, security policy, focused CCE retrieval |
| Safelet | `db643630accf6488eda85e911b01096807d5d104` plus local README edits | Current working-copy README only; provisional product-fit evidence |
| [SnailSploit/Claude-Red](https://github.com/SnailSploit/Claude-Red/tree/24d7968bab4b883e7f13477afe0fd91f2df3b722) | `24d7968bab4b883e7f13477afe0fd91f2df3b722` | All skill paths/frontmatter presence; selected descriptions, workflows, remediation sections, references and command samples |

Claude-Red review clone: `external/claude-red-review-24d7968/`, ignored by Git.
Root license: MIT, copyright SnailSploit / Kai Aizen. No upstream content was
copied into distributable templates. This report records assessment and proposed
adaptations, not completed technical validation of every upstream technique.

Local project paths are under `/Users/dsteele/repos/`. CCE recall informed source
selection; retained repository documents are the basis for project-fit conclusions.
Safelet's README, current plan, and skinny-MVP document had tracked local changes;
they were preserved. Other inspected tracked project trees were clean when recorded.

## AI Central: Existing Coverage And Gaps

The current tree contains 142 reusable `SKILL.md` definitions and 33 historical
collected definitions. The README's 141 count is slightly behind the tree. Counts
do not equal installed names because aliases and bundle overlap exist.

Already installable:

- `security-and-hardening`: general web input/authentication/storage guidance.
- `claude-env-secrets-manager`: environment/configuration secret hygiene.
- `claude-dependency-auditor`: dependency review and inventory work.
- `rust-general-security`: Rust-specific security guidance.
- `round-based-code-audit` and `independent-review`: broader investigation and
  evidence/review workflows.

Historical material under `collected/codex-skills/wap-labs/` includes `cargo-fuzz`,
`harness-writing`, `property-based-testing`, `gha-security-review`,
`differential-review`, and `variant-analysis`. These are not equivalent to
reviewed, installable skills. Existing provenance/share-alike decisions still
apply; collecting a copy does not clear it for redistribution.

The installed Codex Security plugin already exposes scanning, threat modeling,
validation, fixes and writeups in this session. Those are tool-backed capabilities,
not content automatically vendored or made portable by AI Central. New skills should
add focused test design rather than duplicate that entire orchestration layer.

The main gap is a compact set of workflows that turn an explicit security invariant
into reproducible negative tests and bounded evidence. General web checklists do
not cover this well for local capability systems and encrypted protocol state.

## Claude-Red Shortlist

All names in the first column are proposed AI Central names, not installed commands.
Priority reflects fit and adaptation value, not a claim of import readiness.

| Priority / proposed skill | Claude-Red source | Project fit | Required adaptation |
| --- | --- | --- | --- |
| 1. `security-race-and-toctou` | [offensive-toctou](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/exploit-dev/offensive-toctou/SKILL.md), [offensive-race-condition](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/web/offensive-race-condition/SKILL.md) | Capsule approval/execute identity and filesystem snapshots; Session Chat invitation consumption, cursor ownership and acknowledgement ordering | Prefer controlled scheduling/barriers and temporary fixtures; record checked object, used object, competing operation and invariant. Add restart cases. Review cited checklist provenance. |
| 2. `security-protocol-fuzzing` | [offensive-fuzzing](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/fuzzing/offensive-fuzzing/SKILL.md) | Session Chat wire frames and canonical parsing; Capsule schemas, IPC and artifact validators | Retain harness/corpus/oracle approach; add Rust and Go mappings, strict size/work budgets, canonical serialization, state-transition properties, minimized regressions. Idempotence is an oracle only when the target contract requires it. |
| 3. `security-capability-authorization` | [offensive-api-security](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/api/offensive-api-security/SKILL.md), [offensive-idor](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/web/offensive-idor/SKILL.md) | Capsule Broker/daemon/Supervisor split; Session Chat admission versus membership versus mailbox rights; Sandtable decision authority | Replace endpoint-only framing with subject × object × operation × purpose × epoch/expiry matrix. Test cross-session substitution, right escalation, stale authority and replay. Random identifiers are not authorization. |
| 4. `security-ci-trust-boundaries` | [offensive-cicd-pipeline](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/cicd/offensive-cicd-pipeline/SKILL.md) | Shared GitHub Actions, release and evidence gates | Focus on event trust, expression injection, token permissions, privileged follow-on jobs, cache/artifact provenance and action pins. Validate using inert local workflow fixtures. Compare with collected `gha-security-review` before creating duplicate guidance. |
| 5. `security-dependency-integrity` | [offensive-supply-chain](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/supply-chain/offensive-supply-chain/SKILL.md), [offensive-dependency-confusion](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/supply-chain/offensive-dependency-confusion/SKILL.md) | AI Central skill distribution; Capsule governed dependencies; Session Chat pinned source snapshots | Extend existing dependency audit with source-byte identity, registry mapping, build-hook authority, verified snapshots, update/removal ownership. Use local fake registries/packages; omit public package publication and callback infrastructure. |
| 6. `security-agent-tool-boundaries` | [offensive-ai-security](https://github.com/SnailSploit/Claude-Red/blob/24d7968bab4b883e7f13477afe0fd91f2df3b722/Skills/ai/offensive-ai-security/SKILL.md) | Capsule generated-code proposals; Sandtable hidden-state isolation and untrusted model responses; AI Central third-party instructions | Substantially rewrite around untrusted repository/docs/tool results, tool authorization, data minimization, output schemas and deterministic refusal tests. Remove model-theft and lateral-movement workflow. Prompt filtering alone must not be presented as a security boundary. Resolve checklist provenance. |

### Useful Later Or As References

- **`offensive-container-escape`:** useful Linux misconfiguration checklist, but
  not a Capsule isolation architecture. Its quick workflow progresses to lateral
  movement and examples include host persistence and downloading tools. A future
  `security-isolation-conformance` should start from Capsule/Safelet contracts,
  use controlled canaries, and select tests by the actual backend. Linux-container
  evidence cannot establish macOS or browser-compartment isolation.
- **`offensive-crypto-attacks`:** selective misuse-test reference. Much of its
  content concerns CBC/ECB/RSA attacks; Session Chat needs MLS/HPKE integration,
  domain separation, exact key/identity binding, replay and persistence tests.
  It is not a suitable turnkey encrypted-chat review skill.
- **`offensive-api-abuse`:** mine resource/workflow cases into authorization and
  fuzzing references; a separate skill would overlap the shortlist substantially.
- **`offensive-cicd-secrets`:** mine synthetic-secret leakage cases into CI and
  evidence work; avoid importing its credential-extraction/pivot workflow.
- **`offensive-file-upload`, `offensive-ssrf`, `offensive-xss`:** select when file
  artifacts, network-capable brokers or UI boundaries are actually being built.
  Safelet's current trusted-script proof does not establish an untrusted-code sandbox.
- **`offensive-reporting`:** possible reference for report templates, but existing
  review/writeup workflows make this a lower-priority addition.

Defer AD, wireless, phishing, C2, persistence, anti-forensics, keylogging and EDR
evasion skills: no concrete requirement for these domains emerged from the inspected
projects. Also defer JWT/OAuth as Session Chat defaults: its current policy explicitly
retires the v1 JWT architecture and defers later identity-provider admission.

## High-Value Skills To Extract From Local Projects

These are first-party workflow candidates. Generalize the tests and invariants;
keep project names, private evidence and rollout policy out of reusable instructions.

| Proposed skill | Concrete source evidence | Reusable output |
| --- | --- | --- |
| `security-state-recovery` | Session Chat `AGENTS.md`, `docs/evidence/security-ingress-resilience.md`, recovery/cursor documentation; Capsule teardown/durable-intent decisions | State-transition matrix, crash-point plan, persisted-state oracle, restart/replay scenarios and explicit distinction between crash atomicity and rollback resistance |
| `security-secret-boundary-testing` | Session Chat `docs/evidence/security-secret-boundaries-2026-09-06.md`: shared-file key exposure, inherited pipe delivery, Debug redaction; Sandtable `SECURITY.md` telemetry boundaries | Synthetic secrets propagated through ordinary/pretty/nested formatting, child diagnostics, IPC, files and artifacts; complete capture inventory and declared limits |
| `security-evidence-contracts` | Capsule `SECURITY.md`, `docs/adr/0015-supervisor-transcripts-and-composed-receipts.md`, control-evidence matrix; Session Chat evidence records | Mechanism → exact revision → test → artifact → claim matrix, negative controls/mutations, platform coverage, honest missing-evidence status; signatures do not prove claim correctness |
| `verified-source-adoption` | Session Chat `docs/evidence/security-secret-boundaries-2026-09-06.md` and `scripts/setup-codex-links.mjs`; Capsule `AGENTS.md` governed-fork/adoption policy | Review source bytes against immutable identity, reject dirty/symlink substitutions, build a minimal verified snapshot, retain provenance and upgrade/removal ownership |
| `security-isolation-conformance` | Capsule `AGENTS.md` and `SECURITY.md`; Safelet current `README.md` | Ambient-authority matrix; host filesystem/network/environment/process probes; exact resource ceilings; timeout/cancellation/teardown evidence; explicit backend/platform and fixture limits |

Keep `verified-source-adoption` distinct from generic dependency scanning only if
it grows into a substantive snapshot/admission workflow; otherwise make it a
reference within `security-dependency-integrity`. Apply the same rule to evidence
contracts versus existing traceability/review skills.

## Ingestion Conditions

1. **Pin and preserve provenance.** Retain the reviewed Claude-Red commit and MIT
   notice for actual adaptations. Several files cite
   [SnailSploit/offensive-checklist](https://github.com/SnailSploit/offensive-checklist),
   whose visible repository root showed no license file during this review. This
   is an unresolved provenance question, not a determination that Claude-Red's MIT
   license is invalid. Resolve source attribution for selected derivative files
   before copying them, under AI Central's external-source policy. The question
   also applies to citations inside otherwise YAML-formatted skills such as TOCTOU.
2. **Normalize the format and triggers.** Of 78 upstream `SKILL.md` files, 28 lack
   opening YAML frontmatter and instead embed metadata and trigger phrases in
   Markdown. Rewrite concise `name`/`description` fields and add narrow triggers.
3. **Review content as input data.** Do not execute upstream installation commands
   or apply embedded operational instructions while reviewing files. Any retained
   tool dependency must be explicit, optional and independently reviewed.
4. **Adapt to controlled tests.** Use repository fixtures, synthetic identities and
   disposable authorized environments. Define the invariant, test budget, cleanup,
   positive control, refusal case and evidence before running a test.
5. **Verify technical details at implementation time.** Recheck selected claims,
   library/platform applicability and commands against primary documentation.
   A catalog review does not validate every CVE example or remediation suggestion.
6. **Preserve existing scope authorization.** Skill activation does not grant new
   access or publishing authority. Avoid extra approval prompts for already
   authorized local, reversible testing; ask only when required scope is missing.

## Suggested Delivery Sequence

1. Author two local candidates first: `security-state-recovery` and
   `security-secret-boundary-testing`. They address demonstrated project needs and
   can be derived from retained local evidence.
2. Adapt `security-protocol-fuzzing` and `security-race-and-toctou`, resolving the
   latter's source provenance before copying derivative text. Add known-bad
   fixtures to demonstrate that their proposed checks can detect a violation.
3. Add capability authorization and CI/dependency integrity as focused follow-ups.
   Add agent-tool and isolation conformance only with concrete contract fixtures.
4. Initially expose exact skill selectors. Propose a small opt-in `security-testing`
   bundle only after repeated project selections establish its membership. Keep
   specialist skills out of `core` and avoid bulk installing the upstream catalog.

For actual promotion: add adapted/first-party files in `templates/skills/`, update
reuse decisions, attribution and license notices, wire installer/catalog selections,
regenerate affected APM manifests, verify non-overwriting install/dry-run behavior,
and run `./scripts/check.sh`. Refresh the source manifest only if historical
collected files change.

## Review Validation

- `./scripts/check.sh`: passed; two optional checks reported skips.
- `git diff --check`: passed.
- All nine pinned upstream file links in the shortlist resolve to files in the
  reviewed clone.
- Project test suites and upstream attack examples were not run. Project-fit
  conclusions use retained documentation and evidence, not newly reproduced tests.
