---
id: macos-defaults
title: System settings
section: system
purpose: The settings that were changed away from Apple's defaults, each with the reason next to the value — so that a rebuild is a decision and not a re-click
status: active
commitment: fixed
commitment_reason: Muscle memory, and several of them are preconditions for other notes
install: system-setting
package: macos-defaults.sh
machines: [mac]
checked_on: 2026-04-14
checked_by: human
---

# System settings

## Why

Apps have a Brewfile. Settings had nothing — they lived as prose in this note,
which turned out to be the weakest part of the whole wiki. Prose carries
reasons effortlessly and values carelessly: there were 24 justified settings
here and only 6 named keys, and one of the six checks read the wrong domain.

So the reason is now a *field beside the value*, in a table the script reads:

```
Domain|Key|Type|Value|Mode|Reason
```

The script defaults to reading, not writing. At a rebuild, or after a macOS
update, it prints every setting whose value differs from the recorded one —
which is the moment the reason column earns its keep: keep it, adopt the new
default, or restore the old one, decided per line.

A worked example of that table and the script that reads it lives in
`examples/macos-defaults.sh` in this repository.

## Setup

```bash
~/.config/scripts/macos-defaults.sh            # read: compare, change nothing
~/.config/scripts/macos-defaults.sh --set      # write the recorded values
killall Finder Dock                            # some settings need this
```

Rows marked `hand` are never written by the script. They are settings whose
wrong value breaks half the interface, or which are not `defaults` keys at all;
the script only reports them.

## Verify

```bash
~/.config/scripts/macos-defaults.sh | grep -v ' ok$'    # empty = all as recorded
defaults read com.apple.finder FXDefaultSearchScope     # SCcf
defaults read NSGlobalDomain AppleShowAllExtensions     # 1
```

```
# by hand: the four rows marked `hand` — confirm them in System Settings.
```

## Decisions

**2026-04-14 — the reason belongs beside the value, not in a paragraph above
it.** This is the correction of the original design. A paragraph explaining why
the Finder should search the current folder is worth a great deal at rebuild
time and worth nothing to a checker, because it does not contain
`FXDefaultSearchScope`. Splitting them meant the wiki could not verify its own
most-repeated claim.

**2026-03-13 — every setting is per-user.** Not because system-wide was
impossible but because per-user needs no admin and is individually reversible.
See [[admin-rights]].

**2026-03-13 — `does not exist` is recorded as a value.** The way back from a
setting that was previously unset is `defaults delete`, not "write a 0". A
written `false` is not the same as "not set": Apple can change the default in
the next release, and then the written value silently freezes a state nobody
chose.

## Pitfalls

**The same domain exists on four levels, and reading the wrong one gives wrong
conclusions.** Per-user (`defaults read`), per-device (`defaults -currentHost
read`, invisible without the flag), company-managed
(`/Library/Managed Preferences/`, which *wins*), and system. If a setting keeps
reverting, look at the managed level first — that is a policy, not a
malfunction, and writing against it is a fight you lose on a schedule.

**Writing a value does not apply it.** `defaults write` changes the database,
not the running app. Reading the value back shows the new one immediately,
which is why it is so easy to believe the change took effect. Restart the app
and check the *effect*.

**Not everything is a `defaults` key.** Some switches exist only in the GUI and
overwrite anything written underneath them, within seconds. Some are filesystem
flags rather than preferences. If three attempts move nothing, the question is
no longer "which key" but "is it one at all".

**Apple changes its own defaults.** One setting here was found already flipped
without anyone having touched it. Two consequences: a setting nobody changed
can still have changed, and the recorded target value is the only way to ever
notice.

## Links

[[admin-rights]] · [[window-manager]] · [[bsd-gotchas]] · [[chezmoi]]
