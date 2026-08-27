---
id: search-tools
title: Search, jump, display
section: shell
purpose: Modern replacements for the Unix classics — faster, coloured, with defaults worth having
status: active
commitment: loose
install: brew
package: fzf zoxide eza bat fd ripgrep sd
requires: [fish]
machines: [mac, linux-laptop, homeserver]
researched_on: 2026-04-03
research_finding: none
checked_on: 2026-04-11
checked_by: machine
---

# Search, jump, display

## Why

Seven small tools, one decision: replace the standard commands with variants
that are faster and give usable output without a chain of flags. None of them
carries anything else — which is exactly why it is worth looking every year or
two at what has grown up since.

| Tool | replaces | for |
|---|---|---|
| `fzf` | — | Fuzzy selection in the shell |
| `zoxide` | `cd` | Jumps to frequently visited directories by substring |
| `eza` | `ls` | Colours, git status, tree view |
| `bat` | `cat` | Syntax highlighting and paging |
| `fd` | `find` | Sane defaults, respects `.gitignore` |
| `ripgrep` | `grep -r` | Substantially faster in repositories |
| `sd` | `sed` for substitutions | Readable syntax, no BSD/GNU split |

## Setup

```bash
brew install fzf zoxide eza bat fd ripgrep sd
```

Aliases and the `zoxide init` line live in [[fish]] under `conf.d/`.

## Verify

```fish
for w in fzf zoxide eza bat fd rg sd
    command -v $w > /dev/null; or echo "missing: $w"
end
```

## Decisions

**`exa` → `eza`.** `exa` is no longer maintained; `eza` is the active fork. The
older machine still had `exa` installed and was migrated during a sync.

**This is the case this wiki exists for.** `commitment: loose` means: at the
next rebuild, please check whether any of these seven has gone quiet or been
overtaken. Nothing depends on them, so the check is cheap and the swap is
cheap.

## Links

[[fish]] · [[bsd-gotchas]]
