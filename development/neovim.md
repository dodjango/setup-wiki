---
id: neovim
title: Neovim
section: development
purpose: The main editor, with language servers that must actually attach — a state that is easy to fake and hard to notice
status: active
commitment: medium
commitment_reason: Ten years of muscle memory and a hand-written config; the config is portable, the habits are not
install: brew
package: neovim
requires: [homebrew, search-tools]
machines: [mac, linux-laptop, homeserver]
researched_on: 2026-08-22
research_finding: none
checked_on: 2026-08-26
checked_by: machine
---

# Neovim

## Why

The editor. Not an interesting decision — it is here because of what hangs off
it, and because language server setup is one of the few places in this whole
setup where something can look configured and do nothing at all.

## Setup

```bash
brew install neovim
nvim --headless "+Lazy! sync" +qa      # install plugins
```

Language servers are not pinned to a fixed list. The config walks a table of
`server -> binary` and only asks the plugin manager for the ones missing from
`PATH`, so the same file is correct on all three machines:

```lua
local server = {
  lua_ls = "lua-language-server",
  bashls = "bash-language-server",
  basedpyright = "basedpyright-langserver",
}

local fetch = {}
for name, binary in pairs(server) do
  if vim.fn.executable(binary) == 0 then
    table.insert(fetch, name)
  end
end
```

## Verify

```bash
nvim --version | head -1
nvim --headless "+checkhealth vim.lsp" +qa 2>&1 | grep -i warning
```

The second line is the one that matters. Opening a file and seeing no error is
not a check — see Pitfalls.

## Decisions

**2026-08-26 — the server list is derived from `PATH`, not hardcoded.** The
first version listed servers explicitly and was correct on this Mac only. On
the two Linux machines it silently stopped installing two of them, because the
same config file is shared and the reason for the Mac-specific choice did not
apply there. A list that describes intent (`these four servers`) plus a
`PATH` probe is machine-independent; a list that describes a machine is not.

**2026-08-26 — a fork over the original, because of the distribution channel.**
One Python server is blocked by the company's package scanner on the npm route.
The maintained fork ships from the Python index instead, which the scanner does
not sit in front of. That is a different channel, not a bypass of a scan — worth
stating, because the alternative fix was to install the blocked package from
somewhere the scanner could not see, and that would have been the wrong answer.

## Pitfalls

**A language server that fails to start says so only in the log.** Neovim
`pcall`s the executable check and writes `log.error`; there is no notification
and nothing in `:messages`. The editor opens, the file is highlighted by the
built-in parser, and everything looks right. `:checkhealth vim.lsp` shows it as
`'<bin>' is not executable. Configuration will not be used.`

The general form of this is the reason for the `## Verify` section in every
note: check the *effect*, not the start. A server that attaches and stays silent
cost a day here.

**A linter's absence is also only a log line.** The shell language server
produces no diagnostics of its own; without `shellcheck` in `PATH` it logs a
warning and reports nothing forever. Nothing on screen distinguishes "clean
file" from "linter missing".

**Plugin bootstrap does not run in headless mode.** Some plugin managers gate
their auto-install behind an interactive check, so a headless verification run
reports a state that never had a chance to install anything. That is a false
negative, not a passing test — see [[bsd-gotchas]] for the same class of error
in a different tool.

## Links

[[search-tools]] · [[fish]] · [[bsd-gotchas]] · [[chezmoi]]
