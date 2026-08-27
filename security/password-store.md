---
id: password-store
title: Password store
section: security
purpose: Where every credential in this setup lives, so that no script, no dotfile and no note ever has to hold one
status: active
commitment: fixed
commitment_reason: Hangs off a hardware key and off a git-synced store shared with two other machines
install: brew
package: gopass
requires: [homebrew]
machines: [mac, linux-laptop, homeserver]
checked_on: 2026-04-11
checked_by: human
---

# Password store

## Why

Every rule in this wiki about not writing credentials into files needs somewhere
for the credentials to go instead. This is that somewhere: a GPG-encrypted
store, synced over git, unlocked by a hardware key.

The important property is not the encryption. It is that scripts can *resolve*
a secret at run time from a stable path, so the secret never has to exist as
text on disk, and the path — which is not a secret — can be written into the
wiki freely.

## Setup

```bash
brew install gopass pinentry-mac
gopass clone git@github.com:<you>/pass.git
```

Scripts read at run time and degrade gracefully when the agent cache is cold:

```bash
token="$(gopass show -o service/api-token 2>/dev/null)" || {
    echo "password store locked — skipping the upload step"
    exit 0
}
```

Skipping beats failing here: a scheduled job that exits non-zero because a
human has not unlocked their key looks like a broken job.

## Verify

```bash
gopass ls | head
gpg --card-status | grep -i 'reader\|serial'
```

```
# by hand: run `gopass show -o <a path>` once in a real terminal and confirm
# the pinentry window appears. This cannot be checked non-interactively — see Pitfalls.
```

## Decisions

**2026-03-16 — paths in the wiki, values nowhere.** A note may say "the token
is in the store under `service/api-token`". That sentence is useful, is not a
secret, and survives a rotation. A redacted value in a note is worse than
nothing: it looks like documentation and ages into a lie.

## Pitfalls

**Decryption needs a real interactive terminal, and its absence produces a
wrong conclusion rather than a clear failure.** Run from a non-interactive
shell — a scheduled job, an agent's tool call — pinentry has nowhere to draw,
and the operation fails with something unhelpful like `signal: killed`. The
failure says nothing about whether the store is reachable or the key is
authorized. Unlock once in a real terminal; the agent caches it for a while.

**The same trap applies to passphrase-protected SSH keys, and there it has
caused real damage.** Testing a key non-interactively disables the passphrase
prompt, so an encrypted key always fails to authenticate — and that failure is
routinely read as "this key has no access", leading to a request for new
credentials that were never needed. Check `ssh-keygen -y -P "" -f <key>` first:
if that fails, the key is encrypted and a non-interactive test cannot judge it.

**Never infer missing authorization from a non-interactive auth failure**, and
never propose new credentials on that basis. This is the same class of error as
the language server in [[neovim]] and the keychain lookup in
[[network-shares]]: a tool that structurally cannot see something reports that
it is not there.

**Short secrets need the interactive insert.** Piping a PIN on the command line
puts it into shell history and into `ps` output for every process on the
machine.

## Links

[[chezmoi]] · [[corporate-tls]] · [[network-shares]] · [[neovim]]
