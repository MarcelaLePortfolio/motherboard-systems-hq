#!/usr/bin/env bash
set -euo pipefail

SRC="docs/phase456_run_view_schema_evidence.txt"
OUT="docs/phase456_run_view_schema_summary.txt"

python3 - << 'PY'
from pathlib import Path
import re
from datetime import datetime, timezone

src = Path("docs/phase456_run_view_schema_evidence.txt")
out = Path("docs/phase456_run_view_schema_summary.txt")

if not src.exists():
    raise SystemExit(f"Missing {src}")

text = src.read_text(errors="replace")
lines = text.splitlines()

def section(title: str, limit: int = 160):
    start = None
    marker = f"=== {title} ==="
    for i, line in enumerate(lines):
        if line.strip() == marker:
            start = i
            break
    if start is None:
        return [f"[missing section: {title}]"]
    collected = [lines[start]]
    for line in lines[start + 1:]:
        if line.startswith("=== ") and line.strip() != marker:
            break
        collected.append(line)
    return collected[:limit]

run_view_matches = [f"{i+1}:{line}" for i, line in enumerate(lines) if "run_view" in line][:80]

postgres_tail = section("CANONICAL POSTGRES LOGS (TAIL 120)", limit=400)
postgres_filtered = [
    f"{idx+1}:{line}"
    for idx, line in enumerate(postgres_tail)
    if re.search(r"run_view|relation|ERROR|create|view|tasks|task_events", line, re.I)
][:120]

parts = []
parts.append("PHASE 456 — RUN_VIEW SCHEMA SUMMARY EXTRACT")
parts.append(f"Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")
parts.append("")

parts.append("=== MATCHES: run_view ===")
parts.extend(run_view_matches or ["[no run_view matches]"])
parts.append("")

for title, limit in [
    ("SEARCH: run_view / runs / schema bootstrap", 160),
    ("SEARCH: DB BOOTSTRAP / MIGRATION ENTRYPOINTS", 160),
    ("SEARCH: /api/runs IMPLEMENTATION", 160),
    ("POSTGRES: DOES run_view EXIST?", 120),
    ("POSTGRES: DOES tasks TABLE EXIST?", 120),
]:
    parts.extend(section(title, limit=limit))
    parts.append("")

parts.append("=== SECTION: CANONICAL POSTGRES LOGS (FILTERED) ===")
parts.extend(postgres_filtered or ["[no matching postgres log lines]"])
parts.append("")

out.write_text("\n".join(parts))
print(f"Wrote {out}")
print(out.read_text(errors='replace')[:12000])
PY
