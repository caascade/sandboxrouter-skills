#!/usr/bin/env bash
# A project whose build writes dist/app.js; the user has their own Daytona account connected.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
echo daytona > .sandboxrouter/accounts

cat > package.json <<'JSON'
{ "name": "app", "version": "1.0.0", "private": true, "scripts": { "build": "node build.js" } }
JSON
cat > build.js <<'JS'
const fs = require("node:fs");
fs.mkdirSync("dist", { recursive: true });
fs.writeFileSync("dist/app.js", "// built by build.js\nconsole.log('app');\n");
console.log("built dist/app.js");
JS
printf 'dist/\nnode_modules/\n.sandboxrouter/\n' > .gitignore
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm init
