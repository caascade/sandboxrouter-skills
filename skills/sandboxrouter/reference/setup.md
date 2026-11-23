# Setup

The CLI acts in one workspace: the one its API key was created in. It needs three things saved: the workspace's **tenant ID**, its **namespace**, and an **API key** (`ck_…`).

## 1. Install

```sh
node --version                     # needs 22 or later
npm i -g @sandboxrouterio/cli
sandboxrouter help
```

## 2. The user creates a key and configures the CLI

**You never see the key.** The CLI takes it only as a command-line option, so if you run the command, the key lands in this conversation. Ask the user to do these steps themselves:

1. Sign in to https://console.sandboxrouter.io/ and open **Settings**.
2. Under **Workspace**, copy the **Tenant ID** and the **Namespace**.
3. Under **API keys**, enter a key name (such as `my laptop`) and choose **Create key**. Copy the key: it starts with `ck_` and is shown once. Leave **Billing access** unchecked: you don't need it.
4. In their own terminal, not through you, run:

   ```sh
   sandboxrouter configure --tenant <tenant-id> --key <api-key> --namespace <namespace>
   ```

Owners and operators can create keys. Viewers can't, so a viewer has to ask an owner for a different role.

The CLI saves these to `~/.config/sandboxrouter/config.json`, or to `$XDG_CONFIG_HOME/sandboxrouter/config.json`. Don't read or print that file: it holds the key.

## 3. Check

```sh
sandboxrouter sandboxes list
```

| Result | Cause | Fix |
| --- | --- | --- |
| A list, maybe empty | Ready | — |
| Exit `2`, asks to name the workspace's namespace | No namespace saved | The user runs `sandboxrouter configure --namespace <namespace>` |
| Exit `3`, `unauthorized` | Key revoked, key from another workspace, or wrong namespace | The user checks the namespace under **Settings** → **Workspace**, and if it's right, creates a new key and configures again |

## Another workspace

A key works only in its own workspace. To switch, the user creates a key in the other workspace and runs `configure` again, which replaces what was saved.

## What the key can and can't do

A normal key can create, change, start, stop and delete sandboxes, run commands, and move files. It can't do anything its creator can't. Only an **owner's** key can connect provider accounts or add connectors. Only a key with **Billing access** can read the balance or add funds. If a command exits `3` for lack of access, tell the user what it needs and stop; don't look for a way around it.
