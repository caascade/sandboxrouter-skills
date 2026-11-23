# Troubleshooting

Errors go to standard error as `sandboxrouter: <message>`. First look:

```sh
sandboxrouter sandboxes get <uid>     # phase, and why
sandboxrouter sandboxes logs <uid>    # each state it reached, and each provider Auto tried
```

## Exit codes

| Code | Meaning | What to do |
| --- | --- | --- |
| `0` | Success | — |
| `1` | The request or the command failed | Read the message, then `get` and `logs` |
| `2` | Invalid command line; nothing changed | Fix the flags (`sandboxrouter <command> --help`) |
| `3` | Key refused: revoked, wrong workspace or namespace, or missing access | See [setup.md](setup.md). Don't retry with another key |
| 1–125 from `exec`/`run` | The command's own exit code | Read its stderr |

## Common errors

| What you see | Cause | Fix |
| --- | --- | --- |
| Asks to name the workspace's namespace (exit `2`) | CLI not configured | [setup.md](setup.md) |
| `unauthorized` (exit `3`) | Wrong key or namespace | [setup.md](setup.md) |
| `not_running` | The sandbox stopped (idle stop or $0 balance) | `sandboxrouter sandboxes start <uid>`, then `get <uid> --wait-ms 60000` |
| `out_of_funds` (`402`) | No card on file, balance at $0, or spend cap reached | Tell the user: an owner adds funds in the console. Never add funds yourself |
| `provider_unavailable` (`503`), or the sandbox reads `Failed` | No provider in the order could run it | Read `logs <uid>` for each provider's own reason. Try a smaller size, or pin a provider the user has connected |
| A create refused before anything ran | A field, a provider that isn't connected, or a feature the pinned provider lacks | Read the message: it names what's missing |
| `sandboxes on your own image need size M or larger` | Own image on `xs`/`s` | `--size m` |
| `image tag not found` / `image must belong to this tenant` | Image not in this workspace's registry | Ask the user to push it |
| Command not found in the sandbox | The Default image is minimal | `apk add --no-cache <pkg>` (needs `dl-cdn.alpinelinux.org` if egress is limited) |
| `&&`, `|`, `>` or `*` don't work | `exec` runs without a shell | Wrap the command: `sh -c '…'` |
| Long `sh -c` fails | Each argument is at most 512 characters | Upload a script with `files put`, then run `sh /path/script.sh` |
| Network calls fail with `--egress` set | The host isn't in the list, or it's an IP address or `localhost` | `sandboxes update <uid> --egress HOST1 --egress HOST2 …` with every host, since it replaces the list. A list never allows IPs |
| Private clone fails | No GitHub connector on the sandbox, or its account isn't connected | Create a new sandbox with `--connector github`; ask an owner to connect it (see [files-and-code.md](files-and-code.md)) |
| `port` gives no URL | Native and Freestyle don't serve port URLs | Use an E2B or Daytona sandbox, if the user has one |
| The CLI couldn't reach the API mid-create or mid-exec | Network | Re-run with `--idempotency-key <the key in the error>` so nothing runs twice |

## Finding what you made

```sh
sandboxrouter sandboxes list --selector created-by=agent
sandboxrouter sandboxes list --selector created-by=agent,task=<slug>
sandboxrouter snapshots list --selector created-by=agent
```

Names aren't unique, so act on the uid (`u-…`) from these lists.
