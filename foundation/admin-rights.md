---
id: admin-rights
title: What works without admin
section: foundation
purpose: The boundary this whole setup is built around — which paths are writable without a password prompt and which are not
status: active
commitment: fixed
commitment_reason: Company policy, not a preference
machines: [mac]
checked_on: 2026-08-25
checked_by: human
---

# What works without admin

## Why

Almost every macOS setup guide on the internet assumes you own the machine.
This one does not. Admin rights are temporary, granted for fifteen minutes at a
time through a self-service portal, and an install that stalls on a password
prompt after twelve minutes of unattended work has to be started over.

So the question "does this need admin?" is not a detail here. It is the design
constraint the rest of the wiki is shaped by, and the reason several notes
choose the second-best tool.

## Verify

```bash
id -Gn | tr ' ' '\n' | grep -qx admin && echo "admin right now" || echo "no admin"
touch /Applications/.probe 2>&1 | head -1     # expect: Permission denied
touch ~/Applications/.probe && rm ~/Applications/.probe
```

```
# by hand: confirm the self-service portal still grants temporary admin,
# and note how long the window is. It changed from 30 to 15 minutes once.
```

## Decisions

| Wanted | Needs admin? | What this setup does instead |
|---|---|---|
| Install apps | yes, into `/Applications` | `~/Applications`, see [[homebrew]] |
| Background job at login | yes, as a LaunchDaemon | LaunchAgent in `~/Library/LaunchAgents` |
| Write `/etc/hosts` | yes | Never needed so far; ssh config covers the cases |
| Add a CA to the system store | yes | The bundle lives in the home directory, see [[corporate-tls]] |
| Mount a network share | no | The user-level mount is enough |
| Change a system-wide default | yes | Every setting in [[macos-defaults]] is per-user, on purpose |

The last row is the one worth copying. All settings here are per-user not
because system-wide was impossible, but because per-user is individually
reversible and needs no password. Reversibility beat reach.

## Pitfalls

**A tool that fails without admin often fails quietly and misleadingly.** The
error is rarely "you need admin" — it is a timeout, an empty result, or a file
that appears to be written and is not. When something behaves impossibly, check
the permission boundary before you check your own logic.

## Links

[[homebrew]] · [[corporate-tls]] · [[macos-defaults]]
