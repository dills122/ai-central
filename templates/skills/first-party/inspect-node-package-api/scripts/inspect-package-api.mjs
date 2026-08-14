#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const DECLARATION_EXTENSIONS = [".d.ts", ".d.mts", ".d.cts"];
const RUNTIME_EXTENSIONS = [".js", ".mjs", ".cjs", ".jsx"];

function fail(message, code = 1) {
  process.stderr.write(`inspect-package-api: ${message}\n`);
  process.exit(code);
}

function usage() {
  process.stdout.write(`Usage: inspect-package-api.mjs PACKAGE_OR_SUBPATH [options]

Resolve an installed Node package and map its public entry points without executing it.

Options:
  --project DIR       Resolve from this project/workspace directory (default: cwd)
  --symbol NAME       Search the declaration graph for an identifier
  --max-files N       Limit declaration files followed or searched (default: 120)
  --json              Emit machine-readable JSON
  -h, --help          Show this help

Examples:
  inspect-package-api.mjs zod --project .
  inspect-package-api.mjs @scope/pkg/server --project apps/api
  inspect-package-api.mjs package-name --symbol Client --json
`);
}

function parseArgs(argv) {
  const options = {
    project: process.cwd(),
    symbol: null,
    maxFiles: 120,
    json: false,
    specifier: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "-h" || argument === "--help") {
      usage();
      process.exit(0);
    }
    if (argument === "--json") {
      options.json = true;
      continue;
    }
    if (argument === "--project" || argument === "--symbol" || argument === "--max-files") {
      const value = argv[index + 1];
      if (!value) fail(`${argument} requires a value`, 2);
      index += 1;
      if (argument === "--project") options.project = value;
      if (argument === "--symbol") options.symbol = value;
      if (argument === "--max-files") {
        options.maxFiles = Number.parseInt(value, 10);
        if (!Number.isInteger(options.maxFiles) || options.maxFiles < 1) {
          fail("--max-files must be a positive integer", 2);
        }
      }
      continue;
    }
    if (argument.startsWith("-")) fail(`unknown option: ${argument}`, 2);
    if (options.specifier) fail("provide exactly one package specifier", 2);
    options.specifier = argument;
  }

  if (!options.specifier) {
    usage();
    fail("a package specifier is required", 2);
  }

  options.project = path.resolve(options.project);
  return options;
}

function splitSpecifier(specifier) {
  const segments = specifier.split("/").filter(Boolean);
  if (specifier.startsWith("@")) {
    if (segments.length < 2) fail(`invalid scoped package specifier: ${specifier}`, 2);
    return {
      packageName: `${segments[0]}/${segments[1]}`,
      subpath: segments.length > 2 ? `./${segments.slice(2).join("/")}` : ".",
    };
  }
  if (segments.length < 1) fail(`invalid package specifier: ${specifier}`, 2);
  return {
    packageName: segments[0],
    subpath: segments.length > 1 ? `./${segments.slice(1).join("/")}` : ".",
  };
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (error) {
    fail(`cannot read ${file}: ${error.message}`);
  }
}

