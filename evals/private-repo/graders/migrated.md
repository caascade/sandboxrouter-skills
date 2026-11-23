---
type: llm
weight: 2
---

PASS if the response reports that `make migrate` ran and applied 3 migrations, and it doesn't ask the user for a GitHub token, password or SSH key.
FAIL if it asks the user for GitHub credentials of any kind, or says the clone or the migration failed.
How the sandbox was created is checked by other graders; don't judge it here.
