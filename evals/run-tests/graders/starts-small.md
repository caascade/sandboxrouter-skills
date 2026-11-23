---
type: regex
weight: 0.5
pattern: '"sandboxes","(?:run|create)"[^\n]*"--size","(?:xs|s)"'
target: { source: file, path: .sandboxrouter/calls.log }
---
