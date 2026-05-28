
from pathlib import Path

from datetime import datetime

OUTPUT = Path("GOVERNED_ROUTE_REGISTRATION_DISCOVERY.txt")

ROOT = Path(".")

EXCLUDED_DIRS = {

    ".git",

    "node_modules",

    "backups",

    "dist",

}

SUFFIXES = {

    ".js",

    ".mjs",

    ".ts",

}

NAMES = {

    "server.js",

    "app.js",

    "index.js",

}

def skip(path: Path) -> bool:

    return any(part in EXCLUDED_DIRS for part in path.parts)

def interesting_file(path: Path) -> bool:

    return path.name in NAMES or path.suffix in SUFFIXES

def safe_read(path: Path) -> str:

    try:

        return path.read_text(errors="ignore")

    except Exception:

        return ""

def grep_lines(path: Path, needles):

    text = safe_read(path)

    out = []

    for i, line in enumerate(text.splitlines(), 1):

        if any(n in line for n in needles):

            out.append(f"{path}:{i}:{line}")

    return out

files = sorted(

    p for p in ROOT.rglob("*")

    if p.is_file()

    and not skip(p)

    and interesting_file(p)

)

lines = []

lines.append("===== GOVERNED ROUTE REGISTRATION DISCOVERY =====")

lines.append(datetime.now().isoformat())

lines.append("")

lines.append("===== EXPRESS SERVER SURFACES =====")

for path in files:

    text = safe_read(path)

    if any(token in text for token in ["express", "Router", "app.use", "router.use"]):

        lines.append("")

        lines.append(f"FILE: {path}")

        lines.append("--------------------------------------------------")

        lines.extend(

            grep_lines(

                path,

                [

                    "express",

                    "Router",

                    "app.use",

                    "router.use",

                    "governed-planning-route",

                    "governed-planning",

                ],

            )

        )

lines.append("")

lines.append("===== ROUTE FILE REFERENCES =====")

for path in files:

    refs = grep_lines(

        path,

        [

            "governed-planning-route",

            "governed_planning",

            "governed-planning",

        ],

    )

    lines.extend(refs)

lines.append("")

lines.append("===== SERVER ENTRYPOINT CANDIDATES =====")

for path in files:

    if path.name in NAMES:

        lines.append(str(path))

lines.append("")

lines.append("===== DISCOVERY COMPLETE =====")

OUTPUT.write_text("\n".join(lines) + "\n")

print(OUTPUT.read_text())

