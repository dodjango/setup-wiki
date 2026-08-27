---
id: rectangle
title: Rectangle
section: apps
purpose: Snapping windows to halves and quarters by keyboard — the replacement for Win+arrow
status: active
commitment: loose
install: brew-cask
package: rectangle
requires: [homebrew]
machines: [mac]
researched_on: 2026-08-22
research_finding: none
checked_on: 2026-08-24
checked_by: human
---

# Rectangle

## Why

macOS has no keyboard shortcut for "left half of the screen". After twenty
years of `Win`+arrow that is a missing reflex, not a missing feature — which is
why this is `loose`: any tool that restores the reflex will do.

## Setup

```bash
brew install --cask rectangle
```

Autostart via `launchOnLogin`, additionally registered as a login item, the
alternative shortcut scheme active. The accessibility permission has to be
granted by hand — no command can answer that dialog.

Shortcuts: `Ctrl+Opt+arrow` for halves, `U I J K` for quarters, `Enter` to
maximise.

## Verify

```bash
brew list --cask --versions rectangle
defaults read com.knollsoft.Rectangle launchOnLogin        # 1
pgrep -qf /Rectangle.app && echo running
```

```
# by hand: Ctrl+Opt+<left> must put the window on the left half, U I J K on the
#          quarters, Enter maximises.
# by hand: after a bundle update, check this first — the accessibility
#          permission can be lost in the process. Confirmed by hand on
#          2026-08-24 after the jump 0.98 -> 0.99: shortcuts work, the
#          permission survived.
```

This note is `checked_by: human` for exactly that reason. Every command above
can pass on a machine where the shortcuts do nothing.

## Decisions

**2026-08-18 — a small tool over a tiling window manager.** A full tiling
manager replaces a reflex with a new one, which is the opposite of the point
here. Grouping in Stage Manager was rejected for the same reason and is off
in [[macos-defaults]].

## Pitfalls

**An accessibility permission can be revoked by an update without any
notification.** The app still runs, the menu bar icon is still there, the
shortcuts do nothing. Because the check for this is a keypress and not a
command, it is one of the few things in this wiki a machine genuinely cannot
verify.

## Links

[[homebrew]] · [[macos-defaults]] · [[kap]]
