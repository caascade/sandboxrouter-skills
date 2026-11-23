#!/usr/bin/env bash
# Copy a file or folder out of a sandbox: pack it with `exec`, download the archive with `files get`, unpack it here.
# Usage: pull.sh SANDBOX REMOTE_PATH [LOCAL_DIR]
#   SANDBOX      the sandbox's uid (u-…) or name
#   REMOTE_PATH  the file or folder in the sandbox, an absolute path
#   LOCAL_DIR    where it lands (default: the current folder); REMOTE_PATH's last part is created inside it
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 SANDBOX REMOTE_PATH [LOCAL_DIR]" >&2
  exit 2
fi

sandbox=$1
remote_path=${2%/}
local_dir=${3:-.}
case "$remote_path" in
  /?*) ;;
  *) echo "pull.sh: REMOTE_PATH must be an absolute path" >&2; exit 2 ;;
esac

archive=$(mktemp "${TMPDIR:-/tmp}/sandboxrouter-pull.XXXXXX")
trap 'rm -f "$archive"' EXIT
remote_archive="/tmp/sandboxrouter-pull-$$-$RANDOM.tgz"

# shellcheck disable=SC2016 # $1 and $2 expand in the sandbox's sh, not here.
# exec's status line goes to stderr, so this script's stdout is just the path.
sandboxrouter sandboxes exec "$sandbox" -- sh -c 'tar -czf "$1" -C "$(dirname "$2")" "$(basename "$2")"' sh "$remote_archive" "$remote_path" >&2
sandboxrouter sandboxes files get "$sandbox" "$remote_archive" > "$archive"
sandboxrouter sandboxes files delete "$sandbox" "$remote_archive" >/dev/null

mkdir -p "$local_dir"
tar -xzf "$archive" -C "$local_dir"

echo "${local_dir%/}/$(basename "$remote_path")"
