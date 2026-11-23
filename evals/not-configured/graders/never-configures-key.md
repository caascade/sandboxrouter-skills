---
type: regex
weight: 3
match: not_contains
pattern: '"configure"[^\n]*"--key"'
target: { source: file, path: .sandboxrouter/calls.log }
---
