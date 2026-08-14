#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
inspector=$repo_root/templates/skills/first-party/inspect-node-package-api/scripts/inspect-package-api.mjs
fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/ai-central-node-api-check.XXXXXX")
trap 'rm -rf "$fixture_dir"' EXIT HUP INT TERM

package_dir=$fixture_dir/node_modules/@fixture/conditional
mkdir -p "$package_dir/dist/features" "$package_dir/dist/internal"

cat >"$package_dir/package.json" <<'EOF'
{
  "name": "@fixture/conditional",
  "version": "1.2.3",
  "type": "module",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js",
      "require": "./dist/index.cjs"
    },
    "./server": {
      "types": "./dist/server.d.ts",
      "node": "./dist/server.js",
      "default": null
    },
    "./features/*": {
      "types": "./dist/features/*.d.ts",
      "default": "./dist/features/*.js"
    }
  }
}
EOF

cat >"$package_dir/dist/index.d.ts" <<'EOF'
export { Client, type ClientOptions } from "./client.js";
export * as utils from "./utils.js";
EOF
cat >"$package_dir/dist/client.d.ts" <<'EOF'
export interface ClientOptions { endpoint: string }
export declare class Client { constructor(options: ClientOptions); request(): Promise<void> }
EOF
cat >"$package_dir/dist/utils.d.ts" <<'EOF'
export declare function normalize(value: string): string;
EOF
cat >"$package_dir/dist/server.d.ts" <<'EOF'
export declare function serve(port: number): Promise<void>;
EOF
cat >"$package_dir/dist/features/alpha.d.ts" <<'EOF'
export declare const alpha: unique symbol;
EOF
cat >"$package_dir/dist/index.js" <<'EOF'
throw new Error("the inspector must not execute package code");
EOF
cat >"$package_dir/dist/index.cjs" <<'EOF'
throw new Error("the inspector must not execute package code");
EOF
cat >"$package_dir/dist/server.js" <<'EOF'
throw new Error("the inspector must not execute package code");
EOF
cat >"$package_dir/dist/features/alpha.js" <<'EOF'
throw new Error("the inspector must not execute package code");
EOF

legacy_dir=$fixture_dir/node_modules/legacy-runtime
mkdir -p "$legacy_dir"
cat >"$legacy_dir/package.json" <<'EOF'
{
  "name": "legacy-runtime",
  "version": "4.5.6",
  "main": "index.cjs"
}
EOF
cat >"$legacy_dir/index.cjs" <<'EOF'
exports.start = function start() {};
module.exports.stop = function stop() {};
EOF
cat >"$legacy_dir/helpers.d.ts" <<'EOF'
export declare function help(): void;
EOF

workspace_dir=$fixture_dir/workspace-safe
mkdir -p "$workspace_dir"
cat >"$workspace_dir/package.json" <<'EOF'
{
  "name": "workspace-safe",
  "version": "1.0.0",
  "types": "index.d.ts"
}
EOF
cat >"$workspace_dir/index.d.ts" <<'EOF'
export declare const workspaceLinked: true;
EOF
ln -s ../workspace-safe "$fixture_dir/node_modules/workspace-safe"

escape_dir=$fixture_dir/node_modules/escape-types
mkdir -p "$escape_dir"
cat >"$escape_dir/package.json" <<'EOF'
{
  "name": "escape-types",
  "version": "1.0.0",
  "types": "index.d.ts"
}
EOF
cat >"$fixture_dir/outside-package.d.ts" <<'EOF'
export declare const OUTSIDE_PACKAGE_CANARY: "must-not-be-read";
EOF
ln -s ../../outside-package.d.ts "$escape_dir/index.d.ts"

runtime_escape_dir=$fixture_dir/node_modules/escape-runtime
mkdir -p "$runtime_escape_dir"
cat >"$runtime_escape_dir/package.json" <<'EOF'
{
  "name": "escape-runtime",
  "version": "1.0.0",
  "main": "index.cjs"
}
EOF
cat >"$fixture_dir/outside-package.cjs" <<'EOF'
exports.OUTSIDE_RUNTIME_CANARY = "must-not-be-read";
EOF
ln -s ../../outside-package.cjs "$runtime_escape_dir/index.cjs"

