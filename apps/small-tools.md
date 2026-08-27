---
id: small-tools
title: Small tools
section: apps
purpose: Four utilities with no story of their own — one file, because they are one decision, not four
status: active
commitment: loose
install: brew-cask
package: shottr keka marta espanso
requires: [homebrew]
machines: [mac]
researched_on: 2026-04-10
research_finding: none
checked_on: 2026-04-10
checked_by: inherited
---

# Small tools

## Why

The convention in [[conventions]] says one file per *decision*, not per package.
These four were one decision — "replace the handful of Windows utilities that
are actually missed" — and none of them has an argument attached.

| Tool | Replaces | For |
|---|---|---|
| Shottr | Screenpresso | Screenshots with annotation, scrolling capture, OCR |
| Keka | 7-Zip | Unpacking archives the Finder refuses |
| Marta | Total Commander | Two-pane file manager |
| Espanso | AutoHotkey | Text expansion |

If any one of them grows a pitfall or a rejected alternative, it moves out into
its own note. That is the rule, and it is worth stating here because collection
notes are where wikis go to rot.

## Setup

```bash
brew install --cask shottr keka marta espanso
```

## Verify

```bash
for a in Shottr Keka Marta Espanso; do
  ls ~/Applications/$a.app >/dev/null 2>&1 || echo "missing: $a"
done
```

```
# by hand: type an Espanso trigger in any text field and confirm it expands.
# Espanso needs accessibility permission and fails silently without it.
```

## Decisions

**2026-03-18 — Espanso's config is not at its default path.** It is symlinked
into the shared dotfiles directory so the same expansions work on the Linux
machines. The default location holds only the link.

## Links

[[homebrew]] · [[screen-recorder]] · [[window-manager]] · [[chezmoi]]