function walkParents(start) {
  const directories = [];
  let current = path.resolve(start);
  while (true) {
    directories.push(current);
    const parent = path.dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return directories;
}

function ascendToPackageRoot(resolvedFile, expectedName) {
  let current = fs.existsSync(resolvedFile) && fs.statSync(resolvedFile).isDirectory()
    ? resolvedFile
    : path.dirname(resolvedFile);
  while (true) {
    const manifestFile = path.join(current, "package.json");
    if (fs.existsSync(manifestFile)) {
      try {
        const manifest = JSON.parse(fs.readFileSync(manifestFile, "utf8"));
        if (!expectedName || manifest.name === expectedName) return current;
      } catch {
        // Continue upward; the package's own manifest is validated after resolution.
      }
    }
    const parent = path.dirname(current);
    if (parent === current) return null;
    current = parent;
  }
}

function findPackageRoot(project, packageName, requestedSpecifier) {
  for (const directory of walkParents(project)) {
    const candidate = path.join(directory, "node_modules", ...packageName.split("/"));
    if (fs.existsSync(path.join(candidate, "package.json"))) {
      return fs.realpathSync(candidate);
    }
  }

  const requireFromProject = createRequire(path.join(project, "__inspect_package_api__.cjs"));
  for (const request of [requestedSpecifier, packageName]) {
    try {
      const resolved = requireFromProject.resolve(request);
      const root = ascendToPackageRoot(resolved, packageName);
      if (root) return fs.realpathSync(root);
    } catch {
      // Try the next resolution route.
    }
  }
  return null;
}

function isConditionMap(value) {
  return value && typeof value === "object" && !Array.isArray(value)
    && !Object.keys(value).some((key) => key.startsWith("."));
}

function flattenTargets(value, conditions = [], output = []) {
  if (typeof value === "string") {
    output.push({ conditions, target: value });
    return output;
  }
  if (value === null) {
    output.push({ conditions, target: null });
    return output;
  }
  if (Array.isArray(value)) {
    value.forEach((item, index) => flattenTargets(item, [...conditions, `fallback[${index}]`], output));
    return output;
  }
  if (value && typeof value === "object") {
    for (const [condition, target] of Object.entries(value)) {
      flattenTargets(target, [...conditions, condition], output);
    }
  }
  return output;
}

function exportEntries(manifest) {
  if (manifest.exports === undefined) return [];
  const raw = manifest.exports;
  if (typeof raw === "string" || raw === null || Array.isArray(raw) || isConditionMap(raw)) {
    return [{ key: ".", value: raw }];
  }
  return Object.entries(raw)
    .filter(([key]) => key.startsWith("."))
    .map(([key, value]) => ({ key, value }));
}

function matchExportEntry(entries, subpath) {
  const exact = entries.find((entry) => entry.key === subpath);
  if (exact) return { entry: exact, wildcard: null };

  for (const entry of entries) {
    const star = entry.key.indexOf("*");
    if (star === -1) continue;
    const prefix = entry.key.slice(0, star);
    const suffix = entry.key.slice(star + 1);
    if (subpath.startsWith(prefix) && subpath.endsWith(suffix)) {
      return {
        entry,
        wildcard: subpath.slice(prefix.length, subpath.length - suffix.length),
      };
    }
  }
  return null;
}

function substituteWildcard(value, wildcard) {
  if (wildcard === null) return value;
  if (typeof value === "string") return value.replaceAll("*", wildcard);
  if (Array.isArray(value)) return value.map((item) => substituteWildcard(item, wildcard));
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, substituteWildcard(item, wildcard)]),
    );
  }
  return value;
}

function publicSpecifier(packageName, exportKey) {
  return exportKey === "." ? packageName : `${packageName}${exportKey.slice(1)}`;
}

function safePackagePath(packageRoot, target) {
  if (typeof target !== "string" || !target.startsWith("./")) return null;
  const resolved = path.resolve(packageRoot, target.slice(2));
  const relative = path.relative(packageRoot, resolved);
  if (relative.startsWith("..") || path.isAbsolute(relative)) return null;
  return resolved;
}

function pathRecord(packageRoot, target) {
  const absolute = safePackagePath(packageRoot, target);
  return {
    target,
    absolute,
    exists: absolute ? fs.existsSync(absolute) : false,
  };
}

function isDeclaration(file) {
  return DECLARATION_EXTENSIONS.some((extension) => file.endsWith(extension));
}

function isRuntime(file) {
  return RUNTIME_EXTENSIONS.some((extension) => file.endsWith(extension));
}

