---
id: conventions
title: Conventions of this wiki
section: meta
purpose: The rules the notes are written and read by — for humans and machines alike
status: active
checked_on: 2026-08-22
---

# Conventions

## What this is for

A shell script says **what** is done, and a comment in it can say why. What a
comment cannot do is carry a *state*: when the reason was last examined, whether
it is open to revision at all, what the last look found. This collection gives
every reason a file, an id and fields, so that those questions have somewhere to
live.

That is what makes it operable. When a machine is set up, an agent reads these
files, checks per entry whether the tool is still the right choice, proposes
alternatives where something has moved — and writes what it found back into the
note. Only then does it install.

The collection is **not a replacement for execution**. It is the ground an
execution is derived from — every time anew, every time checked.

## One file = one decision

Not one package. `fzf`, `zoxide`, `eza`, `bat`, `fd`, `ripgrep` and `sd` are
one decision ("modern replacements for the Unix classics") and therefore live
in **one** file. A password store has its own history, its own pitfalls and
hangs off hardware — its own file.

Rule of thumb: as soon as a tool deserves its own "Decisions" or "Pitfalls"
section, it gets its own file.

## Front matter

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Filename without `.md`, kebab-case. Target of `[[links]]` |
| `title` | yes | Display name |
| `section` | yes | Folder name |
| `purpose` | yes | **One sentence**: what problem this solves. The AI reads this field first |
| `status` | yes | `active` \| `planned` \| `rejected` \| `superseded` |
| `commitment` | yes | `loose` \| `medium` \| `fixed` — steers the alternatives research |
| `commitment_reason` | for `medium`/`fixed` | What it hangs off |
| `install` | if installable | `brew` \| `brew-cask` \| `npm` \| `manual` \| `system-setting` \| `homegrown` |
| `package` | if installable | Exact package name |
| `requires` | no | ids that must exist first |
| `replaces` | no | What this made obsolete |
| `machines` | yes | `mac` \| `linux-laptop` \| `homeserver` — several possible |
| `checked_on` | yes | When this was last checked against reality |
| `checked_by` | yes | `machine` \| `human` \| `inherited` — **who** checked, see below |
| `researched_on` | for `loose`/`medium` | When alternatives were last looked for. **Sort key** of the research run: the five oldest are next |
| `research_finding` | for `loose`/`medium` | `none` \| `soft` \| `hard` — see below |

## `commitment` is the most important field

It answers the AI's question: *am I allowed to propose an alternative here?*

- **`loose`** — pure convenience tool, replaceable at any time. Here the AI
  **should** research whether something better exists. (`eza`, `bat`)
- **`medium`** — replaceable, but configuration or muscle memory hangs off it.
  Propose an alternative only if the benefit can be named in one sentence.
  (`fish`, `neovim`)
- **`fixed`** — not negotiable. Hardware, a company policy, or half a dozen
  other notes depend on it. Do not research, only check the version.
  (`corporate-tls`, `chezmoi`, `gopass`)

## The research finding lives in two places

Front matter carries the **status**, the body carries the **reasoning**. One is
machine-readable and sortable, the other is the text a human wants to read.
Pressing both into one field makes neither whole.

| `research_finding` | Meaning | What happens |
|---|---|---|
| `none` | Nothing new. Tool is alive, no serious alternative | only `researched_on` is bumped |
| `soft` | Something else exists, but no compelling reason | `## Alternatives` is extended. **Silently** — no notification |
| `hard` | Discontinued, archived, security hole, last release over two years old | `## Alternatives` is extended **and** a message goes out |

The split is not cosmetic. With two dozen loosely committed tools there is
*always* something newer somewhere. If every soft finding notified, the channel
would be dead within two weeks — and with it the notifications that matter.

## Who checked is as important as when

`checked_on` says when someone last looked. That is not enough: a command that
returns `0` and a human who pressed a key shortcut are not the same confidence.

| `checked_by` | Meaning | Load-bearing? |
|---|---|---|
| `machine` | The `## Verify` section was executed and passed | High, for everything a command can see |
| `human` | Someone looked, pressed, heard or clicked | The only source for everything a command cannot check |
| `inherited` | Carried over from an earlier document, **never re-checked** | None. Treat it as unknown |

`inherited` is the honest starting state of a wiki grown out of prose: the
notes came from a report, not from a measurement. Whoever touches a note and
checks it sets the value to what they actually did.

**Why the distinction is needed:** some checks are not machine-possible at all.
Whether `Ctrl+Opt+←` snaps a window to the left half, whether a menu bar icon
is visible, whether a voice sounds right — only a human sees that. If a note
says `machine` although its `## Verify` demands a look, the check is
incomplete, and the field says so.

**Both at once** is not a value. Whoever checked by machine **and** by hand
writes `human` — the human saw the machine part too.

## Mark verification steps that need a human

If `## Verify` holds a step no command can do, it is marked as such — as a
comment inside the code block or as a sentence below it:

```bash
defaults read com.example.WindowManager launchOnLogin   # 1
# by hand: Ctrl+Opt+<left> must snap the window to the left half
```

The bootstrap skill knows from this where to stop and ask, instead of
reporting a check as passed that it could not perform.

## Body: fixed sections

Always in this order, omit the empty ones:

```
## Why           Prose. The problem, not the tool.
## Setup         Copyable commands. Order matters.
## Verify        How do I know it actually runs? Command plus expected output.
## Decisions     What was rejected and why. Dated.
## Alternatives  What the research found. Dated. Appended, never replaced.
## Pitfalls      What hurt once.
## Links         [[other-ids]]
```

`## Verify` is not optional decoration — it is what this collection redeems
over a script: verifiable instead of hopefully.

## Links

With `[[id]]`, no folder path. Ids are globally unique. A link to a note that
does not exist yet is allowed and marks a gap.

## Stories belong to the topic, not to an archive

Course corrections, dead ends and reverted changes live under `## Decisions`
**with the tool they were about** — not in a folder of their own. Without the
context the story loses its value.

## No credentials

Not as an example, not redacted, not "just for testing". Internals are fine —
hostnames, cluster and tenant names, internal paths, ticket numbers. A token, a
password, a private key is not. Point at the password store path instead.
