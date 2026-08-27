---
id: bsd-gotchas
title: BSD userland gotchas
section: system
purpose: The differences that make a script written on Linux fail quietly on macOS, collected in one place because each one costs an hour exactly once
status: active
commitment: fixed
commitment_reason: It is the operating system; nothing to choose here
machines: [mac]
checked_on: 2026-08-25
checked_by: inherited
---

# BSD userland gotchas

## Why

Two of the three machines in this setup are Linux, and scripts move between
them. macOS ships the BSD versions of the standard tools, and the differences
share a nasty property: most of them do not produce an error. They produce a
different result.

Collected here rather than scattered, because the symptom never points at the
cause.

## Setup

The GNU variants are available and prefixed with `g`:

```bash
brew install coreutils gnu-sed grep findutils
gsed --version | head -1
```

They are deliberately *not* put ahead of the system tools on `PATH`. A script
that only works because of a shadowed binary is a script that fails on the next
machine — the point is to write portable code, not to hide the difference.

## Verify

```bash
sed --version 2>&1 | head -1        # "sed: illegal option" = BSD, as expected
command -v gsed gawk greadlink      # the GNU variants are present
/bin/bash --version | head -1       # 3.2 — see below
```

## Pitfalls

**`sed -i` needs an argument.** `sed -i 's/a/b/' f` on macOS treats `s/a/b/` as
the backup suffix. Portable form: `sed -i.bak` and delete the backup, or use
`gsed`.

**`/bin/bash` is version 3.2**, from 2007, and it stays that way for licensing
reasons. No associative arrays (`declare -A`), no `${x^^}`. Critically,
**`bash -n` does not catch this** — the script parses fine and dies at run time,
in whatever branch happens to use the feature. Iterate over `"$a:$b"` pairs and
split with `${pair%%:*}` instead.

**`csplit … '{*}'` is a GNU extension** and silently produces one file instead
of one per match. Split with `awk`.

**There is no `getent`.** Portable host lookup: `getent hosts` if it exists,
else `dscacheutil -q host -a name <h>` — whose output field is `ip_address:`,
not `ipv4_address:` — else a three-line Python fallback.

**Do not feed a host from a git remote URL into a resolver.** An ssh config
alias is not a DNS name. Resolve it with `ssh -G <host>` first, which gives the
real hostname and port. Together with the `getent` gap above, these two bugs
silently disabled a sync check for weeks: it reported "not reachable" and
skipped, on the machine where the alias was in use — and worked fine on the
machine that used a plain URL, which is why it went unnoticed.

**The filesystem is case-insensitive by default.** `git mv Foo foo` does
nothing visible locally and produces a confusing diff on a case-sensitive
machine.

## Links

[[fish]] · [[search-tools]] · [[neovim]] · [[macos-defaults]]
