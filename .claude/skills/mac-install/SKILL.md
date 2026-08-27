---
name: mac-install
description: Use when installing new software on this machine — checks whether the tool is alive and whether the OS already ships it, installs it, records it in the Brewfile, and writes the wiki note. Use this skill whenever someone says "install X", "I need a tool for Y", or "can we add Z", instead of running a bare brew install.
---

# Installing new software

`brew install` is one line — which is why this skill does not exist for that.
It exists for the three places where a new install goes **quietly** wrong:

1. Nobody checked beforehand whether the thing is alive, or whether the OS
   already ships it.
2. The entry is missing from the Brewfile — at the next rebuild the app is gone.
3. There is no note, so in six months nobody remembers **why**.

Points 2 and 3 do not announce themselves. That is exactly why they are here.

## Step 1 — check the candidate before installing

**Do not skip this, even if the human already named the package.** The point of
this wiki is that the question gets asked at all. On a hard finding you ask
before installing — you do not decide.

```bash
brew info --cask <name> 2>/dev/null || brew info <name>
```

| Question | Why |
|---|---|
| **Cask or formula?** | `brew info` says so. A GUI app is a cask |
| **Is it alive?** | Last release, last commit with substance. Over two years without a release is a **hard** finding |
| **Does the OS already ship this?** | The counter-question that makes half a toolbox unnecessary |
| **Is it already in the wiki?** | `grep -ri '<name>' */*.md`. It may have been rejected once, with a reason |
| **Is there something better?** | Only if you can name the advantage in one sentence |

On a hard finding — discontinued, archived, security hole, last release over two
years old — you **stop** and present it. The human may still want it; then you
install it and **write the finding into `## Alternatives`** of the new note. A
deliberate choice for an old tool is fine. An unnoticed one is not.

## Step 2 — install

```bash
brew install <name>              # formula
brew install --cask <name>       # application
```

Casks land in `~/Applications`, not `/Applications` — there is no standing
admin session here. That is what `HOMEBREW_CASK_OPTS` is for. If a password
prompt appears, the variable is not set: **abort**, do not push through with
admin rights.

## Step 3 — first launch belongs to a human

A freshly installed cask is quarantined. The first launch shows a dialog, and
**no tool can answer it**. Ask the human to start the app once and confirm.

**Never work around this by stripping the quarantine attribute.** That disables
the check instead of passing it.

## Step 4 — into the Brewfile, by hand

Without this step the install is gone at the next rebuild. This is the error
nobody notices for a year.

The file is under chezmoi management — **edit the source**, not the target:

```bash
chezmoi source-path ~/Brewfile
```

**Never run `brew bundle dump --force`.** It overwrites the comments, and the
commented-out lines there are deliberate — they are the rejections that would
otherwise be reinstalled.

Add one line to the **thematically matching block**, with a comment naming the
purpose — not repeating the tool name:

```ruby
cask "shottr"                     # screenshots with annotation and OCR
```

Then apply and verify:

```bash
chezmoi apply ~/Brewfile              # targeted, never a bare `chezmoi apply`
brew bundle check --file=~/Brewfile   # "dependencies are satisfied"
```

## Step 5 — write the note

Via `mac-write-note`; the rules there and in `CONVENTIONS.md` apply. Three
things are different for a **new** install:

- **Set `researched_on: <today>` and `research_finding:` honestly.** You just
  researched in step 1. That is load-bearing, not a guess.
- **`checked_by` is never `inherited`.** You were there. `machine` if
  `## Verify` passed; `human` if a person confirmed a dialog or used the app.
  For a cask it is almost always `human` — the first launch is a look.
- **`## Verify` must prove the install, not praise the app.** A version command,
  and for a GUI a `# by hand:` line for what no command can see.

On the folder: **one file = one decision, not one package.** A tool that carries
its own decision gets its own note. Another small utility with no story of its
own belongs in a collection note.

Fill in `requires:` — at minimum `[homebrew]`. And set a `[[link]]` back from at
least one existing note, otherwise the new note is an orphan and the checker
reports it.

## Finish

```bash
./check.py
git add -A && git commit    # one commit per install
```

One commit **per install**, not per session. A new install is a single event and
should be findable as one.
