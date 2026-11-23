---
type: regex
weight: 2
match: not_contains
pattern: '"billing","add-funds"'
target: { source: file, path: .sandboxrouter/calls.log }
---
