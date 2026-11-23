# Snapshots and images

## Snapshots: save a set-up sandbox and restore it

Useful after a slow setup (dependencies installed, repo built), so the next task starts from there.

```sh
sandboxrouter snapshots create <uid> --name <slug>-ready --label created-by=agent --label task=<slug>
sandboxrouter snapshots get <slug>-ready          # Pending, then Ready
sandboxrouter sandboxes run --snapshot <slug>-ready --label created-by=agent --label task=<slug> --json
sandboxrouter snapshots delete <slug>-ready
```

- Take it of a **running** sandbox. Restore only once it's `Ready`.
- A restore runs on the snapshot's own provider and account, whatever `--provider` says, at the snapshot's size unless you pass `--size`.
- **Snapshots outlive their sandbox.** Deleting the sandbox doesn't delete them. List yours with `sandboxrouter snapshots list --selector created-by=agent` and delete the ones you no longer need, or tell the user they're there.
- What's kept depends on the provider: Native and Daytona keep the disk; E2B and Freestyle can keep memory and processes too (`--no-memory` for disk alone); Maritime takes none. A provider without snapshots refuses the create.
- Native's snapshots expire 30 days after their last use.

## Images

Without `--image`, a sandbox runs the **Default image**: Alpine Linux with bash, coreutils, Node and Docker. It has none of the project's dependencies: install them with `apk add --no-cache …` or `npm ci` (with `--egress`, allow `dl-cdn.alpinelinux.org`).

To run the user's own image:

```sh
sandboxrouter sandboxes run --image registry.caas.sh/<name>:<tag> --size m --label created-by=agent --label task=<slug> --json
```

- The image has to be in the workspace's own registry (`registry.caas.sh/<tenant-id>/…`), for `linux/amd64`. Others are refused.
- It needs size `m` or larger.
- Pushing an image (`sandboxrouter registry login`, then `docker build --platform linux/amd64 …` and `docker push`) puts the key into Docker's credential store. Leave this to the user unless they ask for it.

**Images of the namespace** give an image a name for sandboxes to boot (`--image-name NAME`). They're made from a registry image, a provider's own artifact, or a Dockerfile:

```sh
sandboxrouter images list
sandboxrouter images get <name>          # where each provider can boot it
sandboxrouter sandboxes run --image-name <name> --label created-by=agent --label task=<slug> --json
```

A Dockerfile image is built and runs on the user's Daytona account only. An image made from a provider's artifact runs only on that provider.

**Maritime** boots only its own templates or public images pinned by digest, so the Default image and registry images never go there.
