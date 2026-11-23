---
name: sandboxrouter
description: Run code in cloud sandboxes with the Sandbox Router CLI (`sandboxrouter`). Use when the user wants to run tests, builds, installs or long jobs somewhere other than their own machine, asks for a sandbox, or mentions Sandbox Router or sandboxrouter.io. Covers setup, creating sandboxes, copying code in and results out, running commands, and cleaning up.
---

# Sandbox Router

Sandbox Router gives you isolated cloud machines (sandboxes) on whichever provider fits: Sandbox Router's own runtime (Native) or the user's own E2B, Daytona, Freestyle or Maritime account. You drive it with the `sandboxrouter` CLI. Every command acts in the workspace of the saved API key.

## Before anything: is the CLI set up?

Run `sandboxrouter sandboxes list`.

| Result | Meaning | Do |
| --- | --- | --- |
| A list (maybe empty) | Ready | Go on |
| `command not found` | Not installed | `npm i -g @sandboxrouterio/cli` (needs Node 22+) |
| Exit `2`, "name the workspace's namespace" | Not configured | Follow [reference/setup.md](reference/setup.md) |
| Exit `3`, "unauthorized" | Wrong key or namespace | Follow [reference/setup.md](reference/setup.md) |

## Rules

1. **Never handle the API key.** Keys start with `ck_`. Don't ask the user to paste one into the chat, and don't run `sandboxrouter configure --key` yourself. Ask the user to run it in their own terminal ([reference/setup.md](reference/setup.md)).
2. **Never spend the user's money without asking.** Sandboxes on Native are paid from the workspace balance. Never run `sandboxrouter billing add-funds`, and ask before a create that will land on Native (see [reference/providers.md](reference/providers.md)).
3. **Label every sandbox you create** with `--label created-by=agent --label task=<short-slug>`, and keep its **uid** (`u-…`). Names are not unique, so act on uids.
4. **Delete only what you created.** Find it by your labels, never by guessing from names.
5. **Start small.** Use `--size s` unless the task needs more, and say which size you picked.
6. **Keep large output out of the conversation.** Write long output to a file in the sandbox and read only what you need.
7. **Clean up.** When the task is done, delete the sandbox, or tell the user what is still running and why.

## The loop

### 1. Create

```sh
sandboxrouter sandboxes run --size s --label created-by=agent --label task=run-tests --json
```

`run` returns once the sandbox is running (or failed, exit `1`). Read `metadata.uid` from the JSON and use it from then on. Add `--provider cloudflare` (Native) or `--account e2b` (the user's own account) to pin where it runs; without either, the workspace's Auto order places it.

### 2. Copy code in

`files put` writes one file. To copy a folder, use the script next to this file:

```sh
scripts/push.sh <uid> .                 # the current folder → <sandbox's working dir>/<folder name>
scripts/push.sh <uid> ./app /tmp/app    # or to a path you choose
```

In a git repo it copies what git tracks plus untracked files that aren't ignored, so `node_modules` and `.env` stay behind unless they are committed. To clone instead of copying, see [reference/files-and-code.md](reference/files-and-code.md).

### 3. Run commands

```sh
sandboxrouter sandboxes exec <uid> --workdir <dir> -- sh -c 'npm ci && npm test > /tmp/test.log 2>&1; echo "exit $?"'
sandboxrouter sandboxes exec <uid> -- tail -n 50 /tmp/test.log
```

- Commands run **without a shell**. For `&&`, pipes, `>` or globs, wrap them in `sh -c '…'`.
- `exec` exits with the command's own exit code.
- For anything that may take minutes, use `--detach` and poll: see [reference/long-jobs.md](reference/long-jobs.md).

### 4. Copy results out

```sh
sandboxrouter sandboxes files get <uid> /tmp/test.log > test.log      # one file
scripts/pull.sh <uid> <remote dir>/coverage ./out                     # a folder → ./out/coverage
```

### 5. Clean up

```sh
sandboxrouter sandboxes delete <uid>
```

To find what you made earlier: `sandboxrouter sandboxes list --selector created-by=agent,task=run-tests`.

A sandbox **stops** after 15 minutes with no command, file transfer or snapshot in flight (requests to its port URLs don't count) (`--idle-stop` sets 5 to 240), but a stopped sandbox still exists until it is deleted. Snapshots stay even after their sandbox is deleted.

## When something goes wrong

- `sandboxrouter sandboxes get <uid>` shows the phase and why.
- `sandboxrouter sandboxes logs <uid>` shows each state it reached, including each provider Auto tried.
- `not_running`: the sandbox stopped. `sandboxrouter sandboxes start <uid>`, then `get <uid> --wait-ms 60000`.
- More: [reference/troubleshooting.md](reference/troubleshooting.md).

## Exit codes

`0` success · `1` the request or command failed · `2` invalid command line, nothing changed · `3` the key was refused. `run` and `exec` pass through the command's own exit code from 1 to 125.

## More

- [reference/setup.md](reference/setup.md): install, API key, namespace, first check
- [reference/providers.md](reference/providers.md): Native or the user's own account, the Auto order, sizes, cost
- [reference/files-and-code.md](reference/files-and-code.md): copying repos, cloning, private repos
- [reference/long-jobs.md](reference/long-jobs.md): detached commands, timeouts, port URLs
- [reference/snapshots-images.md](reference/snapshots-images.md): saving and restoring, your own images
- [reference/troubleshooting.md](reference/troubleshooting.md): errors and what to do
- Full CLI reference: `sandboxrouter help`, or https://sandboxrouter.io/docs/cli
