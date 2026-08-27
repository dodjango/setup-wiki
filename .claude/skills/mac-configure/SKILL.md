---
name: mac-configure
description: Use to set up something on this machine that has no package behind it — access to a company system, a network share, a scheduled agent, a helper script with a task-runner recipe, anything you would otherwise click together by hand. Triggers on "set up X", "I need access to Y", "can you automate that", "how do I get to Z". Use this skill instead of improvising in the home directory; mac-install is for software with a package, this one is for everything without.
---

# Setting up something that has no package

For everything the package manager knows, there is `mac-install`. This skill is
for the other case — an access path, a service, an automation. Three things go
**quietly** wrong there, and none of them shows up on the same day:

1. **The precondition is never named.** It works today because the VPN happens
   to be up. Tomorrow the file browser says "connection failed", and that looks
   like a password problem. See `security/network-shares.md`.
2. **The configuration lives only in the home directory.** At the next rebuild it
   is gone — the same hole as a missing Brewfile entry, but without a package
   manager to catch it.
3. **There is no check command.** So there is no way to tell whether it still
   works.

## Step 1 — establish the situation, do not guess

Before you build anything: find out what it hangs off. The answer belongs in
`## Verify` of the note later, because it is the first question during any
outage.

| Question | Command |
|---|---|
| Can I reach it at all? | `nc -z -G 3 <host> <port>` — **not** `ping`, ICMP is filtered on the company network |
| Does it go over the VPN? | `route -n get <ip> \| grep interface` → a tunnel interface means yes |
| Is there a directory binding? | `dsconfigad -show` (empty = not bound), `klist` (a ticket?) |
| Does a company policy have a say? | `ls /Library/Managed\ Preferences/`, `profiles show -type configuration` |
| Is it already in the wiki? | `grep -ri '<thing>' */*.md` |

**Do not throw names from URLs at a resolver.** An ssh config alias is not a DNS
name, and there is no `getent` here. First `ssh -G <host>`, then
`dscacheutil -q host -a name <h>` (field `ip_address:`). See
`system/bsd-gotchas.md`.

## Step 2 — choose the mechanism

| Temptation | Why it is usually wrong here | Instead |
|---|---|---|
| `autofs`, `/etc/…`, `sudo` | No standing admin on this machine | Something in the user's own area |
| A system service unit | Does not exist on macOS | A LaunchAgent under `~/Library/LaunchAgents/` |
| Run automatically at login | A laptop is usually **not** on the company network at login, and the VPN does not return by itself after the lid was closed. An automation that mostly fails only produces noise | A command on request — with a reachability check that makes the agent possible later without a rewrite |
| Logic inside the task-runner recipe | Complex logic belongs in a script | A script in `~/.config/scripts/`, a thin recipe in front |

And: **fail kindly.** If the precondition is missing, the script says so in one
sentence and exits successfully — not with an error that looks like a defect.

## Step 3 — the configuration belongs in chezmoi

Otherwise it is gone at the next rebuild. **Edit the source**, never the target:

```bash
chezmoi source-path ~/.config/scripts/xyz.sh     # -> executable_xyz.sh
chezmoi apply ~/.config/scripts/xyz.sh           # targeted, never without a path
```

- Scripts are named `executable_*.sh` — without the prefix the execute bit is
  missing.
- The task-runner file is a template with **swapped delimiters** (`[[ ]]`),
  because just itself uses `{{ }}`.
- Anything that exists only on this machine also belongs in the OS block of
  `.chezmoiignore` — otherwise an `apply` creates dead files elsewhere.
- Run `bash -n` **and** `shellcheck`. macOS ships bash 3.2: no associative
  arrays, no `${x^^}` — and `bash -n` does not notice.

## Step 4 — the step that belongs to a human

Credentials, login dialogs, quarantine prompts: **do not ask for the password
and do not write it anywhere.**

- A password in a URL or in `argv` is readable via `ps` by every process on the
  machine.
- The keychain and the password store are the storage. Read the store at
  **run time**, never render it into a file.
- The human answers the dialog. Give them the command to run themselves, and
  tell them which box to tick.

## Step 5 — verify the effect, not the start

That a service started, a client connected or a volume appeared proves nothing.
Check the result: is content there, does an answer come back, does the file
appear. A language server that attaches and stays silent cost a day
(`development/neovim.md`).

And **trust no tool that cannot look.** A keychain query can fail to find an
entry that plainly works, because it does not read that keychain at all — the
same class of false conclusion as a non-interactive test of a passphrase-
protected key. Verify by behaviour: unmount, remount.

## Finish

Note via `mac-write-note`. Three things are specific to a setup without a
package:

- **`install: homegrown`** if a script is involved; `system-setting` if it was
  only a switch. `package:` then names the script.
- **`requires:` must contain the precondition**, not just the tools. If it hangs
  off the VPN, that belongs there — it is half the troubleshooting.
- **`## Verify` starts with the path, not the destination**: reachability first,
  function second.

```bash
./check.py
git add -A && git commit    # one commit per setup
```

The commit in the dotfiles repository is a separate one — two repositories, two
commits.
