#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import sys

p = Path("public/dashboard.html")
html = p.read_text(encoding="utf-8")

checks = {
    "phase61-workspace-shell count == 1": len(re.findall(r'id=["\']phase61-workspace-shell["\']', html)) == 1,
    "phase61-workspace-grid count == 1": len(re.findall(r'id=["\']phase61-workspace-grid["\']', html)) == 1,
    "operator-workspace-card count == 1": len(re.findall(r'id=["\']operator-workspace-card["\']', html)) == 1,
    "observational-workspace-card count == 1": len(re.findall(r'id=["\']observational-workspace-card["\']', html)) == 1,
    "phase61-atlas-band count == 1": len(re.findall(r'id=["\']phase61-atlas-band["\']', html)) == 1,
    "atlas-subsystem-status-card count == 1": len(re.findall(r'id=["\']atlas-subsystem-status-card["\']', html)) == 1,
}

for label, ok in checks.items():
    print(("PASS" if ok else "FAIL") + " - " + label)

if not all(checks.values()):
    sys.exit(1)

order_tokens = [
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="phase61-atlas-band"',
    'id="atlas-subsystem-status-card"',
]

positions = []
for token in order_tokens:
    pos = html.find(token)
    print(f"ORDER {token} -> {pos}")
    if pos == -1:
        sys.exit(1)
    positions.append(pos)

if positions != sorted(positions):
    print("FAIL - structure ordering invalid")
    sys.exit(1)

required_markers = [
    "Operator Workspace",
    "Chat",
    "Delegation",
    "Recent Tasks",
    "Task Events",
    "Atlas Subsystem Status",
]
for marker in required_markers:
    if marker not in html:
        print(f"FAIL - missing marker: {marker}")
        sys.exit(1)
    print(f"PASS - marker present: {marker}")

print("STRUCTURE VERIFY PASSED")
PY
