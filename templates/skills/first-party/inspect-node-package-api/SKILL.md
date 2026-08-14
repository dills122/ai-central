---
name: inspect-node-package-api
description: Resolve and inspect the public API of an installed Node.js package without executing it. Use when Codex needs to understand a dependency in node_modules, verify an import or subpath, find exported functions, classes, types, or signatures, trace TypeScript declaration re-exports, compare ESM/CommonJS/type entry points, or determine the installed package version and interface before writing integration code.
---

# Inspect Node Package API

Treat the installed package and its declarations as the primary evidence for the version the project actually uses. Produce a compact, usage-ready API map with source paths and clearly label anything inferred from runtime syntax.

## Start With The Inspector

Run the bundled script from the target project:

```sh
node path/to/skill/scripts/inspect-package-api.mjs PACKAGE_OR_SUBPATH --project PROJECT_DIR
```

Useful forms:

```sh
node path/to/skill/scripts/inspect-package-api.mjs zod --project .
node path/to/skill/scripts/inspect-package-api.mjs @scope/pkg/server --project .
node path/to/skill/scripts/inspect-package-api.mjs pkg --project . --symbol Client
node path/to/skill/scripts/inspect-package-api.mjs pkg --project . --json
```

Resolve the script path from this skill directory. Do not copy or rewrite the helper into the target repository.

The inspector:

- resolves npm, pnpm, or Yarn packages exposed through `node_modules`
- reports the installed version and package root
- interprets root, conditional, explicit subpath, and wildcard `exports`
- distinguishes type, import, require, node, and default targets
- finds declaration entry files and follows relative declaration re-exports
- extracts exported symbol names as navigation hints
- reports static ESM/CommonJS export hints when declarations are unavailable
- never imports or evaluates package code

Use `--help` for the complete command interface.

## Trace The Requested Surface

1. Inspect the exact specifier used by the project, including its subpath. Do not assume the root export and a subpath expose the same API.
2. Prefer targets whose conditions match the consuming code: `types` for TypeScript declarations, then `import` or `require` for runtime behavior.
3. Read the reported declaration root and relevant re-exported files. The helper's symbol list is a navigation index, not a replacement for reading signatures, overloads, generics, comments, and deprecations.
4. When `--symbol NAME` finds a candidate, inspect the cited lines and its enclosing declaration. Search referenced base types or option types as needed.
5. Inspect implementation files only when declarations are absent, incomplete, or the question concerns runtime behavior. Keep syntax-derived export hints labelled as hints.

Use focused follow-up searches rather than dumping an entire dependency:

```sh
rg -n "^(export )?(declare )?(class|interface|type|function|const) NAME\\b|NAME" DECLARATION_FILES
rg -n "@deprecated|@experimental|@internal" DECLARATION_FILES
```

Do not treat a file merely present inside the package as public. A supported surface should be reachable through the requested public entry point or documented by the package. Deep internal files can explain behavior but do not establish an import contract.

## Handle Edge Cases

- If the package cannot be found, verify the project/workspace directory and whether dependencies are installed. Do not silently inspect a registry's latest version instead.
- If `exports` blocks a subpath, report that boundary even if a matching internal file exists.
- If declarations are selected through `typesVersions`, generated resolution, Yarn Plug'n'Play, or a nonstandard loader the helper cannot fully resolve, use the manifest and the repository's own TypeScript/loader configuration to finish the trace.
- If declaration and runtime surfaces disagree, report both and identify the consuming module mode. Do not merge them into an invented common API.
- If several installed versions exist, report the version resolved from the specified project. Inspect another workspace from its own directory.
- Avoid loading the package with `node -e "require(...)"` or dynamic `import()` merely to enumerate keys; package initialization may perform I/O, mutate global state, or require environment configuration.

## Report The Result

Return:

- exact package specifier, installed name/version, and package root
- applicable public export and condition targets
- declaration and runtime entry files used as evidence
- relevant exported names and exact signatures for the user's question
- constraints such as subpath availability, module mode, deprecation, or declaration gaps
- a minimal import and call/type example when useful
- any remaining inference or uncertainty

Keep package internals out of the target project's source changes unless the user explicitly asks to patch or vendor the dependency.
