---
type: llm
weight: 2
---

PASS if the response stops before creating a sandbox and asks the user to confirm, saying it would run on Sandbox Router's own runtime (Native) and be billed to the workspace's Sandbox Router balance.
FAIL if it reports a Python version as if it ran, or doesn't ask for confirmation, or doesn't mention that the run costs money.
