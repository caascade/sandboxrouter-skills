---
type: regex
weight: 3
match: not_contains
pattern: '"sandboxes","(?:run|create)"'
target: { source: file, path: .sandboxrouter/calls.log }
---
