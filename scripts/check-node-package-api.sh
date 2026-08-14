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
