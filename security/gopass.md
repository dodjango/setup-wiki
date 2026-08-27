---
id: gopass
title: gopass
section: security
purpose: Password store — GPG-encrypted, synced over git between all three machines, so that no script, dotfile or note ever has to hold a credential
status: active
commitment: fixed
commitment_reason: Hardware token, three machines on one git repository, and scripts resolve their secrets here at run time
install: brew
package: gopass
requires: [homebrew]
machines: [mac, linux-laptop, homeserver]
checked_on: 2026-08-25
checked_by: human
---

# gopass

## Why

Every rule in this wiki about not writing credentials into files needs
somewhere for the credentials to go instead. This is that somewhere: a store
that needs no third-party service, syncs over git between the three machines,
and whose encryption hangs off a hardware token — the private key never leaves
the card.

The store is the foundation for other things and therefore not interchangeable:
update scripts fetch tokens from it, browser logins live in it, and the alert
of the dotfiles sync check uses it too.

## Setup

```bash
brew install gopass gnupg pinentry-mac
gopass clone git@github.com:<you>/pass.git
```

Scripts read at run time and degrade gracefully when the agent cache is cold:

```bash
token="$(gopass show -o telegram/bot-token 2>/dev/null)" || {
    echo "password store locked — skipping the notification"
    exit 0
}
```

Skipping beats failing here: a scheduled job that exits non-zero because a
human has not unlocked their key looks like a broken job.

## Verify

```bash
gopass ls --flat | wc -l                     # 378 entries (2026-08-25)
gopass show -o telegram/bot-token | wc -c    # a real decryption, > 10 bytes
```

```
# by hand: run the second command once in a real terminal and confirm the
# pinentry window appears. It cannot be checked non-interactively — see Pitfalls.
```

## Decisions

**2026-08-15 — no secrets in chezmoi, enforced rather than advised.** Neither
the source tree nor a rendered file may contain a password. That rules out
`{{ gopass "..." }}` template calls, because the rendered target file would hold
the plaintext. Secrets are resolved at **run** time inside the script, and the
script exits cleanly when the gpg-agent is cold. A scheduled job checks for
violations. See [[chezmoi]].

**Paths in the wiki, values nowhere.** A note may say "the token is in the store
under `telegram/bot-token`". That sentence is useful, is not a secret, and
survives a rotation. A redacted value in a note is worse than nothing: it looks
like documentation and ages into a lie.

## Pitfalls

**Decryption needs a real interactive terminal, and its absence produces a
wrong conclusion rather than a clear failure.** Run from a non-interactive
shell — a scheduled job, an agent's tool call — pinentry has nowhere to draw and
the operation fails with `Decryption failed: signal: killed`. That says nothing
about whether the store is reachable or the key is authorized. Unlock once by
hand; the agent caches it for a while.

**The same trap applies to passphrase-protected SSH keys, and there it has
caused real damage.** A non-interactive test disables the passphrase prompt, so
an encrypted key always fails to authenticate — and that failure gets read as
"this key has no access", leading to a request for credentials that were never
needed. Check `ssh-keygen -y -P "" -f <key>` first: if that fails, the key is
encrypted and a non-interactive test cannot judge it.

**Never infer missing authorization from a non-interactive auth failure**, and
never propose new credentials on that basis. Same class as the language server
in [[neovim]] and the keychain lookup in [[network-shares]]: a tool that
structurally cannot see something reports that it is not there.

**`gopass recipients add <fpr>` fails silently without the global `--yes` flag.**

**Short secrets need the interactive insert.** `gopass insert -f <path>` with
its hidden prompt; piping a PIN on the command line puts it into shell history
and into `ps` output for every process on the machine.

## Links

[[chezmoi]] · [[corporate-tls]] · [[network-shares]] · [[neovim]]
