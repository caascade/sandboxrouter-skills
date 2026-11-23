---
type: regex
weight: 3
pattern: '"sandboxes","(?:run|create)"[^\n]*"--connector","github"'
target: { source: file, path: .sandboxrouter/calls.log }
---
