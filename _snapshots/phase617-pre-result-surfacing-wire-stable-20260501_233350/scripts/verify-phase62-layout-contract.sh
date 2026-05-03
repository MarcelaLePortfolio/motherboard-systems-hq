#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-public/dashboard.html}"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

file_path = Path(sys.argv[1])
text = file_path.read_text()

def fail(msg: str) -> None:
    print(f"FAIL: {msg}")
    raise SystemExit(1)

def pas(msg: str) -> None:
    print(f"PASS: {msg}")

def count(needle: str) -> int:
    return text.count(needle)

def assert_single_id(element_id: str) -> None:
    needle = f'id="{element_id}"'
    c = count(needle)
    if c != 1:
        fail(f"{element_id} count = {c} (expected 1)")
    pas(f"{element_id} count == 1")

def assert_present(marker: str) -> None:
    if marker not in text:
        fail(f"missing marker: {marker}")
    pas(f"marker present: {marker}")

def pos(needle: str) -> int:
    i = text.find(needle)
    if i == -1:
        fail(f"anchor missing: {needle}")
    return i

def assert_order(a: str, b: str) -> None:
    pa = pos(a)
    pb = pos(b)
    if pa >= pb:
        fail(f"order violation: {a} must appear before {b}")
    pas(f"order {a} -> {b}")

print("PHASE 62.2 LAYOUT CONTRACT VERIFY")

assert_single_id("agent-status-container")
assert_single_id("metrics-row")
assert_single_id("phase61-workspace-shell")
assert_single_id("phase61-workspace-grid")
assert_single_id("operator-workspace-card")
assert_single_id("observational-workspace-card")
assert_single_id("phase61-atlas-band")
assert_single_id("atlas-status-card")

assert_present('class="phase62-top-row"')
assert_present("Agent Pool")
assert_present('aria-label="System metrics"')
assert_present("Operator Workspace")
assert_present("Telemetry Workspace")
assert_present("Atlas Subsystem Status")

assert_order('id="agent-status-container"', 'id="metrics-row"')
assert_order('id="metrics-row"', 'id="phase61-workspace-shell"')
assert_order('id="phase61-workspace-shell"', 'id="phase61-atlas-band"')
assert_order('id="phase61-atlas-band"', 'id="atlas-status-card"')

print("PHASE 62.2 CONTRACT PASSED")
PY
