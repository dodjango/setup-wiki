# setup-wiki

**What if your machine setup were not a script but a wiki — one an agent keeps
for you?**

A script can say why every line is there; that is what comments are for, and a
language model reads them fine. What a comment cannot do is carry a state: when
the reason was last examined, whether it is open to revision, what the last look
found. Give each decision a file, an id and a few fields, and the reasoning
stops being something you read and becomes something an agent can operate.

**A demonstration, not a fabrication.** This is an extract from the setup wiki
of a real MacBook Pro: one Markdown note per decision, in folders by topic,
with an index on top and a schema a language model can act on. The tools, the
decisions and the incidents are real and happened on a machine that is run this
way.

What has been taken out is anything that identifies the employer. The company
is not named, and internal hostnames, paths, ticket numbers and credentials
never enter this repository at all. Some notes are shortened. Nothing in them
is invented.

It does not claim to be complete. The wiki it is taken from holds about four
times as many notes, and several of the mechanisms described here are sketched
rather than built out. What is in this repository is the slice that shows the
idea: the schema, the checker, the skills, and enough real cases to judge them
by. The gaps are deliberate.

**Start at [INDEX.md](INDEX.md). The rules are in [CONVENTIONS.md](CONVENTIONS.md).**

## What is in here

```
INDEX.md          the entry point: every note, by folder, with its commitment
CONVENTIONS.md    the rules the notes are written and read by
check.py          checks the wiki itself, not the machine

foundation/       what everything else stands on: Homebrew, the CA bundle, the Brewfile
shell/            the interactive shell and its small tools
development/      dotfiles, editor, language servers
security/         password store, network shares
apps/             GUI applications, including the ones that were removed again
system/           macOS settings and the BSD userland differences

.claude/skills/   the seven skills that act on all of the above
examples/         the settings script the system note refers to
```

**One file, one decision — not one package.** Seven search tools that were
chosen together share a note; gopass has its own history, its own pitfalls and
hangs off hardware, so it gets its own file. The folders group by what kind of
thing something is, not by when it was installed, because that is the question
being asked at a rebuild.

**Every note has the same shape.** Front matter a machine reads, then a fixed
sequence of sections — Why, Setup, Verify, Decisions, Alternatives, Pitfalls,
Links. Empty ones are left out, the order is enforced.

The front matter carries what the skills act on: `purpose`, one sentence about
the problem rather than the tool; `requires`, which notes must exist first and
therefore the install order; `install` and `package`; `checked_on` and
`checked_by`. And the field that steers all the rest:

| `commitment` | |
|---|---|
| `loose` | Convenience tool. Here an AI **should** go looking for alternatives |
| `medium` | Replaceable, but configuration or muscle memory hangs off it |
| `fixed` | Hardware, company policy, or half a dozen other notes. Do not research, only check the version |

**Notes link to each other with `[[id]]`.** Ids are globally unique and carry no
folder path, so a note can move between folders without breaking a link. A link
to a note that does not exist yet is allowed and marks a gap worth writing.
`requires:` is the stricter relative and must resolve — the bootstrap skill
derives the install order from it, and a dangling entry would silently produce
the wrong one.

**`INDEX.md` is the entry point**, for a person and for a model: every note in
one table per folder with its commitment and a one-line purpose, and the open
points from all notes collected in one place.

**`./check.py` checks the wiki, not the machine** — required fields, unique ids,
allowed values, section order, links and `requires` that go nowhere, and
whether a research finding agrees with what the note actually says. It prints
the verification standing on every run.

## The skills

One per lifecycle stage, in `.claude/skills/`. They are what turns the wiki from
documentation into something that acts — and each exists for a specific place
where the one-line command goes quietly wrong.

- **`mac-bootstrap`** — Sets up a machine from these notes, resolving the
  `requires:` chains for order and confirming every single note with the human
  before installing anything.
- **`mac-install`** — Adds new software: checks first whether the tool is alive
  and whether the OS already ships it, then installs, then records it in the
  Brewfile, then writes the note.
- **`mac-configure`** — Sets up the things that have no package behind them — an
  access path, a share, a scheduled agent — where the precondition is what
  actually needs documenting.
- **`mac-system-setting`** — Analyses, changes, tries out and reverts a system
  setting, refusing to write anything before the old value has been read and
  recorded.
- **`mac-update`** — Updates one tool or everything stale, note-guided, running
  each note's `## Verify` afterwards and writing back what changed.
- **`mac-research`** — Looks for alternatives in the five notes with the oldest
  `researched_on`, and decides whether a finding is worth interrupting anyone
  for.
- **`mac-write-note`** — Writes or updates the note after a change, without
  asking whether the change is worth recording.

## The scheduled run

The third building block, next to the notes and the skills, and the one that
makes the difference between a wiki and an archive. Two jobs, both on a timer,
both writing back into the repository rather than into a report nobody opens.

**Weekly — the alternatives run.** It takes the five notes with the oldest
`researched_on`, skips everything marked `fixed`, and checks each remaining tool
for the same five things: is it alive, is it archived, is there a named
successor, are there advisories, is there something demonstrably better. Then it
writes the finding into the file and bumps the date.

