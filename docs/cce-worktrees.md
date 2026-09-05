# CCE Worktree Seeding

Use the primary checkout's embedding cache to prepare an independent CCE index for a new
worktree. This adapter is validated against **Code Context Engine 0.4.26** and refuses other
versions until their storage and pipeline contracts have been reviewed.

## Setup

Index the primary checkout once using its normal CCE configuration. CCE's stock `post-checkout`
hook starts a background cold index as soon as Git creates a worktree. Install the ordered hook
once in the primary checkout so seeding happens first:

```sh
/path/to/ai-central/scripts/install-cce-worktree-hook.sh /path/to/primary-checkout \
  --replace-cce-hook --dry-run
/path/to/ai-central/scripts/install-cce-worktree-hook.sh /path/to/primary-checkout \
  --replace-cce-hook
```

The explicit replacement flag is required when a hook already exists. The installer recognizes
CCE's stock block, preserves other commands, and saves a backup beside the original hook.
The managed CCE block runs before unmanaged commands (including early exits), after the optional
AI Central context block. Unmanaged commands retain their order relative to one another.
It refuses unrecognized CCE commands, non-shell hooks, symlinked hook files, and external shared
hook managers; integrate the supplied template manually for those configurations. Reinstallation
is a no-op when the managed block is current. Keep the AI Central checkout at its installed path.

The managed hook runs seeding and indexing synchronously for a newly created worktree. Ordinary
checkouts retain CCE's background incremental indexing behavior. This also covers worktrees
created directly with Git, before an agent starts. If setup fails, Git may leave the new worktree
on disk; fix the reported cause and rerun the seeder on that path.

