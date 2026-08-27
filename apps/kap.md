---
id: kap
title: Kap — removed
section: apps
purpose: Was the video and GIF half of the screenshot toolchain; removed on 2026-08-22 and deliberately not replaced
status: rejected
commitment: loose
machines: [mac]
researched_on: 2026-08-22
research_finding: hard
checked_on: 2026-08-22
checked_by: machine
---

# Kap — removed

> **Do not reinstall.** This note exists so that Kap is not read as a gap at the
> next rebuild and quietly reinstalled. It is missing on purpose.

## Why it was there

Screen video and GIF capture — "Screenpresso, part two", because Shottr in
[[small-tools]] cannot record video.

## Verify

```bash
brew list --cask | grep -c kap        # 0
ls ~/Applications/Kap.app 2>/dev/null || echo "not installed"
grep -n 'cask "kap"' ~/Brewfile       # only the commented-out line
```

## Decisions

**2026-08-22 — removed.** Three reasons, any one of which would have been
enough:

- **Effectively discontinued.** Last release v3.6.0 on **2022-10-27**, last
  commit 2024-11-12, 262 open issues.
- **Security posture.** `package.json` pins **Electron 13.6.9** from 2021, long
  past end of life; OSV lists 40 advisories against it. On a company-managed
  machine that is not a detail.
- **Never used.** `Bilder/Kaptures` was empty after eleven days — not a single
  recording. The one attempt to use it produced an unusable file.

**No replacement bought.** CleanShot X (~29 €) could cover Shottr and Kap
together and had been in the running for a while. For a tool that produced no
usable output at all, spending money is the wrong direction. Instead:

| Need | Route |
|---|---|
| Screen video | `Cmd-Shift-5` — built in, no Electron, no menu bar problem |
| GIF | `gifski` via Homebrew when needed |
| Screenshots, annotation, OCR | stays with Shottr, see [[small-tools]] |

**If the need comes back**, the question is asked again — with a maintained
candidate, not with this one.

## Alternatives

**2026-08-22 — hard finding, on the first run of the alternatives research.**
The release history, the commit log and the advisories against the bundled
Electron are under `## Decisions` above, because they became the reason for
removal rather than staying a research note.

This is precisely what `commitment: loose` is for. Nothing about Kap looked
broken from the outside — it launched, it had a menu bar icon, it was in the
Brewfile. Without a run that asks the question on a schedule, it would have
been carried into the next machine along with Electron 13.

## Pitfalls

Both of these outlive the tool, which is why they stay here:

- **The stop control lived only in the menu bar icon** — and on this machine
  that icon disappeared behind the display notch. Sending `pkill -INT` is not a
  substitute for a proper stop: without a clean finish the `moov` atom is never
  written and the recording is unplayable.
- **Rosetta 2 was required despite Kap being arm64**, because its bundled
  permission-check helper was x86_64 and the launch failed with `EBADARCH`
  (error −86). Rosetta stays installed; noted in [[macos-defaults]].

## Leftovers

`~/Library/Application Support/Kap` is still there — only `config.json`,
harmless. Can go at some point.

## Links

[[small-tools]] · [[brewfile]] · [[rectangle]] · [[macos-defaults]]
