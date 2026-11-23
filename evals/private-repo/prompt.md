---
description: Clone a private GitHub repo in a sandbox. The agent must use the GitHub connector, never ask for or set a token, and may bill Native because the user said so.
tags: [loop, connectors]
expected_outcome: Checks connectors, creates with --connector github and labels, clones over https, runs make migrate, reports "applied 3 migrations", deletes the sandbox.
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

Clone our private repo https://github.com/acme/api into a sandbox and run `make migrate` there. It's fine to bill this to our Sandbox Router balance.
