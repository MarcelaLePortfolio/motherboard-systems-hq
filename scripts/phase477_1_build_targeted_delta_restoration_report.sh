#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BACKUP="public/dashboard.html.phase476_6_pre_strip.bak"
CURRENT="public/dashboard.html"
OUT="docs/phase477_1_targeted_delta_restoration_report.txt"

mkdir -p docs

python3 <<'PY'
from pathlib import Path
import re
import difflib

backup_path = Path("public/dashboard.html.phase476_6_pre_strip.bak")
current_path = Path("public/dashboard.html")
out_path = Path("docs/phase477_1_targeted_delta_restoration_report.txt")

backup_lines = backup_path.read_text().splitlines()
current_lines = current_path.read_text().splitlines()

def classify_line(line: str) -> str:
    s = line.strip()
    if not s:
        return "blank"
    if "<script" in s or "</script" in s:
        return "script"
    if "<link" in s and "stylesheet" in s:
        return "stylesheet"
    if s.lower().startswith("<body"):
        return "body_tag"
    if "<style" in s or s.startswith("</style"):
        return "inline_style"
    return "structural_other"

def section_of_index(lines, idx):
    head_end = None
    body_start = None
    body_end = None
    for i, line in enumerate(lines):
        if head_end is None and re.search(r"</head>", line, re.I):
            head_end = i
        if body_start is None and re.search(r"<body\b", line, re.I):
            body_start = i
        if re.search(r"</body>", line, re.I):
            body_end = i
    if head_end is not None and idx <= head_end:
        return "head"
    if body_start is not None and body_end is not None and body_start <= idx <= body_end:
        return "body"
    return "footer"

current_set = set(current_lines)

missing = []
for idx, line in enumerate(backup_lines, start=1):
    if line not in current_set:
        missing.append({
            "line_no": idx,
            "section": section_of_index(backup_lines, idx - 1),
            "kind": classify_line(line),
            "text": line,
        })

filtered = [m for m in missing if m["kind"] == "structural_other"]

grouped = {"head": [], "body": [], "footer": []}
for item in filtered:
    grouped[item["section"]].append(item)

diff = list(difflib.unified_diff(
    backup_lines,
    current_lines,
    fromfile=str(backup_path),
    tofile=str(current_path),
    lineterm=""
))

with out_path.open("w") as f:
    f.write("PHASE 477.1 — TARGETED DELTA RESTORATION REPORT\n")
    f.write("===============================================\n\n")
    f.write(f"BACKUP={backup_path}\n")
    f.write(f"CURRENT={current_path}\n\n")
    f.write("STEP 1 — Summary counts\n")
    f.write(f"backup_line_count={len(backup_lines)}\n")
    f.write(f"current_line_count={len(current_lines)}\n")
    f.write(f"missing_total={len(missing)}\n")
    f.write(f"missing_structural_other={len(filtered)}\n\n")

    f.write("STEP 2 — Missing dashboard-only lines by section (excluding scripts, stylesheets, inline styles, and body tag)\n")
    for section in ("head", "body", "footer"):
        f.write(f"\n[{section.upper()}] count={len(grouped[section])}\n")
        for item in grouped[section][:120]:
            f.write(f"{item['line_no']}: {item['text']}\n")

    f.write("\nSTEP 3 — Unified diff preview (first 300 lines)\n")
    for line in diff[:300]:
        f.write(line + "\n")

    f.write("\nSTEP 4 — Recommendation\n")
    if grouped["head"]:
        f.write("- Start with HEAD structural_other delta restoration closest to </head>.\n")
    elif grouped["body"]:
        f.write("- Start with BODY structural_other delta restoration closest to <body> boundary.\n")
    elif grouped["footer"]:
        f.write("- Start with FOOTER structural_other delta restoration closest to </body> boundary.\n")
    else:
        f.write("- No structural_other deltas remain under current filters; next pass should compare comments, wrapper tags, and exact body-open/body-close composition.\n")
PY

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
