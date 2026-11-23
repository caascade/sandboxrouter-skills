#!/usr/bin/env bash
# Four sandboxes: two the agent made for the build, one it made for lint, and a teammate's named like a build one.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../fake-cli/setup.sh"
echo e2b > .sandboxrouter/accounts
sb() { # name uid labels-json
  printf '{"apiVersion":"sandboxrouter.io/v1","kind":"Sandbox","metadata":{"name":"%s","namespace":"acme","uid":"%s","labels":%s,"creationTimestamp":"2026-11-20T10:00:00Z"},"spec":{"resources":{"size":"s"},"connectors":[],"state":"Running"},"status":{"phase":"Running","provider":{"name":"e2b","id":"%s"}}}' "$1" "$2" "$3" "$2"
  mkdir -p ".sandboxrouter/sandboxes/$2/root/home/user"
}
{
  echo '['
  sb acme-build-1 u-b111111111111111111111111111111111111111 '{"created-by":"agent","task":"build"}'; echo ','
  sb acme-build-2 u-b222222222222222222222222222222222222222 '{"created-by":"agent","task":"build"}'; echo ','
  sb acme-build   u-a999999999999999999999999999999999999999 '{}'; echo ','
  sb acme-lint    u-c333333333333333333333333333333333333333 '{"created-by":"agent","task":"lint"}'
  echo ']'
} > .sandboxrouter/sandboxes.json
