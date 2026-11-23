#!/usr/bin/env bash
# Configured, but no provider account of the user's own: Auto places every sandbox on Native, which is paid.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
touch .sandboxrouter/accounts
