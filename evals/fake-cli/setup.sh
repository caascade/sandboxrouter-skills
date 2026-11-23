# Sourced by each case's scaffold.sh, in the run's empty workspace: installs the stand-in CLI and puts it on PATH.
#
# A run's Bash sandbox can read only the workspace and system folders (not $HOME, /tmp or the per-user temp folder), so the
# stand-in lives in the workspace, at .sandboxrouter/bin, next to its state. The scaffold's $HOME is the run's temporary
# home, and the agent's shells read their startup files from it, so those put the stand-in first on PATH by absolute path:
# `sandboxrouter` then resolves from any folder, and so it does inside the skill's push.sh and pull.sh.
set -euo pipefail
_sr_state="$PWD/.sandboxrouter"
mkdir -p "$_sr_state/bin"
cp "$(dirname "${BASH_SOURCE[0]}")/sandboxrouter" "$_sr_state/bin/sandboxrouter"
chmod +x "$_sr_state/bin/sandboxrouter"
touch "$_sr_state/calls.log"
cp -R "$(dirname "${BASH_SOURCE[0]}")/sandbox-bin" "$_sr_state/sandbox-bin"   # PATH for commands run in a sandbox
chmod +x "$_sr_state/sandbox-bin/"*
for rc in .zshenv .bashrc .bash_profile .profile; do
  printf 'export PATH="%s/bin:$PATH"\n' "$_sr_state" >> "$HOME/$rc"
done

# On macOS, /usr/bin/git and /usr/bin/make are Xcode shims that write a cache file the sandbox refuses, and the real
# binaries under /Applications are unreadable there too. Copy the real ones into the workspace (git with its helpers, about
# 12 MB). Elsewhere xcrun doesn't exist and this does nothing.
if git_bin=$(xcrun -f git 2>/dev/null); then
  git_root=$(dirname "$(dirname "$git_bin")")
  mkdir -p "$_sr_state/tools/bin" "$_sr_state/tools/libexec"
  cp "$git_bin" "$_sr_state/tools/bin/git"
  cp -R "$git_root/libexec/git-core" "$_sr_state/tools/libexec/"   # its links are relative (../../bin/git)
  mkdir -p "$_sr_state/tools/share/git-core/templates"   # empty: copying the sample hooks is refused in the sandbox
  make_bin=$(xcrun -f make 2>/dev/null) && cp "$make_bin" "$_sr_state/tools/bin/make"
  for rc in .zshenv .bashrc .bash_profile .profile; do
    printf 'export PATH="%s/tools/bin:$PATH" GIT_EXEC_PATH="%s/tools/libexec/git-core"\n' "$_sr_state" "$_sr_state" >> "$HOME/$rc"
  done
fi
