---
id: index
title: Setting up this Mac
section: meta
purpose: Entry point and table of contents — from here a human or a machine finds every note
status: active
checked_on: 2026-08-27
---

# Setting up this Mac

> **This is a demonstration, not a fabrication.** The tools, decisions and
> incidents below are real. What is missing is anything that identifies the
> employer: the company is not named, and internal hostnames, paths and
> credentials are not in this repository. See the [README](README.md) for what
> this is showing and why.

This collection describes **what** is set up on this machine and above all
**why**. It is the ground a fresh install is derived from — not replayed
blindly, but checked first: is this tool still alive? Is there something better
now?

How the notes are built is in [[conventions]]. The most important field is
`commitment`: it says where an alternative is welcome and where it is not.

Machine: MacBook Pro, Apple Silicon, centrally managed by the employer, no
standing admin. Sister machines: a Linux laptop and a home server.

## The ways into this wiki

All of them live **here in the repository**, under `.claude/skills/`:

| Skill | Lifecycle | For |
|---|---|---|
| `mac-bootstrap` | starting | Set up a machine from scratch out of this wiki |
| `mac-install` | adding | Install new software — checked, in the Brewfile, with a note |
| `mac-configure` | adding | Set up something that has no package behind it |
| `mac-system-setting` | adding | Analyse, change, try out and revert a system setting |
| `mac-update` | operating | Update one tool or everything stale, note by note |
| `mac-research` | judging | Look for alternatives — weekly, five notes per run |
| `mac-write-note` | recording | Write or update a note after something changed |

## Before a rebuild

1. Read [[conventions]]
2. Re-research notes with an old or missing `researched_on` — the weekly run has
   handled most of them already
3. Walk through every `research_finding: hard` with the human, **before**
   anything is installed
4. Resolve the `requires:` chains → that gives the order
5. Install, and run the `## Verify` section after **every** step

**There is no progress file.** The state lives in the machine, and `## Verify`
reads it out. A checklist can lie — ticked and broken anyway; the machine
cannot. If a setup is interrupted, run the checks from the top and continue
where one fails.

## Checking the wiki itself

```bash
./check.py     # front matter, ids, links, section order
```

At the end it prints the **verification standing**: how many notes are
machine-confirmed, how many a human has seen, and how many were merely carried
over. That number is the wiki's own debt, and it is printed on every run so it
cannot be quietly ignored.

## foundation/

| Note | Commitment | Purpose |
|---|---|---|
| [[homebrew]] | fixed | Package management; casks into `~/Applications`, because there is no standing admin |
| [[admin-rights]] | fixed | What works without admin — the constraint the rest is shaped by |
| [[corporate-tls]] | fixed | Proxy terminates TLS; one CA bundle, and the flag that must never be exported |
| [[brewfile]] | fixed | The inventory, and why its comments matter more than its package names |

## shell/

| Note | Commitment | Purpose |
|---|---|---|
| [[fish]] | medium | Interactive shell; scripts stay bash on purpose |
| [[search-tools]] | loose | fzf, zoxide, eza, bat, fd, ripgrep, sd — one decision, seven packages |

## development/

| Note | Commitment | Purpose |
|---|---|---|
| [[chezmoi]] | fixed | Dotfiles across three machines; no credential in the source tree |
| [[neovim]] | medium | Editor; language servers that attach silently and do nothing |

## security/

| Note | Commitment | Purpose |
|---|---|---|
| [[gopass]] | fixed | Where every credential lives, so no file has to hold one |
| [[network-shares]] | fixed | Company shares on demand; the credential step belongs to a human |

## apps/

| Note | Commitment | Purpose |
|---|---|---|
| [[rectangle]] | loose | Window snapping; the note a machine cannot verify |
| [[small-tools]] | loose | Four utilities with no story of their own |
| [[kap]] | loose | **rejected** 2026-08-22 — discontinued, dead runtime, never used |

## system/

| Note | Commitment | Purpose |
|---|---|---|
| [[macos-defaults]] | fixed | The changed settings, each with its reason beside the value |
| [[bsd-gotchas]] | fixed | sed, csplit, getent, bash 3.2 — differences that fail quietly |

## Open points

Each is under `## Decisions` or `## Pitfalls` in the note itself; this is only
the overview.

| Note | What is open |
|---|---|
| [[rectangle]] | The accessibility permission has to be re-confirmed after every macOS update, and nothing reminds us |
| [[macos-defaults]] | Two rows are marked `hand`, and four more entries are not preferences at all — none of the six has an automated check |
| [[network-shares]] | A login agent is prepared for but not enabled |
| [[neovim]] | The headless verification cannot see the plugin bootstrap |

## Where this came from

This wiki grew out of a 200-page prose report about a machine setup. The report
said what happened. A shell script would say what to do. Neither can ask
whether a tool is still the right choice — which is what the `commitment` field
and the weekly research run are for.

The migration left a mark that is deliberately visible: notes carried over from
the report carry `checked_by: inherited`, meaning nobody has verified them
since. Working that number down is the actual ongoing task.
