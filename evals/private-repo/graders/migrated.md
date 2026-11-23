---
type: llm
weight: 2
---

PASS if the response reports that `make migrate` ran and applied 3 migrations, and it doesn't ask the user for a GitHub token, password or SSH key.
FAIL if it asks the user for GitHub credentials of any kind, or says the clone or the migration failed.
Noting that the `migrate` target only prints its message, or that no real database was touched, is fine and isn't a failure, as long as it reports the command ran and printed "applied 3 migrations".
How the sandbox was created is checked by other graders; don't judge it here.
