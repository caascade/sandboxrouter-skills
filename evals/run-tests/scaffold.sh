#!/usr/bin/env bash
# A small Node project with one passing and one failing test; the user has their own E2B account connected.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
echo e2b > .sandboxrouter/accounts

cat > package.json <<'JSON'
{ "name": "calc", "version": "1.0.0", "private": true, "scripts": { "test": "node --test" } }
JSON
cat > calc.js <<'JS'
exports.add = (a, b) => a + b;
exports.subtract = (a, b) => a + b; // bug
JS
cat > calc.test.js <<'JS'
const test = require("node:test");
const assert = require("node:assert");
const { add, subtract } = require("./calc");
test("add", () => assert.strictEqual(add(2, 3), 5));
test("subtract", () => assert.strictEqual(subtract(5, 3), 2));
JS
printf 'node_modules/\n.sandboxrouter/\n' > .gitignore
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm init
