# Providers, sizes and cost

## Where a sandbox runs

| Provider | `--provider` | Account | Who bills the compute |
| --- | --- | --- | --- |
| Native | `cloudflare` | Sandbox Router's own | Sandbox Router, from the workspace balance |
| Daytona, E2B, Freestyle, Maritime | `daytona`, `e2b`, `freestyle`, `maritime` | The user's own, once an owner connects its key | That provider, directly |

Whatever the provider, a sandbox starts only while the workspace has a **card on file and a balance above $0**. If the balance hits $0, every running sandbox stops.

## Auto or pinned

- **Pinned:** `--provider PROVIDER` or `--account ACCOUNT` (one of the user's own accounts, by name). The sandbox runs there or nowhere, with no failover.
- **Auto:** without either flag, the workspace's Auto order places it. The default order is `maritime, daytona, freestyle, e2b, cloudflare`: the user's own accounts first, then Native. Auto skips any provider whose key isn't connected or that can't run what the sandbox asks for (its size, image, outbound access or connectors), and fails over to the next one if a create fails. Once a sandbox runs, it never moves.
- **Under Auto, a sandbox with a list of outbound hosts (`--egress HOST`) or with any `--connector` goes only to Native.**

## Will this create land on Native? Ask first if so

```sh
sandboxrouter provider-configs list     # the user's own accounts, and whether each key is Ready
sandboxrouter providers list            # every provider, and its place in the Auto order
```

It lands on Native when the user has no Ready account of their own, when you pass `--provider cloudflare`, or when you use `--egress HOST` or `--connector` without pinning another provider. Ask once per task, for example: "This will run on Native, billed to your Sandbox Router balance. OK?"

To use one of the user's own accounts, an owner connects it in their own terminal (the key is read from a file, never typed as an option):

```sh
sandboxrouter provider-configs connect e2b --api-key < e2b-key.txt
```

Don't run this yourself: it handles the user's provider key.

## Sizes

`--size` sets vCPU, memory and disk. The default is `m`, but start with `s` unless the task needs more.

| `--size` | vCPU | Memory | Disk |
| --- | --- | --- | --- |
| `xs` | 1/16 | 256 MiB | 2 GB |
| `s` | 1/4 | 1 GiB | 4 GB |
| `m` | 1/2 | 4 GiB | 8 GB |
| `l` | 1 | 6 GiB | 12 GB |
| `xl` | 2 | 8 GiB | 16 GB |
| `2xl` | 4 | 12 GiB | 20 GB |

- A sandbox on the user's own image needs `m` or larger.
- By default a provider gives its smallest shape that covers the size. `--size-match exact` accepts only an exact match.
- Rates are on https://sandboxrouter.io/pricing. A stopped sandbox bills no CPU, memory or disk.

## What stops cost

- **Idle stop:** a sandbox stops after 15 minutes with no command, file transfer or snapshot in flight. `--idle-stop MINUTES` sets 5 to 240. A stopped sandbox still exists until it's deleted.
- **Delete** when you're done: `sandboxrouter sandboxes delete <uid>`.
- Never run `sandboxrouter billing add-funds` or change auto-recharge. If a create fails with `out_of_funds`, tell the user an owner needs to add funds in the console.
