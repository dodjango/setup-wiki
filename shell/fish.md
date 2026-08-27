---
id: fish
title: fish as the interactive shell
section: shell
purpose: An interactive shell that autosuggests and completes without a plugin framework — while every script in this setup stays POSIX
status: active
commitment: medium
commitment_reason: Roughly 400 lines of conf.d and a dozen functions hang off it; the syntax is not POSIX, so a move means rewriting all of it
install: brew
package: fish
requires: [homebrew]
machines: [mac, linux-laptop, homeserver]
researched_on: 2026-08-22
research_finding: soft
checked_on: 2026-08-25
checked_by: inherited
---

# fish as the interactive shell

## Why

The two things worth having in an interactive shell — history-based
autosuggestion and decent completion — cost a plugin framework in zsh and come
built in here. That is the whole reason. It is not a better scripting language;
it is not a scripting language this setup uses at all.

## Setup

```bash
brew install fish
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells   # needs admin, once
chsh -s /opt/homebrew/bin/fish
```

Configuration is split into `~/.config/fish/conf.d/*.fish`, one file per topic,
rather than one long `config.fish`. Files there are sourced in alphabetical
order, which makes a broken file easy to bisect and easy to remove.

## Verify

```bash
echo $SHELL                          # /opt/homebrew/bin/fish
fish -c 'echo $FISH_VERSION'
fish -c 'type -q z; and echo zoxide ok'
```

## Decisions

**2026-08-11 — scripts stay bash, always.** Every script in
`~/.config/scripts/` starts with `#!/usr/bin/env bash`, and nothing in this
setup is written in fish script. The reason is portability across the three
machines, but also that a shell you use interactively and a shell you write
programs in do not have to be the same shell, and pretending otherwise is how
people end up with unportable automation.

**2026-08-11 — no plugin manager.** Fisher, oh-my-fish and the rest were
skipped. Everything wanted from them here is either built in or twenty lines in
`conf.d/`.

## Alternatives

**2026-08-22 — zsh with zsh-autosuggestions, soft finding.** zsh plus two
plugins reaches functional parity and is POSIX, which would remove the two-shell
split entirely. Not compelling enough to rewrite 400 lines of `conf.d/` and a
dozen functions for; noted so the next research run does not rediscover it as
if it were new. Revisit if the function count ever drops.

## Pitfalls

**A function shadows a binary, and only inside fish.** Several tools here are
wrapped as fish functions. Inside fish the function wins; inside a bash script,
in an editor's integrated terminal, or in a cron job, the binary wins. Two
different behaviours from the same command name, and nothing warns you. If a
tool behaves differently in an IDE than in the terminal, check
`type -a <name>` first.

## Links

[[search-tools]] · [[chezmoi]] · [[neovim]]
