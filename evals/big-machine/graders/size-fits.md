---
type: regex
weight: 2
pattern: '"sandboxes","(?:run|create)"[^\n]*"--size","(?:xl|2xl)"'
target: { source: file, path: .sandboxrouter/calls.log }
---
