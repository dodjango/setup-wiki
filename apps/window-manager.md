---
id: window-manager
title: Window manager
section: apps
purpose: Snapping windows to halves and quarters by keyboard, the way the other operating system does it out of the box
status: active
commitment: loose
install: brew-cask
package: rectangle
requires: [homebrew]
machines: [mac]
researched_on: 2026-04-10
research_finding: soft
checked_on: 2026-04-10
checked_by: human
---

# Window manager

## Why

macOS has no keyboard shortcut for "left half of the screen". After twenty
years of `Win`+arrow that is a missing reflex, not a missing feature — which is
why this is `loose`: any tool that restores the reflex will do.

## Setup

```bash
brew install --cask rectangle
```

The first launch needs a human: the app asks for accessibility permission in
System Settings, and that dialog cannot be answered by a command.

## Verify

```bash
defaults read com.knollsoft.Rectangle launchOnLogin      # 1
ls ~/Applications/Rectangle.app >/dev/null && echo installed
```

```
# by hand: Ctrl+Opt+<left> must snap the front window to the left half.
# by hand: confirm the accessibility permission is still granted after a
#          macOS update — it is silently revoked by some upgrades.
```

This note is `checked_by: human` for exactly that reason. Every command above
can pass on a machine where the shortcut does nothing.

## Decisions

**2026-03-17 — a small tool over a tiling window manager.** A full tiling
manager was tried for two days. It is better at what it does and it replaces a
reflex with a new one, which is the opposite of the point here.

## Alternatives

**2026-04-10 — soft finding.** Two alternatives are alive and comparable; one is
paid, one requires disabling a system integrity feature. Neither is worth a
switch for a tool that has cost nothing and broken nothing. Recorded so the next
research run does not treat this as an open question.

## Pitfalls

**An accessibility permission can be revoked by a system update without any
notification.** The app still runs, the menu bar icon is still there, the
shortcuts do nothing. Because the check for this is a keypress and not a
command, it is one of the few things in this wiki a machine genuinely cannot
verify.

## Links

[[homebrew]] · [[macos-defaults]] · [[screen-recorder]]