function declarationCandidates(runtimeFile) {
  const candidates = [];
  if (!runtimeFile) return candidates;
  if (isDeclaration(runtimeFile)) return [runtimeFile];

  if (runtimeFile.endsWith(".mjs")) {
    candidates.push(runtimeFile.slice(0, -4) + ".d.mts", runtimeFile.slice(0, -4) + ".d.ts");
  } else if (runtimeFile.endsWith(".cjs")) {
    candidates.push(runtimeFile.slice(0, -4) + ".d.cts", runtimeFile.slice(0, -4) + ".d.ts");
  } else if (/\.[cm]?jsx?$/.test(runtimeFile)) {
    candidates.push(runtimeFile.replace(/\.[cm]?jsx?$/, ".d.ts"));
  } else {
    candidates.push(`${runtimeFile}.d.ts`, `${runtimeFile}.d.mts`, `${runtimeFile}.d.cts`);
  }
  candidates.push(
    path.join(runtimeFile, "index.d.ts"),
    path.join(runtimeFile, "index.d.mts"),
    path.join(runtimeFile, "index.d.cts"),
  );
  return [...new Set(candidates)];
}

function existingFiles(files) {
  return [...new Set(files)].filter((file) => {
    try {
      return fs.statSync(file).isFile();
    } catch {
      return false;
    }
  });
}

function exportedNames(text) {
  const names = new Set();
  const declarationPattern = /\bexport\s+(?:declare\s+)?(?:abstract\s+)?(?:class|interface|type|enum|function|const|let|var|namespace|module)\s+([A-Za-z_$][\w$]*)/g;
  const defaultPattern = /\bexport\s+default\b/g;
  const namespacePattern = /\bexport\s+\*\s+as\s+([A-Za-z_$][\w$]*)\s+from\b/g;
  const listPattern = /\bexport\s*\{([\s\S]*?)\}(?:\s*from\s*["'][^"']+["'])?\s*;?/g;

  for (const match of text.matchAll(declarationPattern)) names.add(match[1]);
  if (defaultPattern.test(text)) names.add("default");
  for (const match of text.matchAll(namespacePattern)) names.add(match[1]);
  for (const match of text.matchAll(listPattern)) {
    for (const rawItem of match[1].split(",")) {
      const item = rawItem.trim().replace(/^type\s+/, "");
      if (!item) continue;
      const alias = item.match(/\bas\s+([A-Za-z_$][\w$]*)$/);
      const original = item.match(/^([A-Za-z_$][\w$]*)/);
      if (alias) names.add(alias[1]);
      else if (original) names.add(original[1]);
    }
  }
  if (/\bexport\s*=/.test(text)) names.add("export=");
  return [...names].sort();
}

function reexportSpecifiers(text) {
  const specifiers = [];
  const pattern = /\bexport(?:\s+type)?\s+(?:\*|\*\s+as\s+[\w$]+|\{[\s\S]*?\})\s+from\s+["']([^"']+)["']/g;
  for (const match of text.matchAll(pattern)) specifiers.push(match[1]);
  return [...new Set(specifiers)];
}

