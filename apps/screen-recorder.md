---
id: screen-recorder
title: Screen recorder — removed
section: apps
purpose: Was the video and GIF half of the screenshot toolchain; removed on 2026-04-03 and deliberately not replaced
status: rejected
commitment: loose
machines: [mac]
researched_on: 2026-04-03
research_finding: hard
checked_on: 2026-04-03
checked_by: machine
---

# Screen recorder — removed

> **Do not reinstall.** This note exists so that the tool is not read as a gap
> at the next rebuild and quietly reinstalled. It is missing on purpose.

## Why it was there

Screen video and GIF capture, because the screenshot tool in
[[small-tools]] cannot record.

## Verify

```bash
brew list --cask | grep -c screen-recorder      # 0
ls ~/Applications/ScreenRecorder.app 2>/dev/null || echo "not installed"
grep -n 'screen-recorder' ~/Brewfile            # only the commented-out line
```

## Decisions

**2026-04-03 — removed.** Three reasons, any one of which would have been
enough:

- **Effectively discontinued.** Last release three and a half years ago, last
  commit with substance eighteen months ago, several hundred open issues with
  no maintainer replies.
- **Security posture.** It ships an application runtime that went end-of-life
  in 2021, with dozens of published advisories against that version. On a
  company-managed machine that is not a detail.
- **Never used.** The output directory was empty after three weeks. The single
  attempt to use it produced an unusable file.

The alternatives research found this, on its first run. That is precisely what
`commitment: loose` is for: without the run, this tool would have been carried
into the next machine along with its dead runtime, because nothing about it
looked broken.

**No replacement purchased.** A commercial tool could cover both this and the
screenshot tool. For something that produced no usable output at all, spending
money is the wrong direction. Instead:

| Need | Route |
|---|---|
| Screen video | The built-in recorder, `Cmd-Shift-5` |
| GIF | `gifski` on demand |
| Screenshots, annotation, OCR | stays with the tool in [[small-tools]] |

**If the need comes back**, the question is asked again — with a maintained
candidate, not with this one.

## Pitfalls

Both of these outlive the tool, which is why they stay here:

- **The stop control lived only in the menu bar icon** — and the icon was hidden
  behind the display notch on this machine. Sending a signal to the process is
  not a substitute for a proper stop: without a clean finish the container atom
  is never written and the recording is unplayable.
- **It required the x86 translation layer despite shipping an arm64 binary**,
  because one bundled helper was x86-only and the launch failed with an
  architecture error. The translation layer stays installed; noted in
  [[macos-defaults]].

## Links

[[small-tools]] · [[brewfile]] · [[window-manager]] · [[macos-defaults]]
