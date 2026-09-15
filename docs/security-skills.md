# Security Testing Skills

## Delivered Bundle

`security-testing` contains four individually selectable skills. It is opt-in;
`core`, `engineering`, `rust` and automatic stack detection do not include it.
The inventory-oriented `all` bundle does. Once installed, each skill supports normal
task-based discovery through its narrow description.

| Installed name | Source type | Use it for | Included evidence asset |
| --- | --- | --- | --- |
| `security-state-recovery` | First-party | Crash/retry/replay and restart state invariants | `assets/recovery-matrix.md` |
| `security-secret-boundary-testing` | First-party | Secret custody, diagnostics and complete capture | `assets/capture-inventory.md` |
| `security-race-and-toctou` | First-party | Controlled schedules, one-use authority and check/use identity | `assets/race-case.md` |
| `security-protocol-fuzzing` | Adapted MIT | Parser/state-machine campaigns and minimized regressions | `assets/fuzz-campaign.md` |

The skills work without a security plugin or the upstream review clone. They complement
broader audit/validation tools by designing focused tests. They do not automatically
run attacks, install fuzzers, change deployment policy or publish findings.

## Template Structure

Every installed skill is self-contained:

```text
security-<workflow>/
  SKILL.md       # Trigger, workflow, evidence and limits
  LICENSE        # License travels with copies and APM installs
  assets/        # Editable output templates
  references/    # Conditional guidance, only where needed
```

Evidence contracts are embedded in each workflow rather than adding a fifth skill
that every task must load. The fuzzing skill alone needs a separate harness-selection
reference. No new always-on steering profile is introduced; project contracts remain
the source of actual security requirements.

Use an evidence asset as a starting point in the project's normal evidence directory.
Replace `{{PROJECT_NAME}}`, `{{TARGET_REVISION}}` and `{{CONTRACT_REFERENCE}}` locally.
Keep unsupported dimensions and unrun cases explicit. Generated evidence belongs in
the consuming project, not back in the skill or AI Central's collected archive.

## Installation And Project Selection

Preview a first installation from the reviewed AI Central checkout:

```sh
./scripts/install-skill-bundle.sh /path/to/project \
  --bundle security-testing --mode copy --dry-run
```

Apply the reviewed selection by omitting `--dry-run`. Guided setup supports the same
bundle via `--bundles security-testing`, or `--bundles core,security-testing` when a
core installation is also desired. Existing files are preserved.

For a smaller selection:

```sh
./scripts/install-skill-bundle.sh /path/to/project \
  --bundle none \
  --skills security-state-recovery,security-secret-boundary-testing \
  --mode copy --dry-run
```

Initial project-fit recommendations:

- **Session Chat:** all four, but use its project-owned verified-snapshot installer
  and reviewed AI Central pin. These changes must be committed and accepted at a new
  immutable pin before that installer can adopt them. Do not bypass the wrapper or
  repoint its snapshots to a mutable checkout.
- **Capsule Corp:** all four against named model/adapter fixtures; claims about
  guest containment or native enforcement still require the project's own evidence.
- **Sandtable:** secret boundaries first; add races/recovery when reviewing actual
  decision ownership or durable state. Select fuzzing for a concrete parser boundary.
- **Safelet:** secret boundaries first; isolation conformance remains a later skill.
  This bundle does not convert trusted userscript execution into a security sandbox.

This ingestion does not modify those downstream projects or their pins.

## Versions And Updates

Use AI Central's existing repository releases as the distribution version. There
are no independent version counters for these four skills. Stable installed names
are the public interface; source commits and local content fingerprints serve
different purposes.

| Installation | What changes when AI Central changes | Managed update procedure |
| --- | --- | --- |
| Copy | Existing copies stay unchanged; installer skips them | Compare a fresh staged install with project copies, review local edits, then explicitly replace selected owned copies |
| Link to a development checkout | Editing that checkout immediately changes linked skill content | Use for development; review before editing the shared checkout. `--dry-run` does not freeze linked bytes |
| Link to a dedicated immutable checkout | Links keep referring to that checkout | Stage a new reviewed checkout, compare skill trees, then explicitly repoint only links proven owned by the project |
| Project verified snapshot | Project wrapper controls byte validation and admission | Advance the project pin and snapshot through its own tests and review |
| APM | Manifest/ref and lockfile determine content | Pin a reviewed commit or release, update through APM, inspect the lockfile and run its audit |

Add the bundle to an APM selection with a real reviewed reference:

```sh
./scripts/generate-apm-selection.sh \
  --bundle security-testing \
  --name project-security-context \
  --ref REVIEWED_COMMIT_OR_TAG \
  --output /path/to/staging/apm.yml
```

Replace the uppercase reference with a real immutable commit or released tag.
The initial package is generated locally at the repository's current version; that
does not mean it is already present in an existing published release. Follow
[release policy](releases.md); do not manually increment package versions here.

### Removal And Renaming

`--sync` removes only deselected links whose exact targets belong to the current
AI Central checkout. It preserves real directories, local copies, repointed links,
and links to another checkout. Supply the complete desired selection when using it:
omitted managed bundles can also be pruned. Preview every sync.

