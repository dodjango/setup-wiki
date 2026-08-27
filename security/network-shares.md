---
id: network-shares
title: Network shares
section: security
purpose: Access to the two company file shares, mounted on demand, with the credential step left to a human
status: active
commitment: fixed
commitment_reason: Company file server and VPN; there is no alternative to choose between
install: homegrown
package: network-shares.sh
requires: [password-store, chezmoi]
machines: [mac]
checked_on: 2026-04-13
checked_by: human
---

# Network shares

## Why

Two shares on the company file server hold everything exchanged with colleagues
who do not use git. The Finder can mount them, but the Finder's error message
when the VPN is down says "authentication failed" — which sends everyone
looking at their password instead of their network connection.

So the point of this note is not the mount. It is the reachability check in
front of it.

## Setup

Configuration lives in `~/.config/scripts/network-shares.sh` under
[[chezmoi]], with a thin task-runner recipe in front of it. The script checks
the route before it tries anything:

```bash
if ! nc -z -G 3 "$SERVER" 445 >/dev/null 2>&1; then
    echo "File server $SERVER is not reachable on port 445."
    echo "Usually this means the VPN is not connected."
    exit 0
fi
```

It exits *successfully*. A missing precondition is not a defect, and a red
error trains people to ignore the output.

The mount itself goes through the OS mount API rather than a direct SMB call,
so the keychain, DFS referrals and `/Volumes` behave the way the Finder makes
them behave — and so that no password ever lands in `argv`, where `ps` would
show it to every process on the machine.

## Verify

```bash
nc -z -G 3 <fileserver> 445 && echo reachable
mount | grep smbfs
ls /Volumes/Exchange >/dev/null && echo mounted
```

```
# by hand: eject one share in the Finder and run the recipe again. It must
# remount without prompting — that is the only real proof the credential
# was stored. See Pitfalls.
```

## Decisions

**2026-04-13 — on demand, not at login.** A laptop is usually *not* on the
company network when you log in, and the VPN does not come back on its own
after the lid has been closed. An automation that mostly fails is noise. The
reachability check is written so that a login agent can be added later without
restructuring anything.

**2026-04-13 — the credential step belongs to a human.** The script never asks
for a password and never receives one. A person mounts the share once, ticks
"remember in keychain", and every later mount is silent.

## Pitfalls

**`security find-internet-password` does not find this credential, even though
it works.** The command cannot read the data-protection keychain, so it returns
nothing for an entry that is plainly there. Reading that as "the password was
not saved" is wrong — and it is the third instance of the same mistake in this
wiki, after the SSH key in [[password-store]] and the language server in
[[neovim]].

The lesson generalises past all three: **a tool reporting nothing is only
evidence when the tool can see.** Verify by behaviour instead — eject, remount,
observe no prompt.

**`ping` is useless here.** ICMP is filtered on the company network, so a failed
ping proves nothing about a reachable host. Probe the port.

## Links

[[password-store]] · [[chezmoi]] · [[admin-rights]]
