# Files and code

## What the files commands do

- `files put SANDBOX PATH [FILE]` writes one whole file (from standard input when `FILE` is missing or `-`). Any size.
- `files get SANDBOX PATH` prints one file's bytes to standard output, so redirect it to a file.
- `files delete SANDBOX PATH` deletes one file.
- `PATH` is absolute, not under `/proc`, `/sys` or `/dev`. There is no directory listing and no folder upload: list with `exec <uid> -- ls -la DIR`, and move folders with the scripts below.
- The sandbox has to be running. A stopped one answers `not_running`.

## Copy a folder in: `scripts/push.sh`

```sh
scripts/push.sh <uid> .                  # → <sandbox working dir>/<folder name>; prints the path
scripts/push.sh <uid> ./app /tmp/app     # → a path you choose
```

It packs the folder with `tar`, uploads the archive with `files put`, and unpacks it with `exec`, so the sandbox needs `sh` and `tar` (the Default image has both). In a git repo, it copies tracked files plus untracked files that aren't ignored. Its only standard output is the remote path.

Don't hardcode `/workspace`: the working directory depends on the provider and image (on E2B it's `/home/user`, on Daytona `/home/daytona`). Let push.sh pick it, or read it yourself:

```sh
sandboxrouter sandboxes exec <uid> --json -- pwd     # the "stdout" field
```

## Copy files out: `scripts/pull.sh`

```sh
scripts/pull.sh <uid> /tmp/app/coverage ./out      # creates ./out/coverage; prints the path
sandboxrouter sandboxes files get <uid> /tmp/app/report.json > report.json   # one file
```

## Clone instead of copying

For a public repo, run `git` in the sandbox. The Default image is Alpine, so install `git` with `apk` if it's missing:

```sh
sandboxrouter sandboxes exec <uid> -- sh -c 'command -v git || apk add --no-cache git; git clone --depth 1 https://github.com/OWNER/REPO /tmp/repo'
```

For a **private GitHub repo**, use the GitHub connector: Sandbox Router adds the user's GitHub credentials to the sandbox's HTTPS requests as they leave, so the token never enters the sandbox.

```sh
sandboxrouter connectors list            # is "github" there, with its account connected?
sandboxrouter sandboxes run --size s --connector github --label created-by=agent --label task=<slug> --json
sandboxrouter sandboxes exec <uid> -- sh -c 'command -v git || apk add --no-cache git; git clone https://github.com/OWNER/REPO /tmp/repo'
```

- Connectors are chosen at create and can't be added later.
- Only an owner can add the connector or connect its account (`sandboxrouter connectors add github`, then `sandboxrouter connectors account github --sign-in`, which finishes in the browser). If it's missing, ask the user. If the user isn't an owner, copy the code in with push.sh instead.
- Use `https://` URLs. Credentials are added only to HTTPS, and plain `http://` is refused.
- Tools that refuse to start without a token: set `--env GH_TOKEN=sandboxrouter-egress-placeholder-key`. The real token replaces it on the way out.
- **Under Auto, a sandbox with a connector runs on Native** (paid). See [providers.md](providers.md).

## Outbound access

Without `--egress`, a sandbox can reach every host. `--egress HOST` (repeatable, up to 32) allows only the hosts listed, over HTTP and HTTPS: list everything it needs, such as `registry.npmjs.org` for npm, `dl-cdn.alpinelinux.org` for `apk`, and `github.com` for git. `--no-egress` blocks everything. Under Auto, a list sends the sandbox to Native.

`sandboxes update <uid> --egress HOST …` **replaces** the whole list, so pass every host again. A sandbox created with every host open can't be narrowed much later, and one created with a list can't be fully opened, so choose at create.

## Command line limits

A command is up to 32 arguments of up to 512 characters each, so a long `sh -c '…'` script fails. For a longer script, write it to a file, upload it, and run that:

```sh
sandboxrouter sandboxes files put <uid> /tmp/task.sh ./task.sh
sandboxrouter sandboxes exec <uid> -- sh /tmp/task.sh
```

`--stdin` sends up to 64 KiB of standard input to a command.
