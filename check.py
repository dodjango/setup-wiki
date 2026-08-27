#!/usr/bin/env python3
"""Check the wiki itself.

Every note carries a `## Verify` section that checks the *machine*. Nothing
checks the *wiki* — so this does. It reads every note in a section folder and
reports two kinds of finding:

  ERROR   the wiki is broken and something downstream will act on bad data:
          missing front matter or required fields, a duplicate id, a filename
          that disagrees with its id, a folder that disagrees with `section`,
          an unknown value in `commitment`, `checked_by` or `research_finding`,
          or body sections out of the prescribed order.

  notice  the wiki is usable but something is unfinished or claims too much:
          `commitment_reason` or `researched_on` missing where the schema asks
          for them, an active note without `## Verify`, a `[[link]]` to a note
          that does not exist yet, a note nothing links to, or `checked_by:
          machine` next to a check that says `# by hand:`.

Errors exit non-zero, notices do not. The last two lines are the tally and the
verification standing — how much of the wiki has actually been checked against
a machine, and how much was only carried over. That number is the wiki's own
debt and is printed on every run so it cannot be quietly ignored.

Run it with ./check.py — no arguments, no dependencies.
"""
import re
import sys
import pathlib
import collections

REQUIRED = {"id", "title", "section", "purpose", "status", "machines",
            "checked_on", "checked_by"}
COMMITMENTS = {"loose", "medium", "fixed"}
FINDINGS = {"none", "soft", "hard"}
CHECKERS = {"machine", "human", "inherited"}
SECTIONS = ["Why", "Setup", "Verify", "Decisions",
            "Alternatives", "Pitfalls", "Links"]

root = pathlib.Path(__file__).parent
# README carries no front matter and is not a note. The skills under .claude/
# are excluded by the leading-dot rule in wiki_files().
EXCLUDED = {"README.md"}


def wiki_files():
    for p in sorted(root.rglob("*.md")):
        rel = p.relative_to(root)
        if rel.parts[0].startswith(".") or str(rel) in EXCLUDED:
            continue
        yield p, rel


errors, notices = [], []


def without_code(text):
    """Strip code blocks and inline code — those hold examples, not content."""
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    return re.sub(r"`[^`]*`", "", text)


def headings(text):
    """Level-2 headings in the order they appear, code blocks removed.

    Order matters: the check below compares the sequence found here against
    SECTIONS. Matching on the first word lets a note write `## Why it was
    there` and still count as the Why section.
    """
    body = re.sub(r"```.*?```", "", text, flags=re.S)
    return [m.group(1) for m in re.finditer(r"^## (\S+)", body, re.M)]


def front_matter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    fields = {}
    for line in m.group(1).splitlines():
        if re.match(r"^\w+:", line):
            k, _, v = line.partition(":")
            fields[k.strip()] = v.strip()
    return fields


texts, front, notes = {}, {}, {}
for path, rel in wiki_files():
    text = path.read_text()
    texts[rel] = text
    fm = front_matter(text)
    if fm is None:
        errors.append(f"{rel}: no front matter")
        continue
    front[rel] = fm

    required = REQUIRED - ({"machines", "checked_by"}
                           if fm.get("section") == "meta" else set())
    missing = required - set(fm)
    if missing:
        errors.append(f"{rel}: required fields missing: {', '.join(sorted(missing))}")

    ident = fm.get("id")
    # A missing id is already reported above; indexing it would collapse
    # several such notes onto one key and produce a second, misleading error.
    if ident:
        if ident in notes:
            errors.append(f"{rel}: id '{ident}' already taken by {notes[ident]}")
        notes[ident] = rel
        if path.stem.lower() != ident and path.stem not in ("INDEX", "CONVENTIONS"):
            errors.append(f"{rel}: filename does not match id '{ident}'")

    if fm.get("section") not in ("meta", None) and rel.parent.name != fm.get("section"):
        errors.append(f"{rel}: section '{fm.get('section')}' does not match the folder")

    present = headings(text)
    commitment = fm.get("commitment")
    if fm.get("section") != "meta":
        if commitment not in COMMITMENTS:
            errors.append(f"{rel}: commitment missing or invalid")
        if commitment in ("medium", "fixed") and not fm.get("commitment_reason"):
            notices.append(f"{rel}: commitment '{commitment}' without commitment_reason")
        if commitment in ("loose", "medium") and not fm.get("researched_on"):
            notices.append(f"{rel}: commitment '{commitment}' without researched_on")
        if fm.get("research_finding") and fm["research_finding"] not in FINDINGS:
            errors.append(f"{rel}: research_finding '{fm['research_finding']}' unknown")
        if "Verify" not in present and fm.get("status") == "active":
            notices.append(f"{rel}: no '## Verify' section")
        if fm.get("checked_by") not in CHECKERS:
            errors.append(f"{rel}: checked_by must be {' | '.join(sorted(CHECKERS))}")
        # A check that needs a pair of eyes cannot have been done by a machine.
        if fm.get("checked_by") == "machine" and "# by hand:" in text:
            notices.append(f"{rel}: '## Verify' asks for a look, "
                           "checked_by says 'machine' — the check is incomplete")

    order = [h for h in present if h in SECTIONS]
    if order != sorted(order, key=SECTIONS.index):
        errors.append(f"{rel}: sections are not in the prescribed order: "
                      + " -> ".join(order))

links = collections.Counter()
for rel, text in texts.items():
    for target in re.findall(r"\[\[([^\]|]+)", without_code(text)):
        target = target.strip()
        links[target] += 1
        if target not in notes:
            notices.append(f"{rel}: link to '{target}' — not written yet")

for ident, rel in notes.items():
    if ident not in links and ident not in ("index", "conventions"):
        notices.append(f"{rel}: not linked from any other note")

for line in notices:
    print(f"notice:  {line}")
for line in errors:
    print(f"ERROR:   {line}")

# Counted over files, not over ids: a note with a missing or duplicate id must
# not quietly disappear from the tally it is being judged by.
standing = collections.Counter()
meta = 0
for rel in texts:
    section = front.get(rel, {}).get("section")
    if section == "meta":
        meta += 1
    else:
        standing[front.get(rel, {}).get("checked_by", "?")] += 1
print(f"\n{sum(standing.values())} notes ({meta} meta pages), "
      f"{len(errors)} errors, {len(notices)} notices")
print("Verification standing: "
      + ", ".join(f"{v}x {k}" for k, v in standing.most_common()))
sys.exit(1 if errors else 0)
