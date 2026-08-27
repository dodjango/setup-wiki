#!/usr/bin/env python3
"""Check the wiki's own structure: front matter, ids, links, section order.

Every note has a `## Verify` section that checks the *machine*.
This script checks the *wiki*. Run it with ./check.py
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
# README and the skills are not wiki content and carry no front matter.
EXCLUDED = {"README.md"}


def wiki_files():
    for p in sorted(root.rglob("*.md")):
        rel = p.relative_to(root)
        if rel.parts[0].startswith(".") or str(rel) in EXCLUDED:
            continue
        yield p, rel


errors, notices = [], []


def without_code(text):
    """Strip code blocks and inline code — those hold examples, not links."""
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    return re.sub(r"`[^`]*`", "", text)


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


notes = {}
for path, rel in wiki_files():
    text = path.read_text()
    fm = front_matter(text)
    if fm is None:
        errors.append(f"{rel}: no front matter")
        continue

    required = REQUIRED - ({"machines", "checked_by"}
                           if fm.get("section") == "meta" else set())
    missing = required - set(fm)
    if missing:
        errors.append(f"{rel}: required fields missing: {', '.join(sorted(missing))}")

    ident = fm.get("id", "")
    if ident in notes:
        errors.append(f"{rel}: id '{ident}' already taken by {notes[ident]}")
    notes[ident] = rel

    if ident and path.stem.lower() != ident and path.stem not in ("INDEX", "CONVENTIONS"):
        errors.append(f"{rel}: filename does not match id '{ident}'")

    if fm.get("section") not in ("meta", None) and rel.parent.name != fm.get("section"):
        errors.append(f"{rel}: section '{fm.get('section')}' does not match the folder")

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
        if "## Verify" not in text and fm.get("status") == "active":
            notices.append(f"{rel}: no '## Verify' section")
        if fm.get("checked_by") not in CHECKERS:
            errors.append(f"{rel}: checked_by must be {' | '.join(sorted(CHECKERS))}")
        # A check that needs a pair of eyes cannot have been done by a machine.
        if fm.get("checked_by") == "machine" and "# by hand:" in text:
            notices.append(f"{rel}: '## Verify' asks for a look, "
                           "checked_by says 'machine' — the check is incomplete")

    found = [s for s in SECTIONS if f"## {s}" in text]
    if found != sorted(found, key=SECTIONS.index):
        errors.append(f"{rel}: sections are not in the prescribed order")

links = collections.Counter()
for path, rel in wiki_files():
    for target in re.findall(r"\[\[([^\]|]+)", without_code(path.read_text())):
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
standing = collections.Counter()
for path, rel in wiki_files():
    fm = front_matter(path.read_text()) or {}
    if fm.get("section") != "meta":
        standing[fm.get("checked_by", "?")] += 1
print(f"\n{len(notes)} notes, {len(errors)} errors, {len(notices)} notices")
print("Verification standing: "
      + ", ".join(f"{v}x {k}" for k, v in standing.most_common()))
sys.exit(1 if errors else 0)
