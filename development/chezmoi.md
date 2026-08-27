---
id: chezmoi
title: chezmoi for the dotfiles
section: development
purpose: One dotfiles repository across three machines, with per-machine differences as templates instead of forks — and no credential anywhere in it
status: active
commitment: fixed
commitment_reason: All three machines pull from it; a move would mean re-establishing every config file by hand
install: brew
package: chezmoi
requires: [homebrew, password-store]
machines: [mac, linux-laptop, homeserver]
checked_on: 2026-04-11
checked_by: machine
---

# chezmoi for the dotfiles

## Why

Three machines, one Mac and two Linux, want the same shell configuration and
differ in perhaps a tenth of it. Symlink farms handle the same tenth badly:
either you fork the file and the two copies drift, or you branch inside the file
and it stops being readable.

chezmoi keeps one source tree, renders per machine, and — the part that matters
most here — makes the difference explicit as a template condition rather than
implicit as a file that only exists on one host.

## Setup

```bash
brew install chezmoi
chezmoi init --apply git@github.com:<you>/dotfiles.git
```

Naming in the source tree carries meaning:

| Prefix | Effect |
|---|---|
| `dot_` | becomes a leading `.` |
| `executable_` | target gets the execute bit |
| `private_` | target gets mode 0600 |
| `symlink_` | target becomes a symlink |
| `*.tmpl` | rendered as a Go template |

Machine-specific files that must not land elsewhere go into `.chezmoiignore`,
under the matching OS block.

## Verify

```bash
chezmoi doctor                     # no "error" lines
chezmoi diff | head                # empty = target matches source
chezmoi source-path ~/.gitconfig   # resolves to the source file
```

## Decisions

**2026-03-14 — no credentials in the source tree, and this is enforced, not
advised.** Neither the source tree nor any file chezmoi renders may hold a
secret. That specifically rules out template calls that pull a secret from the
password store: the rendered target file then holds the plaintext, which is the
exact thing the password store exists to prevent.

Secrets are resolved at *run* time inside the script that needs them, and the
script degrades gracefully when the agent cache is cold — log the reason and
skip, do not fail the run. A scheduled job greps both repositories for private
key markers.

**2026-03-14 — the justfile is a template with swapped delimiters.** just uses
`{{ }}` itself, so the template is configured for `[[ ]]`. Without that, every
just variable is eaten by the renderer, and the failure is silent.

## Pitfalls

**`chezmoi apply` with no argument applies everything pending.** Including
unrelated changes you have not reviewed yet, from a machine you were not
thinking about. When one specific file should land, target it:
`chezmoi apply ~/path/to/target`.

**Editing the target instead of the source is the classic loss.** The change
works, survives a reboot, and disappears at the next `apply`. `chezmoi
source-path <file>` before every edit, or use `chezmoi edit`.

**A tool that rewrites a file in place gives it a new inode.** Anything that
bind-mounts that file — a container, for instance — keeps pointing at the old
one and can end up creating an empty file in its place. For any file that is
mounted somewhere, write via a temp file and `cat > target` to keep the inode.

## Links

[[fish]] · [[brewfile]] · [[password-store]] · [[corporate-tls]] · [[macos-defaults]]
