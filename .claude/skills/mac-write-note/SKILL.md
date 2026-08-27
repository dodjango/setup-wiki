---
name: mac-write-note
description: Use after changing anything on this machine — installing, configuring or removing a tool, or hitting a pitfall worth remembering. Writes or updates the matching note in this wiki. Use this skill after every change to the machine, without asking whether it should be recorded.
---

# Updating the setup wiki

The rules are in `CONVENTIONS.md` — read them before you write.

**Update without asking.** If something on the machine changed, it belongs in
the wiki, in the same session. Do not ask whether it should be recorded.

## Where it goes

| Change | Where |
|---|---|
| New tool | A new note in the matching folder — or into an existing one, if it is the same *decision*. The rule "one file = one decision, not one package" is in `CONVENTIONS.md` |
| Configured differently | `## Setup` **and** `## Verify` of the existing note |
| Something rejected | `## Decisions`, **dated**, with the reason. Do not delete — the rejected path is the information |
| Something hurt | `## Pitfalls`. What was the symptom, what the cause, how was it found |
| Something replaced something | `replaces:` in the front matter, and the old note to `status: superseded` |

## While writing

- **`purpose` is one sentence and describes the problem, not the tool.** It is
  read first — including by a model deciding whether an alternative exists.
- **`## Verify` is mandatory, not decoration.** A command and the expected
  output. It is the only state store this wiki has.
- **Stories belong to the topic, not to an archive.** A course correction lives
  with the tool it was about.
- **What was measured goes in as a measurement**, not as a claim. Numbers,
  timestamps, actual output. Half the value of this wiki is cases where an
  assumption turned out measurably wrong.
- **Bump `checked_on`** if you checked against the machine. **Do not** bump it if
  you only changed text.
- **Set `checked_by` truthfully:** `machine` if you ran `## Verify`; `human` if a
  person looked, pressed or listened; `inherited` stays until someone checks.
  **Never write `machine` if you did not actually run the commands** — a field
  claiming a check that did not happen is worse than an empty one.
- If `## Verify` needs a look, mark the line `# by hand:`. The checker then
  warns when `checked_by: machine` sits next to it.
- Links with `[[id]]`, no folder path. A link to a note that does not exist yet
  is allowed and marks a gap.

## Never into the repository

**No credentials.** Not as an example, not redacted, not "just for testing".
Internals are fine — hostnames, cluster and tenant names, internal paths, ticket
numbers. A token, a password, a private key is not.

Point at the password store path instead: "the token is in the store under
`service/…`".

## Finish

```bash
./check.py                            # front matter, ids, links, order
git add -A && git commit
```

If `check.py` finds something, fix it — do not commit and hope.
