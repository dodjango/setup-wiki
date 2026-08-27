---
name: mac-update
description: Use to update one tool or everything stale on this machine, guided by the wiki notes — reads how each thing is installed, updates it, runs its Verify section, and writes back what changed. Use this skill whenever someone says "update X", "update everything", or "what is out of date".
---

# Updating a tool

The difference from `brew upgrade` is not the update — anyone can type that
command. It is the chain after it: check that it still runs, and write back what
changed. That is exactly the part a bulk update skips.

## Two modes

**On request** — "update the window manager": one note, one tool.

**A round** — "update everything stale": first take the list, then note by note.
**Confirm each one individually**, do not run them all in one go. An update that
breaks something must be findable.

```bash
brew outdated --formula
brew outdated --cask --greedy     # --greedy is mandatory, see below
```

## How to update is in the note

The front matter field `install:` says it, `package:` names the package.

| `install:` | Command |
|---|---|
| `brew` | `brew upgrade <package>` |
| `brew-cask` | `brew upgrade --cask <package>` |
| `npm` | `npm install -g <package>@latest` |
| `homegrown` | **no command** — own script, see below |
| `manual` | **no command** — see below |
| `system-setting` | not applicable |

**Invent nothing for `homegrown` and `manual`.** These have no package manager.
Read out what `## Setup` in the note says and let the human decide. A made-up
update path for a hand-written script is worse than none.

## The trap that strikes quietly

`brew outdated --cask` **hides casks with `auto_updates`.** They update
themselves and never appear there — whoever reads only that list reports "all
current" for something they never checked. Always `--greedy`.

## Sequence per tool

1. **Read the note.** `purpose`, `install`, `package`, and whether `## Pitfalls`
   says anything about updating.
2. **Record the version beforehand** — in case it has to be rolled back.
3. **Update.**
4. **Run `## Verify`.** Not optional. An update without a check afterwards is
   exactly the state this wiki abolishes.
5. **On a break, read `## Pitfalls` first**, then improvise. If the cause is
   there, it has happened before.
6. **Update the note**, see below.

## What flows back into the note

**Only update version numbers where one already stands.** Some notes name
versions in prose; those should stay current. **Do not add new version
numbers** — otherwise every update produces a commit everywhere and the wiki
becomes a changelog.

Bump `checked_on`: you just checked against the machine, which is precisely what
the field is for.

**A new pitfall belongs in** if the update created one — and a rejected version
under `## Decisions` if you had to roll back. That is what `mac-write-note` is
for.

**What you do not touch:** `researched_on` and `research_finding`. A new version
is not an answer to whether the tool is still the right choice — that is
`mac-research`.

## Finish

```bash
./check.py
git add -A && git commit    # one commit per round, not per tool
```

If nothing changed in any note, commit nothing. An update that does not touch a
note is not a wiki event.