function isInsidePackage(packageRoot, file) {
  const relative = path.relative(packageRoot, file);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function resolveDeclarationImport(fromFile, specifier, packageRoot) {
  if (!specifier.startsWith(".")) return null;
  const base = path.resolve(path.dirname(fromFile), specifier);
  if (!isInsidePackage(packageRoot, base)) return null;
  const candidates = [base];

  if (base.endsWith(".js")) candidates.push(base.slice(0, -3) + ".d.ts");
  if (base.endsWith(".mjs")) candidates.push(base.slice(0, -4) + ".d.mts", base.slice(0, -4) + ".d.ts");
  if (base.endsWith(".cjs")) candidates.push(base.slice(0, -4) + ".d.cts", base.slice(0, -4) + ".d.ts");
  if (!path.extname(base)) {
    candidates.push(`${base}.d.ts`, `${base}.d.mts`, `${base}.d.cts`);
  }
  candidates.push(
    path.join(base, "index.d.ts"),
    path.join(base, "index.d.mts"),
    path.join(base, "index.d.cts"),
  );
  return existingFiles(candidates).find((candidate) => {
    try {
      return isInsidePackage(packageRoot, fs.realpathSync(candidate));
    } catch {
      return false;
    }
  }) ?? null;
}

function inspectDeclarationGraph(entryFiles, packageRoot, maxFiles) {
  const queue = [...entryFiles];
  const seen = new Set();
  const files = [];
  const unresolved = [];

  while (queue.length > 0 && seen.size < maxFiles) {
    const file = queue.shift();
    const canonical = fs.realpathSync(file);
    if (seen.has(canonical)) continue;
    seen.add(canonical);

    const text = fs.readFileSync(canonical, "utf8");
    const reexports = reexportSpecifiers(text);
    files.push({
      file: canonical,
      relative: path.relative(packageRoot, canonical),
      exports: exportedNames(text),
      reexports,
    });

    for (const specifier of reexports) {
      const resolved = resolveDeclarationImport(canonical, specifier, packageRoot);
      if (resolved) queue.push(resolved);
      else unresolved.push({ from: canonical, specifier });
    }
  }

  return {
    files,
    unresolved,
    truncated: queue.length > 0,
  };
}

function runtimeExportHints(file) {
  if (!file || !fs.existsSync(file) || fs.statSync(file).size > 2_000_000) return [];
  const text = fs.readFileSync(file, "utf8");
  const names = new Set(exportedNames(text));
  const assignmentPattern = /\b(?:exports|module\.exports)\.([A-Za-z_$][\w$]*)\s*=/g;
  const objectPattern = /\bmodule\.exports\s*=\s*\{([\s\S]*?)\}\s*;?/g;
  for (const match of text.matchAll(assignmentPattern)) names.add(match[1]);
  for (const match of text.matchAll(objectPattern)) {
    for (const rawItem of match[1].split(",")) {
      const item = rawItem.trim();
      const key = item.match(/^(?:["']([^"']+)["']|([A-Za-z_$][\w$]*))/);
      if (key) names.add(key[1] ?? key[2]);
    }
  }
  return [...names].sort();
}

function collectDeclarationFiles(root, limit) {
  const output = [];
  const queue = [root];
  while (queue.length > 0 && output.length < limit) {
    const directory = queue.shift();
    let entries;
    try {
      entries = fs.readdirSync(directory, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const entry of entries) {
      if (output.length >= limit) break;
      if (entry.name === "node_modules") continue;
      const file = path.join(directory, entry.name);
      if (entry.isDirectory()) queue.push(file);
      else if (entry.isFile() && isDeclaration(file)) output.push(file);
    }
  }
  return output;
}

function symbolMatches(files, symbol) {
  const escaped = symbol.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp(`\\b${escaped}\\b`);
  const matches = [];
  for (const file of files) {
    const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
    lines.forEach((line, index) => {
      if (pattern.test(line)) {
        matches.push({ file, line: index + 1, text: line.trim().slice(0, 240) });
      }
    });
  }
  return matches.slice(0, 100);
}

function buildReport(options) {
  if (!fs.existsSync(options.project) || !fs.statSync(options.project).isDirectory()) {
    fail(`project directory does not exist: ${options.project}`);
  }

  const { packageName, subpath } = splitSpecifier(options.specifier);
  const packageRoot = findPackageRoot(options.project, packageName, options.specifier);
  if (!packageRoot) {
    fail(`cannot resolve ${packageName} from ${options.project}; verify the workspace and install dependencies`);
  }

  const manifestFile = path.join(packageRoot, "package.json");
  const manifest = readJson(manifestFile);
  const warnings = [];
  const entries = exportEntries(manifest);
  const matched = matchExportEntry(entries, subpath);
  const hasExports = manifest.exports !== undefined;

  if (hasExports && !matched) {
    warnings.push(`specifier ${options.specifier} is not exposed by package.json exports`);
  }

  let selectedTargets = [];
  let selectedExportKey = subpath;
  if (matched) {
    selectedExportKey = matched.entry.key;
    const selectedValue = substituteWildcard(matched.entry.value, matched.wildcard);
    selectedTargets = flattenTargets(selectedValue);
  } else if (!hasExports && subpath !== ".") {
    selectedTargets = [{ conditions: ["legacy-deep-import"], target: subpath }];
  }

  const publicEntrypoints = entries.slice(0, 200).map((entry) => ({
    key: entry.key,
    specifier: publicSpecifier(packageName, entry.key),
    targets: flattenTargets(entry.value).map((target) => ({
      conditions: target.conditions,
      ...pathRecord(packageRoot, target.target),
    })),
  }));
  if (entries.length > publicEntrypoints.length) {
    warnings.push(`public entrypoint list truncated at ${publicEntrypoints.length}`);
  }

  const selectedRecords = selectedTargets.map((target) => ({
    conditions: target.conditions,
    ...pathRecord(packageRoot, target.target),
  }));

  const explicitDeclarationFiles = selectedRecords
    .filter((record) => record.absolute && (
      isDeclaration(record.absolute)
      || record.conditions.some((condition) => condition === "types" || condition.startsWith("types@"))
    ))
    .map((record) => record.absolute);

  if (subpath === ".") {
    for (const manifestType of [manifest.types, manifest.typings]) {
      if (typeof manifestType === "string") {
        const relativeType = manifestType.startsWith("./") ? manifestType : `./${manifestType}`;
        const absolute = safePackagePath(packageRoot, relativeType);
        if (absolute) explicitDeclarationFiles.push(absolute);
      }
    }
  }

  const runtimeFiles = existingFiles(selectedRecords
    .filter((record) => record.absolute && !isDeclaration(record.absolute))
    .map((record) => record.absolute));

  if (!hasExports && subpath === ".") {
    for (const manifestRuntime of [manifest.module, manifest.main, "index.js"]) {
      if (typeof manifestRuntime !== "string") continue;
      const relativeRuntime = manifestRuntime.startsWith("./") ? manifestRuntime : `./${manifestRuntime}`;
      const absolute = safePackagePath(packageRoot, relativeRuntime);
      if (absolute) runtimeFiles.push(absolute);
    }
  }

  const declarationFiles = existingFiles([
    ...explicitDeclarationFiles,
    ...selectedRecords.filter((record) => record.absolute).flatMap((record) => declarationCandidates(record.absolute)),
    ...runtimeFiles.flatMap(declarationCandidates),
  ]);

  if (declarationFiles.length === 0) warnings.push("no declaration entry file was resolved for this specifier");
  if (manifest.typesVersions) warnings.push("package declares typesVersions; verify compiler-version-specific routing when relevant");

  const declarationGraph = inspectDeclarationGraph(declarationFiles, packageRoot, options.maxFiles);
  if (declarationGraph.truncated) warnings.push(`declaration graph truncated at ${options.maxFiles} files`);

  let searchedFiles = declarationGraph.files.map((record) => record.file);
  let matches = [];
  if (options.symbol) {
    matches = symbolMatches(searchedFiles, options.symbol);
    if (matches.length === 0) {
      const fallbackFiles = collectDeclarationFiles(packageRoot, options.maxFiles);
      searchedFiles = [...new Set([...searchedFiles, ...fallbackFiles])];
      matches = symbolMatches(searchedFiles, options.symbol);
      if (fallbackFiles.length >= options.maxFiles) {
        warnings.push(`fallback symbol search considered at most ${options.maxFiles} declaration files`);
      }
    }
  }

  const uniqueRuntimeFiles = existingFiles(runtimeFiles);
  const runtimeHints = uniqueRuntimeFiles.map((file) => ({
    file,
    relative: path.relative(packageRoot, file),
    exports: isRuntime(file) ? runtimeExportHints(file) : [],
  }));

  return {
    request: {
      specifier: options.specifier,
      packageName,
      subpath,
      project: options.project,
      symbol: options.symbol,
    },
    package: {
      name: manifest.name ?? packageName,
      version: manifest.version ?? null,
      root: packageRoot,
      manifest: manifestFile,
      moduleType: manifest.type ?? "commonjs-default",
      types: manifest.types ?? manifest.typings ?? null,
      main: manifest.main ?? null,
      module: manifest.module ?? null,
    },
    exportBoundary: {
      hasExports,
      matched: Boolean(matched) || !hasExports,
      selectedKey: selectedExportKey,
      wildcard: matched?.wildcard ?? null,
    },
    publicEntrypoints,
    selectedTargets: selectedRecords,
    declarationEntryFiles: declarationFiles,
    runtimeEntryFiles: uniqueRuntimeFiles,
    declarationGraph,
    runtimeHints,
    symbolMatches: matches,
    warnings,
  };
}

function printList(values, empty = "(none)") {
  return values.length > 0 ? values.join(", ") : empty;
}

function formatConditions(conditions) {
  return conditions.length > 0 ? conditions.join(" > ") : "default";
}

function printText(report) {
  process.stdout.write("Package\n");
  process.stdout.write(`  requested: ${report.request.specifier}\n`);
  process.stdout.write(`  installed: ${report.package.name}@${report.package.version ?? "unknown"}\n`);
  process.stdout.write(`  root: ${report.package.root}\n`);
  process.stdout.write(`  module type: ${report.package.moduleType}\n`);

  process.stdout.write("\nExport boundary\n");
  process.stdout.write(`  package exports: ${report.exportBoundary.hasExports ? "yes" : "no (legacy manifest resolution)"}\n`);
  process.stdout.write(`  requested subpath: ${report.request.subpath}\n`);
  process.stdout.write(`  matched: ${report.exportBoundary.matched ? "yes" : "no"}\n`);
  if (report.exportBoundary.wildcard !== null) {
    process.stdout.write(`  wildcard value: ${report.exportBoundary.wildcard}\n`);
  }

  process.stdout.write("\nSelected targets\n");
  if (report.selectedTargets.length === 0) process.stdout.write("  (none)\n");
  for (const target of report.selectedTargets) {
    const status = target.target === null ? "blocked" : target.exists ? "exists" : "missing";
    process.stdout.write(`  [${formatConditions(target.conditions)}] ${target.target ?? "null"} (${status})\n`);
  }

  process.stdout.write("\nDeclaration entries\n");
  for (const file of report.declarationEntryFiles) process.stdout.write(`  ${file}\n`);
  if (report.declarationEntryFiles.length === 0) process.stdout.write("  (none)\n");

  process.stdout.write("\nDeclaration API index\n");
  if (report.declarationGraph.files.length === 0) process.stdout.write("  (none)\n");
  for (const file of report.declarationGraph.files) {
    process.stdout.write(`  ${file.relative}\n`);
    process.stdout.write(`    exports: ${printList(file.exports)}\n`);
    if (file.reexports.length > 0) process.stdout.write(`    re-exports: ${file.reexports.join(", ")}\n`);
  }

  process.stdout.write("\nRuntime entries and static export hints\n");
  if (report.runtimeHints.length === 0) process.stdout.write("  (none)\n");
  for (const hint of report.runtimeHints) {
    process.stdout.write(`  ${hint.file}\n`);
    process.stdout.write(`    syntax hints: ${printList(hint.exports)}\n`);
  }

  if (report.request.symbol) {
    process.stdout.write(`\nSymbol matches: ${report.request.symbol}\n`);
    if (report.symbolMatches.length === 0) process.stdout.write("  (none)\n");
    for (const match of report.symbolMatches) {
      process.stdout.write(`  ${match.file}:${match.line}: ${match.text}\n`);
    }
  }

  process.stdout.write("\nPublic entrypoints\n");
  if (report.publicEntrypoints.length === 0) process.stdout.write("  (legacy manifest; no exports map)\n");
  for (const entry of report.publicEntrypoints) {
    process.stdout.write(`  ${entry.specifier}\n`);
    for (const target of entry.targets) {
      process.stdout.write(`    [${formatConditions(target.conditions)}] ${target.target ?? "null"}\n`);
    }
  }

  if (report.declarationGraph.unresolved.length > 0) {
    process.stdout.write("\nUnresolved declaration re-exports\n");
    for (const item of report.declarationGraph.unresolved) {
      process.stdout.write(`  ${item.from} -> ${item.specifier}\n`);
    }
  }

  if (report.warnings.length > 0) {
    process.stdout.write("\nWarnings\n");
    for (const warning of report.warnings) process.stdout.write(`  - ${warning}\n`);
  }
}

const options = parseArgs(process.argv.slice(2));
const report = buildReport(options);
if (options.json) process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
else printText(report);
