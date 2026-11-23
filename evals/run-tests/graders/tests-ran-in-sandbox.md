---
type: regex
weight: 2
pattern: '"sandboxes","exec"[^\n]*(?:npm[^\n]*test|node --test)'
target: { source: file, path: .sandboxrouter/calls.log }
---
