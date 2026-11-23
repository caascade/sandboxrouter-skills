# Sandbox Router skills

[Agent Skills](https://agentskills.io) that let your coding agent run code in [Sandbox Router](https://sandboxrouter.io) cloud sandboxes with the `sandboxrouter` CLI.

| Skill | What it does |
| --- | --- |
| [`sandboxrouter`](skills/sandboxrouter/SKILL.md) | Checks the CLI is set up, creates a sandbox, copies your code in, runs tests, builds or long jobs, copies results out, and cleans up |

The skill follows a few rules on your behalf: it never asks for or handles your API key, it asks before running a sandbox that bills your Sandbox Router balance, it labels every sandbox it creates and deletes only those, and it cleans up when it's done.

## Before you start

Install the CLI and connect it to your workspace. Run this yourself, in your own terminal: the skill never handles your key.

```sh
npm i -g @sandboxrouterio/cli          # needs Node 22+
sandboxrouter configure --tenant <tenant-id> --key <api-key> --namespace <namespace>
sandboxrouter sandboxes list           # check it works
```

Your tenant ID and namespace are in the [console](https://console.sandboxrouter.io/) under **Settings** → **Workspace**, and you create the key under **Settings** → **API keys**. See [The CLI](https://sandboxrouter.io/docs/cli).

## Install the skill

### Claude Code

```text
/plugin marketplace add caascade/sandboxrouter-skills
/plugin install sandboxrouter@sandboxrouter
```

### Codex

```sh
git clone --depth 1 https://github.com/caascade/sandboxrouter-skills /tmp/sandboxrouter-skills
mkdir -p ~/.codex/skills && cp -R /tmp/sandboxrouter-skills/skills/sandboxrouter ~/.codex/skills/
```

### Any other agent

Copy `skills/sandboxrouter/` to wherever your agent reads skills from. The folder is self-contained.

## Use it

Ask your agent in plain words, for example:

- "Run my test suite in a sandbox."
- "Build this on a bigger machine and give me the artifacts."
- "Clone our private repo into a sandbox and run the migrations there."

## Repository layout

```
.claude-plugin/marketplace.json   Claude Code plugin marketplace
.claude-plugin/plugin.json        the plugin (its skills are under skills/)
skills/<name>/                    one folder per skill: SKILL.md, reference/, scripts/
evals/                            test cases for the skills (not installed)
```

## Evals

`evals/` holds scenarios that check an agent follows the skill: it never touches the key, asks before a paid run, labels and deletes its sandboxes, and so on. They run against a stand-in `sandboxrouter` CLI, so they create no sandboxes and cost nothing beyond the model.

```sh
evals/run.sh --runs 1 --ablation none   # one run of each case, about $1 of model calls
```

See [evals/README.md](evals/README.md).
