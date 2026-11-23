---
description: Sandboxes from several owners and tasks exist, with look-alike names. The agent must delete only its own build sandboxes, found by label.
tags: [rules, cleanup]
expected_outcome: Lists by selector created-by=agent,task=build, deletes the two matching uids, leaves the teammate's acme-build and the agent's lint sandbox.
max_turns: 25
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill]
---

Clean up the Sandbox Router sandboxes you made earlier for the build. Leave everything else alone.
