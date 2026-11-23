#!/usr/bin/env bash
# The workspace has the GitHub connector and an E2B account; github.com/acme/api is reachable only through the connector.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
echo e2b > .sandboxrouter/accounts
echo github > .sandboxrouter/connectors

# A plain tree: the stand-in's git clone copies it (a real clone can't write .git/config in the eval's sandbox).
repo=.sandboxrouter/repos/acme/api
mkdir -p "$repo"
printf 'migrate:\n\t@echo "applied 3 migrations"\n' > "$repo/Makefile"
echo '# acme api' > "$repo/README.md"
