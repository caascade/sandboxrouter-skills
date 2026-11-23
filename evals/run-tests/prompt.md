---
description: Runs a Node test suite in a sandbox on the user's own E2B account, reports the one failing test, and cleans up.
tags: [loop]
expected_outcome: Creates a small labeled sandbox, copies the project in, runs npm test there, says subtract fails and add passes, deletes the sandbox.
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

Run my test suite in a sandbox, not on this machine, and tell me which tests fail.