oversize_dir=$fixture_dir/node_modules/oversize-types
mkdir -p "$oversize_dir"
cat >"$oversize_dir/package.json" <<'EOF'
{
  "name": "oversize-types",
  "version": "1.0.0",
  "types": "index.d.ts"
}
EOF
dd if=/dev/zero of="$oversize_dir/index.d.ts" bs=2000001 count=1 2>/dev/null

traversal_report=$fixture_dir/traversal.txt
if node "$inspector" ../escape-types --project "$fixture_dir" >"$traversal_report" 2>&1; then
  echo "path-like package specifier was accepted" >&2
  exit 1
fi
grep -q 'invalid package specifier' "$traversal_report"

escape_report=$fixture_dir/escape.txt
if node "$inspector" escape-types --project "$fixture_dir" >"$escape_report" 2>&1; then
  echo "declaration symlink outside the package root was read" >&2
  exit 1
fi
grep -q 'outside package root' "$escape_report"
if grep -q 'OUTSIDE_PACKAGE_CANARY' "$escape_report"; then
  echo "outside-package declaration content leaked into inspector output" >&2
  exit 1
fi

runtime_escape_report=$fixture_dir/runtime-escape.txt
if node "$inspector" escape-runtime --project "$fixture_dir" >"$runtime_escape_report" 2>&1; then
  echo "runtime symlink outside the package root was read" >&2
  exit 1
fi
grep -q 'outside package root' "$runtime_escape_report"
if grep -q 'OUTSIDE_RUNTIME_CANARY' "$runtime_escape_report"; then
  echo "outside-package runtime content leaked into inspector output" >&2
  exit 1
fi

oversize_report=$fixture_dir/oversize.txt
if node "$inspector" oversize-types --project "$fixture_dir" >"$oversize_report" 2>&1; then
  echo "oversized declaration file was accepted" >&2
  exit 1
fi
grep -q 'exceeds 2000000 bytes' "$oversize_report"

workspace_report=$fixture_dir/workspace.json
node "$inspector" workspace-safe --project "$fixture_dir" --json >"$workspace_report"
grep -q '"relative": "index.d.ts"' "$workspace_report"
grep -q '"workspaceLinked"' "$workspace_report"

root_report=$fixture_dir/root.json
node "$inspector" @fixture/conditional --project "$fixture_dir" --symbol Client --json >"$root_report"
grep -q '"version": "1.2.3"' "$root_report"
grep -q '"selectedKey": "."' "$root_report"
grep -q '"relative": "dist/client.d.ts"' "$root_report"
grep -q '"relative": "dist/utils.d.ts"' "$root_report"
grep -q '"text": "export declare class Client' "$root_report"

server_report=$fixture_dir/server.json
node "$inspector" @fixture/conditional/server --project "$fixture_dir" --json >"$server_report"
grep -q '"selectedKey": "./server"' "$server_report"
grep -q '"relative": "dist/server.d.ts"' "$server_report"

wildcard_report=$fixture_dir/wildcard.json
node "$inspector" @fixture/conditional/features/alpha --project "$fixture_dir" --json >"$wildcard_report"
grep -q '"wildcard": "alpha"' "$wildcard_report"
grep -q '"relative": "dist/features/alpha.d.ts"' "$wildcard_report"

blocked_report=$fixture_dir/blocked.json
node "$inspector" @fixture/conditional/internal --project "$fixture_dir" --json >"$blocked_report"
grep -q '"matched": false' "$blocked_report"
grep -q 'is not exposed by package.json exports' "$blocked_report"

legacy_report=$fixture_dir/legacy.json
node "$inspector" legacy-runtime --project "$fixture_dir" --json >"$legacy_report"
grep -q '"moduleType": "commonjs-default"' "$legacy_report"
grep -q '"start"' "$legacy_report"
grep -q '"stop"' "$legacy_report"

legacy_subpath_report=$fixture_dir/legacy-subpath.json
node "$inspector" legacy-runtime/helpers --project "$fixture_dir" --json >"$legacy_subpath_report"
grep -q '"relative": "helpers.d.ts"' "$legacy_subpath_report"

echo "Node package API inspector checks passed"
