#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="${1:-public/dashboard.html}"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
html = target.read_text(encoding="utf-8")

def fail(msg: str) -> None:
    print(f"FAIL: {msg}")
    raise SystemExit(1)

def expect_count(token: str, expected: int) -> None:
    pattern = rf'id=["\']{re.escape(token)}["\']'
    count = len(re.findall(pattern, html))
    if count != expected:
        fail(f"{token} count expected {expected}, got {count}")
    print(f"PASS: {token} count == {expected}")

required_ids = [
    "metrics-row",
    "phase61-workspace-shell",
    "phase61-workspace-grid",
    "operator-workspace-card",
    "observational-workspace-card",
    "atlas-status-card",
]

for token in required_ids:
    expect_count(token, 1)

required_markers = [
    "Operator Workspace",
    "Telemetry Workspace",
    "Chat",
    "Delegation",
    "Recent Tasks",
    "Task History",
    "Task Events",
    "Atlas Subsystem Status",
]

for marker in required_markers:
    if marker not in html:
        fail(f"missing marker: {marker}")
    print(f"PASS: marker present: {marker}")

positions = {}
for token in [
    'id="metrics-row"',
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="atlas-status-card"',
]:
    pos = html.find(token)
    if pos == -1:
        fail(f"could not locate {token}")
    positions[token] = pos
    print(f"ORDER: {token} -> {pos}")

if not (
    positions['id="metrics-row"']
    < positions['id="phase61-workspace-shell"']
    < positions['id="phase61-workspace-grid"']
    < positions['id="operator-workspace-card"']
    < positions['id="observational-workspace-card"']
    < positions['id="atlas-status-card"']
):
    fail("layout ordering invalid")

workspace_grid_start = html.find('id="phase61-workspace-grid"')
atlas_pos = html.find('id="atlas-status-card"')
if atlas_pos < workspace_grid_start:
    fail("atlas appears before workspace grid")

pre_atlas = html[:atlas_pos]
if '</div>' not in pre_atlas:
    fail("no closing div before atlas; workspace grid may still be open")

last_grid_close = pre_atlas.rfind("</div>")
last_workspace_shell_close = pre_atlas.rfind("</section>")
if last_grid_close == -1:
    fail("workspace grid closing div not found before atlas")

if last_grid_close < workspace_grid_start:
    fail("workspace grid closing div appears before grid start")

if 'grid-column: 1 / -1;' not in html:
    fail("missing atlas full-width grid-column rule")

if '#atlas-status-card' not in html:
    fail("missing atlas status card css selector")

print("STRUCTURE VERIFY PASSED")
PY
