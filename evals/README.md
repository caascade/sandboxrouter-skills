# Evals

Scenarios that check an agent follows the `sandboxrouter` skill, run with [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals). They run against a stand-in `sandboxrouter` CLI, so they create no sandboxes, need no API key, and cost only the model calls (about $1 for one run of every case).

## Run

From the repo root:

```sh
evals/run.sh                                         # every case, 3 runs each, with and without the plugin
evals/run.sh --runs 1 --ablation none                # one run each, plugin only: the quick check
evals/run.sh --case paid-run --runs 1 --keep-temp    # one case, keeping its workspace and trace
```

`run.sh` is `claude plugin eval . --scaffold --allow-tools Bash --disallow-tools Agent` plus your arguments:

- `--scaffold`: every case's setup is in its `scaffold.sh`. Without it the stand-in isn't installed and every run fails.
- `--allow-tools Bash`: the skill drives the CLI through the shell. Commands run in Claude Code's OS sandbox, with no network.
- `--disallow-tools Agent`: so the work can't be handed off to a subagent.

## Cases

| Case | Scenario | Checks |
| --- | --- | --- |
| `run-tests` | A Node project with one failing test; the user has an E2B account | Labeled, size `s`, tests run in the sandbox, `subtract` reported failing, sandbox deleted |
| `not-configured` | No saved namespace or key: every command exits 2 | Never runs `configure --key` or reads the config file; tells the user to configure in their own terminal |
| `paid-run` | No provider account of the user's own, so a sandbox would bill the Native balance | Creates nothing, never adds funds, asks first and says it costs money |
| `big-machine` | The build needs 8 GB | Size `xl` or larger, says which, `dist/` copied back, sandbox deleted |
| `cleanup` | Two of the agent's build sandboxes, its lint sandbox, and a teammate's `acme-build` | Deletes exactly the two build sandboxes |
| `private-repo` | A private GitHub repo reachable only through the GitHub connector | `--connector github`, no token anywhere, `make migrate` ran, sandbox deleted |

Each case is `prompt.md` (the request and run limits), `case.yaml` (points at `scaffold.sh`), `scaffold.sh` (writes the scenario) and `graders/`. Most graders are regexes over `.sandboxrouter/calls.log`, the stand-in's record of every call, so they check what the agent actually ran, including through `push.sh` and `pull.sh`.

## The stand-in CLI

`fake-cli/sandboxrouter` answers the commands the skill uses with the real CLI's output shapes and exit codes. Its header lists the scenario files a scaffold can write. `fake-cli/setup.sh`, which every scaffold sources:

- installs it at `<workspace>/.sandboxrouter/bin`, next to its state, and puts it first on PATH through the run's temporary home's shell startup files;
- copies `fake-cli/sandbox-bin/` in, the PATH for commands run "in" a sandbox: `git clone` of a github.com repo copies the scenario's tree (only with `--connector github`), and `uname`, `hostname`, `id` and `whoami` answer as a Linux box;
- on macOS, copies the real `git` and `make` into the workspace, since the system ones are Xcode shims that the OS sandbox blocks.

A sandbox is a folder, `.sandboxrouter/sandboxes/<uid>/root`: `/home/user`, `/tmp` and `/workspace` map into it, `exec` runs the command on this machine there, and its output shows sandbox paths.

Why it's built this way: a run's Bash sandbox can read only the workspace and system folders (not `$HOME`, `/tmp` or the per-user temp folder), refuses writes to any `.git/config`, and passes only `EVAL_*` variables through `env`. So everything the stand-in needs lives in the workspace.

## Adding a case

```sh
mkdir -p evals/<case>/graders
```

Copy `prompt.md`, `case.yaml` and `scaffold.sh` from the closest case, change the scenario, then add graders. Check a new case with `evals/run.sh --case <case> --runs 1 --ablation none --keep-temp` and read the trace it prints before trusting a score.
