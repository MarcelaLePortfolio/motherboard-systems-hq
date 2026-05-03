#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

python3 <<'PY'
from pathlib import Path

report = Path("docs/phase423_2_step1_execution_anchor_link_resolution.md")
text = report.read_text(encoding="utf-8")

markers = [
    "## Scope control",
    "### Direct co-location result",
    "## Step 1.6 — Execution call stack trace",
    "## Step 1.7 — Governance call stack trace",
    "### Intersection result",
    "## Deterministic conclusion",
]

print(f"REPORT: {report}")
print("=" * 100)

for i, marker in enumerate(markers):
    start = text.find(marker)
    if start == -1:
        print(f"MISSING: {marker}")
        print("=" * 100)
        continue

    end = len(text)
    for next_marker in markers[i + 1:]:
        pos = text.find(next_marker, start + 1)
        if pos != -1:
            end = min(end, pos)

    print(text[start:end].rstrip())
    print("=" * 100)

excluded_hits = [
    line for line in text.splitlines()
    if "docs/phase423_2_step1_" in line
    or "scripts/_local/phase423_2_step1_continuation.sh" in line
]

print("SELF-REFERENCE CHECK")
print("=" * 100)

for line in excluded_hits[:50]:
    print(line)

print("=" * 100)
print(f"Self-reference line count: {len(excluded_hits)}")
PY
