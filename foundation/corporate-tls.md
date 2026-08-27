---
id: corporate-tls
title: Corporate TLS interception
section: foundation
purpose: The company proxy terminates TLS, so every tool needs the internal root certificate — and the wrong way to give it breaks everything at once
status: active
commitment: fixed
commitment_reason: Company network policy. Without it no download, no package manager, no API call
install: homegrown
package: update-corporate-ca.sh
requires: [homebrew]
machines: [mac, linux-laptop]
checked_on: 2026-08-25
checked_by: machine
---

# Corporate TLS interception

## Why

The company proxy terminates TLS and re-signs it with an
internal root. Anything that verifies certificates against its own bundle —
which is most things — fails with a certificate error that reads like a broken
server. It is not. It is the network.

This note exists because the failure looks identical to a dozen unrelated
problems, and because the obvious fix took this machine out of service for a
day.

## Setup

The bundle is assembled from the system keychain into a file in the home
directory. No admin needed, and every tool can be pointed at one path:

```bash
~/.config/scripts/update-corporate-ca.sh      # writes ~/.config/certs/corporate-ca.pem
```

```fish
# ~/.config/fish/conf.d/certs.fish
set -gx NODE_EXTRA_CA_CERTS $HOME/.config/certs/corporate-ca.pem
set -gx CURL_CA_BUNDLE      $HOME/.config/certs/corporate-ca.pem
set -gx SSL_CERT_FILE       $HOME/.config/certs/corporate-ca.pem
```

The script also warns when a root has fewer than 60 days left. That warning is
the only reason the last rotation was not a surprise.

## Verify

```bash
openssl x509 -in ~/.config/certs/corporate-ca.pem -noout -enddate
curl -sS -o /dev/null -w '%{http_code}\n' https://registry.npmjs.org/   # 200
node -e "require('https').get('https://registry.npmjs.org/',r=>console.log(r.statusCode))"
```

All three, not just the first. A bundle that exists is not a bundle that is
being read.

## Decisions

**2026-08-12 — one bundle in the home directory, not an entry per tool.** Each
tool wants its own variable, but they can all point at the same file. One file
means one rotation.

**2026-08-13 — never export `NODE_OPTIONS="--use-system-ca"` globally.**
Rejected the day after it was introduced, see Pitfalls. It is listed here as a
rejected decision rather than deleted, because it is the answer every search
result gives.

## Pitfalls

**`NODE_OPTIONS="--use-system-ca"` took the machine out of service for a day.**
The flag was added on the assumption that native binaries ignore `NODE_OPTIONS`.
They do not — a native CLI read the variable, could not honour the flag, and
fell back to an *empty* trust store. Every TLS connection failed, including the
tool's own login and auto-update, so it could not even be repaired in place.

Isolated by A/B with `env -u`:

| Variable | Result |
|---|---|
| `NODE_EXTRA_CA_CERTS=<bundle>` alone | works |
| `NODE_USE_SYSTEM_CA=1` alone | works |
| `NODE_OPTIONS=--use-system-ca` alone | every TLS connection fails |

If a single tool genuinely needs the flag, scope it to that tool. Never export
it.

**Never export `REQUESTS_CA_BUNDLE` globally either**, for the same class of
reason: a stale path there makes Python fail closed, and the error blames the
server.

**A certificate error is not evidence of a broken server.** On this network it
is the least likely explanation. Check the bundle first.

## Links

[[homebrew]] · [[admin-rights]] · [[chezmoi]] · [[gopass]]
