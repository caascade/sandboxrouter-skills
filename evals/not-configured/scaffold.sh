#!/usr/bin/env bash
# The CLI is installed but nothing is saved: every command but configure and help exits 2.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
touch .sandboxrouter/unconfigured