For AI Central guidance and skills as well, install `install-worktree-context-hook.sh` in the same
repository (use `--replace-hook` when a hook already exists). It adds an independent context block
before CCE; either installation order is supported. See [context hook setup](codex-worktree-context.md#install-the-git-hook).
Each installed block binds the source checkout supplied to its installer explicitly.

In the project's Codex Local Environment setup script, use:

```sh
/path/to/ai-central/scripts/setup-codex-worktree.sh "$PWD" --cce
```

The existing guidance/skill seeder runs first. CCE seeding is opt-in, so projects without CCE keep
their existing setup behavior. [Local environment setup scripts](https://learn.chatgpt.com/docs/environments/local-environment)
run when Codex creates a worktree at the start of a task.

For worktrees created with Git or another agent, run the standalone helper after creating the
worktree and before launching its CCE server:

```sh
git worktree add ../task-checkout -b codex/task
/path/to/ai-central/scripts/seed-cce-worktree.sh ../task-checkout
```

Both commands support `--source /path/to/primary-checkout` and `--dry-run`. The source must be
another checkout of the same repository. Primary-checkout invocations are successful no-ops.

The launcher requires `python3` and automatically locates the Python environment beside the
resolved `cce` executable for uv/pipx installations. The installed hook passes its captured absolute
CCE launcher through `CCE_BIN`, so this discovery still works when CCE's directory is absent from
the launching app's PATH. `python3` must still be available to bootstrap discovery. Reinstall after
moving the CCE launcher. For other installations, specify the interpreter explicitly:

```sh
CCE_PYTHON=/path/to/cce-venv/bin/python \
  /path/to/ai-central/scripts/seed-cce-worktree.sh /path/to/worktree
```

## What Gets Reused

1. Discover the primary checkout through Git's shared common directory.
2. Load CCE's actual global and project configuration to locate each checkout's distinct store.
3. Snapshot only `embedding_cache.db` with SQLite's online backup API, including committed WAL
   data. Verify the schema and snapshot integrity before publishing the cache.
4. Inherit missing, Git-ignored `.context-engine.yaml` and `.cceignore` files from the source.
   Existing target files and tracked branch configuration remain authoritative.
5. Run CCE's indexing pipeline against the actual worktree. The first run rebuilds its vector,
   full-text, graph, and manifest data. Subsequent runs use its incremental manifest.

Identical chunks with a matching embedding backend/model can reuse their cached vectors. New or
changed chunks are embedded normally. Changing models/backends can cause cache misses; CCE's
salted keys prevent reuse across those identities. Source and target may have different commits
or uncommitted edits because only content-keyed embeddings are inherited.

This avoids repeated embedding computation, but still scans and chunks the worktree and writes
its search databases. It is **not a zero-cost full-index clone**; measure `cache_hits`,
`cache_misses`, and elapsed time on the large repository before promising a particular speedup.
The model still needs to be available locally, or through the configured embedding provider.

## Isolation And Failure Behavior

- Each worktree owns its cache copy and search databases. The source database is opened read-only.
- No sessions, memory, savings statistics, ports, manifests, or search databases are copied.
- `meta.json` points to the target, and `ai-central-seed.json` records source/target commits,
  adapter version, and the count of copied embeddings.
- Existing stores are preserved and incrementally indexed; no cache merge or replacement occurs.
- Missing/empty source caches fail instead of silently starting a cold index for a fresh target.
- Legacy basename-only stores require migration with CCE before seeding; dry runs never migrate.
- Pipeline errors return a nonzero exit status. Retry the same command after fixing the cause;
  previously published cache data remains usable.
- Run setup before the target's MCP/watcher/indexer starts. The helper serializes its own setup
  invocations, but CCE does not participate in that lock. A source MCP may remain active because
  the cache is a single SQLite snapshot.

`--seed-only` copies the cache without building a searchable index. Follow it with `cce index`
from the worktree before searching. The default command completes both steps.

## Point MCP At The Worktree

Seeding a worktree does not change an existing MCP server's project binding. A server configured
with the primary checkout's absolute `--project-dir` will continue searching that checkout.
Configure the task's CCE server to use:

```sh
cce serve --project-dir /absolute/path/to/worktree
```

If the MCP client reliably launches servers with the worktree as the working directory, `cce serve`
can discover the root automatically. Verify the launched process's working directory instead of
assuming this for a global MCP configuration. See [CCE's serve reference](https://github.com/elara-labs/code-context-engine/blob/main/docs/wiki/CLI-Reference.md#cce-serve).

The setup helper deliberately does not run `cce init` or replace editor configurations. Hook
installation is a separate, explicit command because hooks are shared across the repository's
worktrees. A pre-existing store is preserved by the seeder, so it cannot retroactively avoid work
already started by the stock hook. Review the managed hook after CCE lifecycle operations such as
uninstalling or changing its hook format. To undo the hook installation, restore the saved backup
after checking for any subsequent local hook edits.

Reusable agent guidance is available in `templates/worktree/cce-guidance.md`.

## Validation And Source Review

The default repository check includes dependency-free tests for SQLite WAL backup, independent
cache writes, repository boundaries, non-overwrite behavior, invalid caches, error propagation,
and real Git hook dispatch with stub CCE commands.
To run the real CCE integration test with an already downloaded FastEmbed model:

```sh
CCE_TEST_PYTHON=/path/to/cce-venv/bin/python python3 -B scripts/check-cce-worktree.py
```

That test uses temporary Git checkouts and temporary CCE storage. It checks cache hits for unchanged
content, misses for new content, deleted-file exclusion, dry-run behavior, and incremental reruns.
It does not benchmark a production repository or contact an embedding service.

The implementation was reviewed against the installed 0.4.26 package: `utils.py` (path-derived
slugs and legacy migration), `config.py`, `indexer/embedding_cache.py` (schema),
`indexer/embedder.py` (backend/model salt), `indexer/pipeline.py` (reconciliation and error result),
and `cli.py` (CLI error handling). [Upstream repository](https://github.com/elara-labs/code-context-engine).

Full-store cloning is deferred: CCE updates vector, FTS, graph, and manifest data separately, and
its pipeline lock is process-local. Independently snapshotting those stores while a source writer
is active does not establish one consistent index state. Cache-only seeding avoids that dependency.
