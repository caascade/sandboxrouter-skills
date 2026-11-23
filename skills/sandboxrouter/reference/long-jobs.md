# Long jobs and ports

## Wait, or detach

Plain `exec` waits until the command ends, prints its output, and exits with the command's exit code. That's fine for anything that ends in a few minutes. For longer work, detach and poll:

```sh
sandboxrouter sandboxes exec <uid> --detach --timeout 3600 -- sh -c 'npm run build > /tmp/build.log 2>&1'
# prints the exec ID
sandboxrouter sandboxes exec <uid> <exec-id> --wait-ms 60000    # waits up to a minute; prints state, exit code and output
sandboxrouter sandboxes exec <uid> -- tail -n 30 /tmp/build.log # progress so far
sandboxrouter sandboxes exec <uid> <exec-id> --cancel           # stop it
sandboxrouter sandboxes execs <uid>                             # every command that has run
```

- `--timeout SECONDS` is 1 to 7200, or up to 86400 with `--detach`. Without it, the command has no time limit, so set one for anything that could hang.
- Send the output to a log file in the sandbox and read the tail. Don't pull the whole log into the conversation.
- Use `--json` when a script needs to read the state: it prints the exec object with `state`, `exitCode`, `stdout` and `stderr`.

## Idle stop during long jobs

A command in flight keeps the sandbox running. Once it ends, the 15-minute idle stop starts counting again. If the user will come back later, raise it at create (`--idle-stop 60`) or change it later:

```sh
sandboxrouter sandboxes update <uid> --idle-stop 60
```

A stopped sandbox keeps what its provider keeps across a stop. Start it with `sandboxrouter sandboxes start <uid>`, then `sandboxrouter sandboxes get <uid> --wait-ms 60000`.

## Retrying without running twice

`exec`, `run` and `create` send an idempotency key. If the CLI can't reach the API, the error names the key. Run the same command again with `--idempotency-key KEY` and the command won't run twice.

## Port URLs

To reach a server the sandbox runs, start it detached, then ask for the URL:

```sh
sandboxrouter sandboxes exec <uid> --detach -- sh -c 'npm start > /tmp/server.log 2>&1'
sandboxrouter sandboxes port <uid> 3000
```

- The URL is the provider's own. E2B and Daytona give one per port; Native and Freestyle give none, and the command says so.
- The output names headers a request must carry: the provider's authorization for the port. `--json` prints their values, so **treat that output as a secret**. Don't paste it into the conversation, a commit or a log.
- Requests to the URL go straight to the provider, so they don't count toward keeping the sandbox awake.
