#!/usr/bin/env python3
"""Export the spells registered under data/scripts/spells to a CSV file.

Columns: group, id, name, words, level, vocation.

The Lua files are parsed statically: each `local x = Spell(...)` starts a new
spell, and `x:group(...)`, `x:id(...)` etc. calls are read until the next one.
Files whose name starts with "#" are skipped, matching the server's script loader.
"""

import argparse
import csv
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SPELLS_DIR = REPO_ROOT / "data" / "scripts" / "spells"
FIELDS = ("group", "id", "name", "words", "level", "vocation")

SPELL_START_RE = re.compile(r"^\s*local\s+(\w+)\s*=\s*Spell\(", re.MULTILINE)
CALL_RE = re.compile(r"^\s*(\w+):(group|id|name|words|level|vocation)\((.*)\)\s*$", re.MULTILINE)
CONSTANT_RE = re.compile(r"^\s*local\s+(\w+)\s*=\s*(-?\d+|\"[^\"]*\")\s*$", re.MULTILINE)
STRING_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


def parse_args_list(raw, constants):
	"""Return the call arguments as strings, resolving simple local constants."""
	strings = STRING_RE.findall(raw)
	if strings:
		return strings
	value = raw.strip()
	return [constants.get(value, value)] if value else []


def parse_file(path):
	text = path.read_text(encoding="utf-8", errors="replace")
	constants = {m.group(1): m.group(2).strip('"') for m in CONSTANT_RE.finditer(text)}

	starts = list(SPELL_START_RE.finditer(text))
	for index, start in enumerate(starts):
		end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
		var = start.group(1)
		spell = dict.fromkeys(FIELDS, "")

		for call in CALL_RE.finditer(text, start.end(), end):
			if call.group(1) != var:
				continue
			field = call.group(2)
			args = parse_args_list(call.group(3), constants)
			if field == "group":
				spell[field] = "/".join(args)
			elif field == "vocation":
				# "elder druid;true" -> "elder druid" (the flag only controls description display)
				spell[field] = ", ".join(arg.split(";")[0] for arg in args)
			else:
				spell[field] = args[0] if args else ""

		if spell["name"] or spell["words"]:
			yield spell


def collect(spells_dir):
	rows = []
	for path in sorted(spells_dir.rglob("*.lua")):
		if path.name.startswith("#"):
			continue
		rows.extend(parse_file(path))
	rows.sort(key=lambda r: (r["group"], int(r["id"]) if r["id"].isdigit() else sys.maxsize, r["name"]))
	return rows


def main():
	parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
	parser.add_argument("-d", "--spells-dir", type=Path, default=DEFAULT_SPELLS_DIR, help="spells directory (default: %(default)s)")
	parser.add_argument("-o", "--output", default="output/spells.csv", help='output CSV path, or "-" for stdout (default: %(default)s)')
	args = parser.parse_args()

	if not args.spells_dir.is_dir():
		parser.error(f"spells directory not found: {args.spells_dir}")

	rows = collect(args.spells_dir)
	out = sys.stdout if args.output == "-" else open(args.output, "w", newline="", encoding="utf-8")
	try:
		writer = csv.DictWriter(out, fieldnames=FIELDS)
		writer.writeheader()
		writer.writerows(rows)
	finally:
		if out is not sys.stdout:
			out.close()

	if args.output != "-":
		print(f"Wrote {len(rows)} spells to {args.output}", file=sys.stderr)


if __name__ == "__main__":
	main()
