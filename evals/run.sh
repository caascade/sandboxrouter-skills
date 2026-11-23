#!/usr/bin/env bash
# Run the eval suite against the stand-in sandboxrouter CLI. Extra arguments go to `claude plugin eval`, e.g.
#   evals/run.sh --case run-tests --runs 1 --ablation none
set -euo pipefail
cd "$(dirname "$0")/.."
# --scaffold: each case's scaffold.sh installs the stand-in CLI (evals/fake-cli) in the workspace and writes the scenario.
# Bash: the skill drives the CLI through the shell. It runs in the OS sandbox with no network, and the only sandboxrouter
# on its PATH is the stand-in. Agent is removed so the work can't be handed to a subagent or a remote session.
exec claude plugin eval . --scaffold --allow-tools Bash --disallow-tools Agent "$@"
