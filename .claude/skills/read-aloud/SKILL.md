---
name: read-aloud
description: Use to read a text out loud on this machine, with pause, resume and speed control, and a rewritten listening version instead of the on-screen answer. Triggers on "read that to me", "I don't feel like reading", "read it out". Offer it when a text is long; start it immediately when it was asked for.
---

# Reading a text out loud

This is the one skill here with nothing to do with the wiki. It lives in this
repository anyway, because it is bound to the same machine as everything else:
the speech command only exists on macOS.

**Why not just the speech command:** `say "$(cat file.md)"` fails in three
places, and all three only show up while listening.

1. It reads the markup aloud — "asterisk asterisk important asterisk asterisk",
   tables as a wall of pipes, `<C-k>` as "less than C hyphen k".
2. It cannot be paused. If the phone rings, the only option is to kill it, and
   then it starts from the beginning.
3. It reads what was **written**. A paragraph that reads well is often
   incomprehensible when heard.

Point 3 is the most important and the only one no script can solve. That one is
your job.

## Step 1 — do not just start

The human wants the choice. **Offer it if you thought of it yourself**; **start
immediately if they asked.**

## Step 2 — rewrite the text for listening

This is the core. **Write a separate version; do not read your answer aloud.**
It was written for the eye — tables, bullet lists, code blocks, links. Heard,
that yields nothing.

| In the text | Spoken |
|---|---|
| `blink.cmp` | "blink dot cmp" |
| `<C-k>`, `<leader>a` | "control k", "leader a" |
| `35 → 26` | "twenty-six instead of thirty-five" |
| A table | two or three sentences of prose |
| A code block | leave it out, or say in one sentence what it does |
| A URL, a commit hash | leave it out — nobody memorises those by ear |

Three rules that matter more than the table:

- **Short sentences.** The script splits on sentence punctuation and speaks
  sentence by sentence. Short sentences mean finer pauses and cleaner resumption.
- **The result first.** When reading you jump to the heading; when listening you
  cannot. Anyone who learns the point two minutes in has already stopped
  listening.
- **Say at the end what comes next.** That replaces the glance at the screen.

## Step 3 — start it in the background

Always in the background: the wrapper waits until the reading is finished, and
in the foreground it would block you for the whole duration.

## Step 4 — name the controls

**In one line, not as a list.** Someone who is listening does not want to read
how to stop listening.

> Space pauses, `q` quits, `+`/`-` change the speed.

## Pitfalls

**The speech command cannot be paused, not even with a stop signal.** That was
the original design and it is disproven: the signal halts the process but not
the audio output. Audible stuttering on pause, half a sentence missing on
resume. Which is why the script speaks sentence by sentence, one invocation per
sentence. Anyone who "optimises" this back to signals rebuilds the bug.

**After a pause the sentence is repeated.** The index stays put. That is
intentional — after an interruption nobody remembers where they were. Not a bug.

**Never delete the state files while it runs.** Doing so makes the run
uncontrollable; it once left two voices speaking at the same time.

**A second start while it is still reading gives two voices.** Stop first.

## What you do not do

- **No raw speech command by hand.** Not even "just for one sentence" — then the
  human has no pause and no control.
- **No listening version without its own file.** Without a file there is no
  follow-along and no second attempt.
- **Do not read your own answer aloud** if it contains tables or code blocks.
