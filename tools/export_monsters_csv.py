#!/usr/bin/env python3
"""Export the monsters registered under data-otservbr-global/monster to a CSV file.

Columns: name, bestiary class, experience.

The Lua files are parsed statically: the name comes from
`Game.createMonsterType("...")`, experience from `monster.experience = N` and the
class from `class = "..."` inside the `monster.Bestiary` table. Monsters without a
bestiary entry (bosses, summons, quest creatures) get an empty class.
Files whose name starts with "#" are skipped, matching the server's script loader.
"""

import argparse
import csv
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_MONSTERS_DIR = REPO_ROOT / "data-otservbr-global" / "monster"
FIELDS = ("name", "bestiary class", "experience")

NAME_RE = re.compile(r'Game\.createMonsterType\(\s*"((?:[^"\\]|\\.)*)"')
EXPERIENCE_RE = re.compile(r"^\s*monster\.experience\s*=\s*(-?\d+)", re.MULTILINE)
BESTIARY_RE = re.compile(r"^\s*monster\.Bestiary\s*=\s*\{(.*?)^\s*\}", re.MULTILINE | re.DOTALL)
CLASS_RE = re.compile(r'^\s*class\s*=\s*"([^"]*)"', re.MULTILINE)


def parse_file(path):
	text = path.read_text(encoding="utf-8", errors="replace")
	name = NAME_RE.search(text)
	if not name:
		return None

	experience = EXPERIENCE_RE.search(text)
	bestiary = BESTIARY_RE.search(text)
	bestiary_class = CLASS_RE.search(bestiary.group(1)) if bestiary else None
	return {
		"name": name.group(1),
		"bestiary class": bestiary_class.group(1) if bestiary_class else "",
		"experience": experience.group(1) if experience else "",
	}


def collect(monsters_dir):
	rows = []
	for path in sorted(monsters_dir.rglob("*.lua")):
		if path.name.startswith("#"):
			continue
		row = parse_file(path)
		if row:
			rows.append(row)
	rows.sort(key=lambda r: r["name"].lower())
	return rows


def main():
	parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
	parser.add_argument("-d", "--monsters-dir", type=Path, default=DEFAULT_MONSTERS_DIR, help="monsters directory (default: %(default)s)")
	parser.add_argument("-o", "--output", default="output/monsters.csv", help='output CSV path, or "-" for stdout (default: %(default)s)')
	args = parser.parse_args()

	if not args.monsters_dir.is_dir():
		parser.error(f"monsters directory not found: {args.monsters_dir}")

	rows = collect(args.monsters_dir)
	if args.output != "-":
		Path(args.output).parent.mkdir(parents=True, exist_ok=True)
	out = sys.stdout if args.output == "-" else open(args.output, "w", newline="", encoding="utf-8")
	try:
		writer = csv.DictWriter(out, fieldnames=FIELDS)
		writer.writeheader()
		writer.writerows(rows)
	finally:
		if out is not sys.stdout:
			out.close()

	if args.output != "-":
		print(f"Wrote {len(rows)} monsters to {args.output}", file=sys.stderr)


if __name__ == "__main__":
	main()
