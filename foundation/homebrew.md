---
id: homebrew
title: Homebrew
section: foundation
purpose: Package management on a machine where nobody has standing admin rights
status: active
commitment: fixed
commitment_reason: Everything installable in this wiki hangs off it; the alternatives (MacPorts, Nix) would mean rewriting every note
install: manual
package: homebrew
machines: [mac]
checked_on: 2026-04-11
checked_by: machine
---

# Homebrew

## Why

This Mac is company-managed. There is no standing admin account — admin rights
are granted for fifteen minutes at a time through a self-service portal, and a
password prompt in the middle of an unattended install is the fastest way to
turn a twenty-minute setup into an afternoon. See [[admin-rights]].

Homebrew is the only package manager here that works entirely inside the user's
own directories once it is installed. That, and not popularity, is why it is
`fixed`.

## Setup

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Apple Silicon this lands in `/opt/homebrew`, which the installer creates
with one single admin prompt. That prompt is expected — it is the only one.

Casks are redirected into the home directory, because `/Applications` needs
admin on every single install:

```fish
# ~/.config/fish/conf.d/homebrew.fish
set -gx HOMEBREW_CASK_OPTS "--appdir=$HOME/Applications"
```

## Verify

```bash
brew --version                       # Homebrew 4.x
brew doctor                          # "Your system is ready to brew."
echo $HOMEBREW_CASK_OPTS             # --appdir=/Users/<you>/Applications
```

If `HOMEBREW_CASK_OPTS` is empty, the next cask install will ask for a password.
That is the signal, not a failure to push through.

## Decisions

**2026-03-09 — Homebrew over Nix.** Nix would give reproducible installs, which
is exactly what this wiki is chasing. It was rejected anyway: it wants
`/nix`, which needs a volume and a daemon, and the security baseline on this
machine flags unsigned launch daemons. Revisit if the baseline changes.

**2026-03-09 — casks into `~/Applications`.** Spotlight and Launchpad find
apps there just as well. The cost is that a cask requiring a hardcoded
`/Applications` path has to be installed by hand, which has happened once so
far and is noted in the affected note.

## Pitfalls

**`brew upgrade --cask` silently skips casks that update themselves.** They
carry `auto_updates true` and never appear in `brew outdated --cask`. Whoever
reads only that list reports "all current" for something they never checked.
Always `--greedy`.

Counter-check on 2026-04-11: without `--greedy` two casks, with `--greedy`
four.

## Links

[[brewfile]] · [[admin-rights]] · [[corporate-tls]]
