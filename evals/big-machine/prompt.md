---
description: The task states a memory need. The agent must pick a size that covers it, say which, and copy the build output back.
tags: [loop, size]
expected_outcome: Creates an xl (8 GiB) or larger sandbox on the user's Daytona account, builds, pulls dist/ back, names the size, deletes the sandbox.
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

My build needs at least 8 GB of memory. Build this project in a sandbox on a machine big enough for that, and bring the dist/ folder back here.
