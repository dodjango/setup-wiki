---
name: mac-research
description: Use to research whether the tools in this wiki are still the right choice — picks the five notes with the oldest researched_on, checks whether each tool is alive, archived, superseded or vulnerable, and writes findings back. Use this skill for the weekly alternatives run, or whenever someone asks "is X still current" or "is there something better than Y".
---

# Researching alternatives

This is the part an install script cannot do: the question of whether a tool is
still the right choice at all.

## Selection

Five notes per run, **oldest `researched_on` first**:

```bash
git ls-files '*/*.md' ':!.claude/*' \
  | xargs grep -l 'commitment: \(loose\|medium\)' \
  | xargs grep -H 'researched_on:' | sort -t: -k3 | head -5
```

`git ls-files` rather than `grep -r`: the latter also walks `.claude/skills/`
and `README.md`, which are not notes. The exclusion is not optional — in a git
pathspec `*` crosses `/`, so `'*/*.md'` on its own matches
`.claude/skills/mac-install/SKILL.md` too. What is left is exactly the notes in
their section folders; `INDEX.md` and `CONVENTIONS.md` are out because they sit
at the root.

**If every note carries the same `researched_on`** — right after the wiki was
created, for instance — there is no "oldest". Then alphabetical order applies,
and you work through the whole wiki over the following weeks.

**Never research `commitment: fixed`.** Hardware, a company policy or half a
dozen other notes hang off those — an alternative is not an option, only the
version is interesting.

## What you check

For each tool in the note (individually, in a collection note):

1. **Is it alive?** Last release, last commit with substance, open issues with
   replies. A repository whose latest commit only touches issue templates is not
   maintained.
2. **Is it archived or discontinued?** Explicitly, in the README or as a
   repository status.
3. **Is there a named successor?** `exa → eza` is the archetype.
4. **Known vulnerabilities?**
5. **Is there something better?** Only relevant if you can name the advantage in
   one sentence. "More modern" is not an advantage.

Also check whether the **version in the note** still matches the current one —
and whether the OS has meanwhile grown what the tool provides.

## What you write

Two places, always both:

**Front matter** — the machine-readable status:

```yaml
researched_on: <today>
research_finding: none | soft | hard
```

**Body** — the `## Alternatives` section, between `## Decisions` and
`## Pitfalls`. **Append, do not replace**: the history of the research is itself
information. Every entry dated, in two to four sentences: what was checked, what
was found, and why it is (not) enough.

On `research_finding: none` you write **no** section — only bump the date.
Otherwise the file fills up with "nothing new" lines.

## Reporting

| Finding | What happens |
|---|---|
| `none` | only bump `researched_on`. Silent |
| `soft` | extend `## Alternatives`. **Silently** — no message |
| `hard` | extend **and** report |

**Hard** means: discontinued, archived, security hole, or last release over two
years old.

**Why the split is strict:** across the loosely committed notes there is
*always* something newer somewhere — and each of them covers several tools. If
every soft finding reported, the channel would be dead within two weeks, and
with it every other notification that uses it.

## Finish

```bash
./check.py
git add -A && git commit -m "Research: <notes>"
```

With no hard findings you commit silently and report nothing.
