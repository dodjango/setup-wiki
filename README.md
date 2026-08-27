# setup-wiki

**A demonstration.** This is a fictional machine-setup wiki: one Markdown note
per decision, in folders by topic, with an index on top and a schema that a
language model can act on. The machine, the company and the incidents in it are
invented. The *shape* is the point.

**Start at [INDEX.md](INDEX.md). The rules are in [CONVENTIONS.md](CONVENTIONS.md).**

## The idea

Setting up a machine is usually captured in one of two ways, and both lose
something:

|  | Captures | Loses |
|---|---|---|
| A shell script | *what* to do | *why*, and whether it is still right |
| A written report | *what happened* | executability, and it ages silently |

Neither can answer the question that actually matters at rebuild time: **is this
still the right choice?** A script will happily reinstall a tool that was
discontinued two years ago. A report will describe it beautifully.

So each note carries a `commitment` field:

| | |
|---|---|
| `loose` | Convenience tool. Here an AI **should** go looking for alternatives |
| `medium` | Replaceable, but configuration or muscle memory hangs off it |
| `fixed` | Hardware, company policy, or half a dozen other notes. Do not research, only check the version |

A weekly run works through the five notes with the oldest `researched_on` and
writes findings back into the files. At rebuild time only the stragglers are
left. In this demo, `apps/screen-recorder.md` is what that run found: a tool
that looked fine and had been dead for three years.

## There is no progress file

The state lives in the machine, and the `## Verify` section of each note reads
it out. A checklist can lie — ticked and broken anyway; the machine cannot.

This is also why `checked_by` exists next to `checked_on`. A command returning
`0` and a human pressing a key shortcut are not the same confidence, and some
checks — does this shortcut actually snap the window? — no command can perform.
Notes carried over from an earlier document say `inherited`, which means: never
verified, treat as unknown. `./check.py` prints the tally on every run, so the
wiki's own debt is visible rather than assumed away.

## What makes it work for a language model

- **`purpose` is one sentence about the problem**, not about the tool. It is the
  first field read.
- **`commitment` is permission.** It tells the model where it may propose a
  change and where proposing one is noise.
- **`requires:` gives the order**, so nothing has to be sequenced by hand.
- **`# by hand:` marks what a machine cannot check**, so a model stops and asks
  instead of reporting a check it never ran.
- **Rejections stay.** `status: rejected` notes exist so a removed tool is not
  read as a gap and quietly reinstalled.

## Tools

```bash
./check.py     # checks the wiki itself: front matter, ids, links, section order
```

The skills in `.claude/skills/` are the entry points — one per lifecycle stage.
They are what turns the wiki from documentation into something that acts:
installing, updating, researching, and writing back what was learned.

```
mac-bootstrap        set up a machine from scratch
mac-install          new software, with a check and a note
mac-configure        set up something with no package behind it
mac-system-setting   analyse, change, try, revert a system setting
mac-update           update, note-guided
mac-research         look for alternatives, weekly
mac-write-note       write the note after a change
read-aloud           read a text out loud
```

## No credentials

Internals are fine — hostnames, cluster and tenant names, internal paths.
A token, a password, a private key is not, not even redacted and not "just as an
example". Notes point at the password store path instead. In a real deployment a
scheduled job greps the repository for private key markers.

## Licence

MIT, see [LICENSE](LICENSE). Take the schema, the checker and the skills and
point them at your own machine.
