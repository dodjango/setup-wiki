---
name: mac-system-setting
description: Use to analyse, change, try out or revert a macOS system setting — defaults keys, Finder/Dock/keyboard behaviour, symbolic hotkeys, things that only exist in the GUI. Triggers on "change X", "why does Y behave like that", "can Z be turned off", "try it", "undo that", "which settings have we set". Use this skill instead of a direct defaults write — without the old value read first, there is no way back.
---

# Investigating, changing, trying and reverting a system setting

The collection note is `system/macos-defaults.md`. `defaults write` is one line
— which is why this skill does not exist for that. It exists because three
things happen regularly:

1. The **old value** was not recorded. The way back is lost, and "put it back
   how it was" can no longer be answered.
2. The setting **does not take effect** — and the cause is not the key but the
   level it sits on.
3. It **was not a `defaults` key at all.** Some switches exist only in the GUI.

## Step 1 — read before you write

**Without this step you do not start.** The old value is the only copy of the
way back.

```bash
defaults read <domain> <key>
defaults read <domain> | grep -i <fragment>      # if the key name is unclear
defaults domains | tr ',' '\n' | grep -i <app>
```

`does not exist` **is** a value, and an important one: the way back is then
`defaults delete`, not "write a 0". A written `false` is something different
from "not set" — Apple can change the default in a later release, and then your
`false` freezes a state you never decided.

Record domain, key, old value and type (`-bool`, `-int`, `-string`) **before**
writing. That is the text that goes into the note later.

## Step 2 — the four levels

The same domain name exists more than once. Reading the wrong level gives wrong
conclusions.

| Level | Read with | Note |
|---|---|---|
| User | `defaults read <domain>` | The normal case. Applies to this user only |
| Per device (ByHost) | `defaults -currentHost read <domain>` | **Invisible** without the flag |
| Company-managed | `ls /Library/Managed\ Preferences/` | **Wins.** A write there is silently discarded or reset |
| System | `sudo defaults read /Library/Preferences/<domain>` | Needs admin |

**If a setting keeps reverting, look at the managed level first** — not at your
own configuration. And do not work against a managed value: that is a company
policy, not a malfunction.

## Step 3 — effect does not arrive by itself

A `defaults write` changes the database, not the running app. Reading the value
back shows it immediately — which is why people conclude the change took effect.

```bash
killall Dock        # Dock, Mission Control, spaces
killall Finder      # Finder behaviour
```

Some things take effect only at logout. What you do **not** do: read the value
and conclude the effect happened. Check the effect — press the key, open the
window.

## Step 4 — not everything is a `defaults` key

Documented cases from this wiki, all of which cost time:

- **The control centre cannot be steered via `defaults`.** Written values are
  overwritten within seconds, in both orderings.
- **Keyboard shortcuts hang off the keyboard layout, not the character.**
  `com.apple.symbolichotkeys` stores a character code, a key code and a modifier
  mask. The shortcut named in every tutorial is a different physical key on a
  non-US layout.
- **Some things are a filesystem flag**, not a key: `chflags nohidden ~/Library`.

If three attempts move nothing, the question is no longer "which key" but "is it
one at all".

## Step 5 — Apple changes its own defaults

One setting in this wiki was found already flipped, without this setup having
touched it. Two consequences:

- A setting "nobody changed" can still have changed. A report about it is a
  hypothesis; read the value.
- Which is why the recorded target value in the note is not decoration but the
  only way to notice such a thing at all.

## Step 6 — trying it out, as a loop

This is what the skill is for. The point is reversibility, not the change.

1. Read the old value and **write it down** (step 1).
2. Change — one thing at a time. Two at once and the result is worthless.
3. Check the effect, and tell the human what to press if no command can see it.
4. Let them decide. **Do not decide yourself** whether it is better.
5. Keep → the note (step 7). Discard → put it back **and verify the way back**,
   not merely execute it.

## Step 7 — the way back and reproducibility go into the note

Via `mac-write-note`, usually into `system/macos-defaults.md`; a note of its own
only if a decision of its own hangs off it.

Two things are mandatory here:

- **The exact way back, as a command** — including its price, if there is one.
- **The setting command, runnable.** A new setting goes into the table the
  script reads, with domain, key, type, target value, mode and reason, so that
  the wiki is the script it otherwise would not have.

```bash
./check.py
git add -A && git commit
```

## What you do not do

- **No `defaults write` without a preceding `read`.** That is the one rule.
- **Do not overwrite a managed domain.** Company policy, not a defect.
- **Do not loosen a security setting because it is more convenient**, and never
  strip a quarantine attribute.
- **Nothing system-wide where the user level is enough.** Every setting here is
  per-user on purpose: individually reversible, no admin needed.
