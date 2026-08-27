---
name: mac-bootstrap
description: Use when setting up a machine from this wiki, or when re-establishing part of an existing setup — reads the notes in this repository, checks each tool against reality before installing, and confirms every note with the human individually. Use this skill whenever someone says "set up this machine", "fresh install", "rebuild my laptop", or asks what has to be installed.
---

# Setting up a machine from this wiki

You are setting up a machine according to the notes in this repository. You are
**not** a script working through a list — you are the part a script cannot do:
checking whether a decision made back then still holds today.

## Ground rules

1. **One note, one confirmation.** Before every install you put in front of the
   human: what you want to install, the `purpose` in one sentence, and whether
   the research found anything. You act only after a yes.
2. **No progress file.** The state lives in the machine. After every step you
   run the note's `## Verify` section. If work is interrupted, walk the checks
   from the top and continue where one fails.
3. **The order comes from `requires:`**, not from the folder structure.
4. **You write nothing about progress into the wiki.** The notes describe the
   target state. If that changes, it is a case for `mac-write-note`.

## Step 1 — orient

Read `INDEX.md` and `CONVENTIONS.md`. Then run `./check.py` — if it finds
errors, the wiki itself is broken and has to be repaired first.

## Step 2 — take stock

For every note with `status: active` and a matching `machines:` entry, run
`## Verify`. That gives three buckets:

| | |
|---|---|
| runs | nothing to do |
| missing | to be set up |
| runs differently than described | **stop and ask.** Either the note is stale or the machine is wrong. The human decides that, not you |

**Read `checked_by` before you believe a note.** `inherited` means: never
verified, the origin is a document. Treat such notes as a hypothesis and check
first. `human` is the strongest value; someone looked at what no command can
see.

**Lines marked `# by hand:` must go to the human.** They are in `## Verify`
precisely because no command can do them. Never report a check as passed whose
manual part you skipped — and in that case do not set `checked_by: machine`
either.

## Step 3 — research the stragglers

Every note with `commitment: loose` or `medium` whose `researched_on` is older
than three weeks or missing: research it now (see `mac-research` for the
method). The weekly run has handled most of them; this is only the remainder.

Notes with `commitment: fixed` are **not** researched. Only the version is
checked.

## Step 4 — walk the hard findings first

Present every `research_finding: hard` to the human together, **before**
anything is installed. This is where a tool decision can flip — and you do not
want to discover that after you have built on top of it.

## Step 5 — set up

Resolve the `requires:` chains, then note by note:

1. Present `purpose`, `commitment` and any finding → wait for confirmation
2. Run the commands from `## Setup`
3. Run `## Verify` and show the result
4. If it fails: read `## Pitfalls` before improvising. If the cause is there, it
   has happened before

## Step 6 — what you learn on the way

Every divergence between a note and reality is a change to the wiki, not a side
observation. Collect them and work them in with `mac-write-note` at the end —
or immediately, if it was a pitfall that cost time.

## Finish

This skill commits nothing. It changes the machine, not the wiki — and the
wiki already describes the target state. Everything you learned on the way goes
in through `mac-write-note`, which runs `./check.py` and commits there.

## What you do not do

- No blanket `chezmoi apply` without a path. Always targeted.
- Never loosen a security setting because it is more convenient.
- Never conclude "no authorization" from a non-interactive auth failure. See
  `security/password-store.md`.
- Never propose new credentials without the existing ones having been tested in
  a real terminal.
