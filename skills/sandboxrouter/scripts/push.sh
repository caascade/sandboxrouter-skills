#!/usr/bin/env bash
# Copy a local folder into a sandbox: pack it, upload the archive with `files put`, unpack it with `exec`.
# Usage: push.sh SANDBOX LOCAL_DIR [REMOTE_DIR]
#   SANDBOX     the sandbox's uid (u-…) or name
#   LOCAL_DIR   the folder to copy
#   REMOTE_DIR  where it lands, an absolute path; default: the sandbox's working directory + the folder's name
# In a git repository, copies the tracked files and the untracked ones git doesn't ignore.
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 SANDBOX LOCAL_DIR [REMOTE_DIR]" >&2
  exit 2
fi

sandbox=$1
local_dir=$2
[ -d "$local_dir" ] || { echo "push.sh: $local_dir is not a folder" >&2; exit 2; }
local_dir=$(cd "$local_dir" && pwd)

if [ "$#" -eq 3 ]; then
  remote_dir=$3
else
  # exec's text output starts with an "Exec <id>: <state>" line, so read the command's stdout from --json (Node is the CLI's own runtime).
  # Captured first, so a failed exec stops the script here with the CLI's own error.
  exec_json=$(sandboxrouter sandboxes exec "$sandbox" --json -- pwd)
  workdir=$(printf '%s' "$exec_json" | node -e 'let s = ""; process.stdin.on("data", (d) => (s += d)).on("end", () => process.stdout.write(JSON.parse(s).stdout.trim()))')
  remote_dir="${workdir%/}/$(basename "$local_dir")"
fi
case "$remote_dir" in
  /*) ;;
  *) echo "push.sh: REMOTE_DIR must be an absolute path" >&2; exit 2 ;;
esac

archive=$(mktemp "${TMPDIR:-/tmp}/sandboxrouter-push.XXXXXX")
trap 'rm -f "$archive"' EXIT
remote_archive="/tmp/sandboxrouter-push-$$-$RANDOM.tgz"

# macOS's bsdtar stores ._ files (COPYFILE_DISABLE) and extended attributes (--no-xattrs, --no-mac-metadata) that the sandbox's
# tar warns about on every file. GNU tar stores neither by default and doesn't take those flags.
tar_flags=()
if tar --version 2>/dev/null | grep -q bsdtar; then tar_flags=(--no-xattrs --no-mac-metadata); fi
if git -C "$local_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  (cd "$local_dir" && git ls-files -z --cached --others --exclude-standard \
    | COPYFILE_DISABLE=1 tar "${tar_flags[@]}" --null -T - -czf "$archive")
else
  COPYFILE_DISABLE=1 tar "${tar_flags[@]}" -czf "$archive" -C "$local_dir" .
fi

sandboxrouter sandboxes files put "$sandbox" "$remote_archive" "$archive" >/dev/null
# shellcheck disable=SC2016 # $1 and $2 expand in the sandbox's sh, not here.
# exec's status line goes to stderr, so this script's stdout is just the path.
sandboxrouter sandboxes exec "$sandbox" -- sh -c 'mkdir -p "$1" && tar -xzf "$2" -C "$1" && rm -f "$2"' sh "$remote_dir" "$remote_archive" >&2

echo "$remote_dir"
