---
id: brewfile
title: Brewfile
section: foundation
purpose: The single inventory of everything installed by package manager — and the one file that decides whether a rebuild is complete or merely close
status: active
commitment: fixed
commitment_reason: Every install note writes into it; it is the machine-readable half of this wiki
install: manual
package: Brewfile
requires: [homebrew, chezmoi]
machines: [mac]
checked_on: 2026-08-25
checked_by: machine
---

# Brewfile

## Why

The wiki holds the reasoning; the Brewfile holds the list. Both are needed, and
they fail in opposite ways: a wiki without a list is an essay, a list without a
wiki is a script that nobody dares to change.

The Brewfile also answers the question a wiki cannot answer quickly — *is this
actually installed right now* — in one command.

## Setup

The file is under [[chezmoi]] management. Edit the source, never the target:

```bash
chezmoi source-path ~/Brewfile        # -> ~/.local/share/chezmoi/Brewfile
chezmoi apply ~/Brewfile              # targeted, never a bare `chezmoi apply`
brew bundle install --file=~/Brewfile
```

Entries go into the matching thematic block, with a comment that names the
*purpose*, not the tool:

```ruby
cask "shottr"                     # screenshots with annotations and OCR
```

## Verify

```bash
brew bundle check --file=~/Brewfile   # "The Brewfile's dependencies are satisfied."
brew leaves | wc -l                   # count of top-level formulae
```

## Decisions

**2026-08-22 — rejected entries stay in the file, commented out.** A tool that
was deliberately removed would otherwise be reinstalled by the next person
reading a "missing" tool as a gap. The comment names the date and the reason
and points at the note. So far one entry has needed it:

```ruby
# cask "kap"  # removed 2026-08-22, discontinued — see apps/kap.md
```

That is a small thing that pays every single rebuild.

## Pitfalls

**Never run `brew bundle dump --force`.** It regenerates the file from the
current state and destroys every comment in it — including the commented-out
rejections above, which then look like nothing more than absent packages. The
whole value of this file is in the comments; the package names are recoverable,
the reasons are not.

**A missing Brewfile entry is the error nobody notices for a year.** The tool
works, the machine is fine, and the gap only shows up on the next rebuild when
it is far too late to remember why the tool was there. This is why the install
skill treats the Brewfile edit as a separate step and not as cleanup.

## Links

[[homebrew]] · [[chezmoi]] · [[kap]] · [[search-tools]]
