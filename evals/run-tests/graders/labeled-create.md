---
type: regex
pattern: '"sandboxes","(?:run|create)"[^\n]*"created-by=agent"'
target: { source: file, path: .sandboxrouter/calls.log }
---
