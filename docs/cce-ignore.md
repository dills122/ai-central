# Reusable CCE Ignore Policy

Seed `templates/cce/default.cceignore` into a project's root before its first CCE index. The
baseline removes common build caches, dependency output, test reports, and nested working copies
while keeping authored code, contracts, tests, fixtures, migrations, and documentation available.
It supplements CCE's own exclusions; it does not determine whether arbitrary code was generated.

## Install

Preview and install an editable local copy:

```sh
/path/to/ai-central/scripts/seed-cce-ignore.sh /path/to/project --dry-run
/path/to/ai-central/scripts/seed-cce-ignore.sh /path/to/project
```

The target must be a Git checkout root. Python 3 is required; CCE itself is not required to seed
the policy. The POSIX shell entrypoint uses a Python helper for worktree-aware Git paths and
atomic file creation. The default adds `/.cceignore` to the checkout's local `info/exclude` when
needed, without changing `.gitignore`. A local exclusion is shared by linked Git worktrees.
If a higher-priority Git rule prevents exclusion, installation reports failure before publishing
the policy; the attempted local exclude entry may remain for manual review.

For a policy intended to be committed with the project, pass `--trackable`. This suppresses new
local exclusions; it does not remove existing Git ignore rules or stage anything.

Guided AI Central setup exposes the same local installation as an opt-in flag:

```sh
/path/to/ai-central/scripts/setup-ai-context.sh /path/to/project --yes --cce-ignore --dry-run
```

Remove `--dry-run` to apply. Ordinary setup without this flag does not change CCE policy.
Existing `.cceignore` files and valid symlinks are preserved, including local edits and empty
policies. Tracked deletions are preserved too. Invalid directory/dangling-link destinations fail.
Re-running the installer does not refresh an existing copy: compare it with the template and
manually select updates. It never replaces a project's exclusions with the shared baseline.

## CCE 0.4.26 Matching Details

These behaviors were verified against the installed indexer and parser, including fixture files:

- The pipeline does not read `.gitignore` as its indexing policy. YAML `indexer.ignore` uses exact
  names in this version. Put glob patterns in root `.cceignore` instead.
- Basename patterns match at any depth; `**/` supports nested path patterns. Trailing `/` matches
  directories. Negation (`!`) is unsupported, so remove or narrow an exclusion to keep a path.
- The matcher strips leading dots from root paths. A plain `.astro/` rule misses root `.astro`
  while matching `apps/web/.astro`. The template includes explicit root aliases such as `astro/*`
  alongside hidden-directory rules. The installer refuses aliases that overlap existing literal
  non-hidden paths. If adding a source path such as `astro/` later, remove or narrow its alias;
  CCE's matcher cannot distinguish those root spellings. Reassess these aliases when upgrading.
- Built-in exclusions still apply independently. Removing a baseline rule cannot re-include a
  path that CCE itself excludes. Symlinks are already skipped by the filesystem walk.

## Project-Specific Additions

Do not copy `.gitignore` wholesale. Several projects deliberately re-include generated contracts
or evidence using negation, and CCE cannot express those exceptions. `lib/`, `types/`, `pkg/`,
`artifacts/`, `generated/`, `*.d.ts`, and `*.generated.*` are deliberately absent from the shared
exclusions. For example, `trader-tools/lib` and `booksie/lib` contain source, while `wap-labs`
generates useful contracts and knowledge-graph documentation.

After inspecting the project's build configuration, append exact disposable output paths, e.g.:

```gitignore
# Only if these paths are disposable outputs in this project:
**/engine-wasm/pkg/
**/transport-rust/pkg/
apps/api/types/
```

Avoid excluding all `artifacts/` in `capsule-corp`: its Git policy explicitly retains selected
validator evidence. Likewise, retain curated fuzz seeds, test snapshots, schemas, and migrations.
Binary assets and large files already receive additional filtering from CCE; no blanket asset,
JSON, Markdown, or data-directory exclusion is added here.

## Worktrees And Indexing

The existing CCE worktree seeder inherits a missing, Git-ignored `.cceignore` from the source
checkout before indexing. A tracked policy arrives with the target branch instead. This installer
therefore needs no new checkout hook; see [CCE worktree seeding](cce-worktrees.md).

Review the policy before indexing the primary checkout. For an already indexed project, run an
ordinary project-wide `cce index` after changing exclusions so CCE reconciles its current file set;
merely creating this file does not immediately remove old search entries. Seeding this policy
does not start indexing, alter MCP bindings, or install hooks.

## Local Inventory Basis

The 2026-09-05 read-only inventory covered 81 Git checkouts under the local `repos` workspace
(Git discovery through three directory levels) and 11 additional non-Git project folders with
build manifests (inspected through five levels). Dependency/build trees were pruned from manifest
discovery. Git-tracked paths, available ignore files, package scripts, and build manifests informed
the baseline; a separate filesystem sample inspected existing untracked output in 12 checkouts.
This is a local snapshot, not a claim about every revision or every nested checkout.

The standalone installer's read-only preview succeeded for all 81 Git checkouts. Installation,
non-overwrite behavior, local exclusions, worktree inheritance, and guided setup are covered by
fixture checks; the optional installed-CCE check exercises the real matcher and directory walk.

| Evidence | Promoted exclusions |
| --- | --- |
| Angular starters, booksie, formly-agent-contracts | `.angular/cache`, `out-tsc`, `bazel-out` |
| forage, formly-agent-contracts, session-chat, breakerflow-platform | Astro cache and generated framework state |
| reef admin UI; WXT extension projects | SvelteKit/WXT output and deployment caches |
| booksie, trader-tools, trove, Rush workspaces | Rush temporary/deployment trees, Heft, emitted module formats |
| formly-agent-contracts, breakerflow-platform, sandtable | Playwright/test results, coverage, benchmark artifacts |
| capsule-corp local Swift experiments | `.build` dependency/build trees and Swift workspace state |
| sandtable | Case-sensitive .NET `Bin`/`Obj` variants and local SDK/tool state |
| Python and JVM projects | Test/type-check caches, Gradle/Kotlin intermediates |
| Nested local checkout and CCE state | `.claude/worktrees`, `.worktrees`, `.cce`, `.ai-central` |

Matching the additional rules against the inventory preserved tracked source and generated
contracts. The matches beyond CCE defaults were 22 tracked minified browser assets/log files in
four checkouts, plus 14 build-log/framework-cache files in three non-Git projects. Repository-specific output names still
need review; package manifests and ignore files alone are not proof that every matching file is
disposable.

### Candidate File Comparison

On the sampled on-disk checkouts, the baseline produced these counts:

| Project | CCE defaults | Defaults plus baseline |
| --- | ---: | ---: |
| capsule-corp | 76,237 | 1,069 |
| booksie | 2,639 | 166 |
| reef | 4,542 | 1,455 |
| sandtable | 4,239 | 3,752 |
| session-chat | 539 | 303 |

This read-only comparison used CCE 0.4.26's filesystem walker, default exclusions, skipped
extensions, and 2 MiB file limit, then applied the template with CCE's actual matcher. It included
untracked local outputs; it did not read file bodies, load an embedding model, or rebuild indexes.
Counts are candidates before UTF-8/content filtering, not chunk counts or measured indexing times.
The largest reduction was Swift `.build` trees and nested worktrees in `capsule-corp`; some
projects already have little extra output to exclude. No consuming repository was modified.