Changing a source path does not automatically retarget existing links. Preserve old
names/paths through a documented migration window if a skill is renamed. Removing
a skill from the catalog can also remove the installer's ability to prove ownership
of its old link, so record explicit downstream cleanup instructions before removal.
Do not silently rewrite project-owned skill copies or verified snapshots.

## Provenance And Review Lifecycle

[security-skill-provenance.json](security-skill-provenance.json) records each shipped
skill's stable name, source path, first-party/adapted status, source commit/files,
review date, transformation notes and SHA-256 inventory of all installed resources.

The fingerprint inventory catches accidental drift, missing licenses and unreviewed
added resources. It is **not** a signature, authorization mechanism or protection
against an actor who can edit both content and manifest. It is not a replacement for
Session Chat's runtime source verification.

For each future upstream update:

1. Clone or fetch the exact candidate into ignored `external/`; never pull an
   upstream tree into installed template paths. Compare against the prior source pin.
2. Review the selected skill's source chain/license, trigger changes, commands,
   references and applicability. Put unresolved sources in the backlog, not the bundle.
3. Edit the smallest adapted skill/reference. Preserve original local guidance and
   omit upstream changes that do not fit the target workflow; document exclusions.
4. Update source commit/files, review date and notes in the provenance manifest.
   For local-only changes, retain the upstream source pin and explain the local change.
5. Inspect the complete skill diff, then refresh the inventory:

   ```sh
   python3 -B scripts/security-skill-manifest.py --refresh
   python3 -B scripts/security-skill-manifest.py --check
   ```

   Refresh updates fingerprints only. It does not change source pins, mark a new
   candidate reviewed, or perform the content review. An intentionally removed
   linked asset must also be removed from the entrypoint.
6. Validate entrypoints, links, installed licenses and relevant behavior. Run a
   fresh-context fixture evaluation for material workflow changes; preserve the raw
   request, input artifact and supported outcome. Avoid tests that merely assert
   the skill repeats its own wording.
7. If membership changes, update the installer, setup allowlist and catalog,
   regenerate APM manifests, and update count assertions and documentation. Run
   `./scripts/check.sh`; run `./scripts/check-apm.sh` when APM is available.
8. Commit/review/release through the repository's usual process. Downstream projects
   adopt the resulting revision deliberately; no automatic upstream refresh is added.

## Validation

The full repository gate checks provenance fingerprints and executes distribution
tests for preview, copy/link installs, exact selection, opt-in detection, safe sync,
project-owned edits, installed resources, APM selection and content drift.

An independent forward-test exercised the four skills against an intentionally
defective in-memory fixture. It reproduced missing receive state after acknowledgement,
double consumption, stderr secret disclosure and acceptance of oversized payloads.
See [evaluation evidence](security-skill-evaluation-2026-09-14.md). That confirms
usefulness on bounded examples, not effectiveness on every project or a security
certification. Future evaluations should add realistic counterexamples and cases
where no violation exists.

### Initial Integration Results

- `./scripts/check.sh` passed, including the new checks; two existing optional
  checks reported skips. `git diff --check` passed.
- Skill-creator entrypoint validation passed for all four skills.
- Six distribution, ownership, provenance-drift and retained-model checks passed.
- APM 0.28.0 installed the complete 143-source package, including the new skills,
  their licenses and assets. Its existing core-package frozen replay and ordinary
  drift audit passed.
- `./scripts/check-apm.sh` failed at `apm audit --ci --no-policy`: config-consistency
  expects per-skill `apm.yml` files for nine existing core dependencies. The core
  manifest and those source skills are unchanged in this ingestion. Do not report
  the stricter APM audit as passed or disable it to mask this limitation. Shell
  installation and the project-owned snapshot workflow remain available; APM CI
  audit compatibility needs a separate tooling follow-up.

## Next Ingestion Batches

| Candidate | Placement decision | Admission criteria |
| --- | --- | --- |
| Capability authorization | New focused skill if object/operation/scope/epoch tests exceed current race/recovery guidance | Exact right-separation fixture; resolve any copied IDOR checklist provenance |
| CI trust boundaries | Separate skill, initially exact-selectable | GitHub event/token/artifact fixtures; compare with existing CI guidance and collected GHA review |
| Dependency integrity / verified-source adoption | Prefer one skill plus a snapshot-admission reference | Source-byte, registry and update/removal fixtures; avoid duplicating dependency inventory |
| Agent/tool boundaries | New skill only with executable authority contracts | Untrusted input-to-tool tests and hidden-state refusal controls; substantial upstream rewrite |
| Isolation conformance | Backend-specific references beneath a focused skill | Owned fixture containment, resource ceilings and observed teardown on each claimed platform |
| General evidence contracts | Keep in current assets initially | Extract only after several workflows demonstrate a stable shared schema |

Add a second bundle only when repeated project selections justify a stable grouping.
Do not expand `security-testing` into the whole Claude-Red catalog by default. The
original [ingestion review](security-skill-ingestion-review-2026-09-14.md) retains
lower-priority candidates and unresolved source-provenance questions.