What it does with the result is graded, and the grading is the load-bearing
part:

| Finding | What happens |
|---|---|
| `none` | bump the date. Silent |
| `soft` | append to `## Alternatives`. Still silent |
| `hard` | append **and** send one message |

Across the loosely committed notes there is *always* something newer
somewhere — each of them covers several tools. A run that notified on every
soft finding would burn the channel within two weeks, and the one hard finding
a year — the discontinued tool with the end-of-life runtime — would arrive in a
stream nobody reads any more. The silence is the feature.

Because it runs continuously, a rebuild does not start with weeks of research.
It starts with the stragglers.

**Every six hours — the secret scan.** It greps the tracked files of this
repository and of the dotfiles repository for private key markers and token
shapes, and it also checks whether the dotfiles repository has diverged from its
remote. Both are rules stated elsewhere in prose; this is the part that makes
them enforced rather than intended. A rule nobody checks is a preference.

## Why a wiki and not a script

The state a comment cannot carry is exactly what the schema turns into fields.
When the reason was last examined is `researched_on`. Whether the decision is
open to revision at all is `commitment`. What the last look found is
`research_finding`, together with the `## Alternatives` section it has to agree
with — and `check.py` reports it when the two disagree.

Three fields, and between them the weekly run has everything it needs: what to
pick up next, what to leave alone, and where to put the answer.

`apps/kap.md` is what that produced on the first run. A tool that launched, sat
in the Brewfile and showed nothing broken from the outside, whose last release
was almost four years old and which had never once been used. A comment saying
"screen recording, because Shottr cannot do video" would have been true, would
have been readable, and would have changed nothing.

## There is no progress file

The state lives in the machine, and the `## Verify` section of each note reads
it out. A checklist can lie — ticked and broken anyway; the machine cannot.

This is also why `checked_by` exists next to `checked_on`. A command returning
`0` and a human pressing a key shortcut are not the same confidence, and some
checks — does this shortcut actually snap the window? — no command can perform.
Notes carried over from an earlier document say `inherited`, which means: never
verified, treat as unknown. `./check.py` prints the tally on every run, so the
wiki's own debt is visible rather than assumed away.

## What was rejected

Both alternatives were tried before this, and both failed at the same point.

**Ansible.** The obvious answer: a machine setup is configuration management,
and this is the tool for it. It was rejected for three reasons. Its playbooks
are declarative about *state* and silent about *reasoning* — the `when:` clause
says a package is installed on Darwin, never why that package and not the other
one, and a comment above a task is not something anything can act on. Its
strength is enforcing a state across many machines, whereas the actual job here
is deciding, once, on one machine, whether a state is still wanted. And most of
it is aimed at servers: a large share of what this wiki records — an
accessibility permission, a first-launch dialog, whether a keyboard shortcut
actually fires — has no module and cannot be asserted at all.

**Hand-written setup scripts.** The starting point, and it works for about a
year. Then the script is 600 lines, every line is still correct in the sense
that it runs, and nobody can say which of them are still *wanted*. The comments
are still there and still readable — but nothing acts on them, so nothing keeps
them true. The failure is silent: a script reinstalls a dead
tool without a murmur, and the removal you made deliberately six months ago
comes back because a rebuild simply ran the file.

Neither is wrong about execution. Both are wrong about the part that turned out
to matter — carrying a reason forward in a form something can act on.

**What is kept from both:** the Brewfile is the declarative inventory, and
`examples/macos-defaults.sh` is a script. They just are not where the reasoning
lives.

## Related: Karpathy's LLM Wiki

The general pattern here is the one Andrej Karpathy published in April 2026 as
[llm-wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f):
rather than retrieving from raw documents at query time, an agent incrementally
builds and maintains a persistent, interlinked collection of Markdown files —
atomic entries, a consistent structure, metadata travelling with each entry, and
the agent as the primary reader rather than a human browsing.

This repository applies that pattern to a subject it was not written for, and
the subject changes two things:

- **The source is not a corpus, it is a machine.** There is nothing to ingest.
  Each note describes a state that can be *read back*, which is why every note
  has a `## Verify` section and why there is no progress file. A knowledge wiki
  is right or wrong; this one can be right, wrong, **or stale** — and staleness
  is the failure mode worth engineering against.
- **Not every entry may be revised.** A knowledge base wants every claim
  updatable. Here, half the notes describe things that are not up for
  discussion — hardware, company policy. That is what `commitment` encodes: it
  is a permission field, telling the agent where a proposal is useful and where
  it is noise.

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

## No credentials

Internals are fine — hostnames, cluster and tenant names, internal paths.
A token, a password, a private key is not, not even redacted and not "just as an
example". Notes point at the password store path instead, and the six-hourly
scan above is what keeps that from being merely a good intention.

## Feedback

The point of publishing this is the idea, not the repository. If you keep your
machine this way, or tried something like it and it fell apart, I would like to
hear about it — open an issue. Disagreement is useful too: several of the
decisions in here were reversed once already, and the reversals are in the
notes.

## Licence

MIT, see [LICENSE](LICENSE). Take the schema, the checker and the skills and
point them at your own machine.
