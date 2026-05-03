#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

DASHBOARD_HTML="public/dashboard.html"

if [[ ! -f "$DASHBOARD_HTML" ]]; then
  echo "FAIL: missing $DASHBOARD_HTML"
  exit 1
fi

count_matches() {
  local pattern="$1"
  python3 - "$DASHBOARD_HTML" "$pattern" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
pattern = sys.argv[2]
text = path.read_text()
print(len(re.findall(pattern, text, flags=re.MULTILINE)))
PY
}

assert_count_eq() {
  local label="$1"
  local pattern="$2"
  local expected="$3"
  local actual
  actual="$(count_matches "$pattern")"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: ${label} count == ${actual} (expected ${expected})"
    exit 1
  fi
  echo "PASS: ${label} count == ${expected}"
}

assert_present() {
  local label="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$DASHBOARD_HTML"; then
    echo "FAIL: marker missing: ${needle}"
    exit 1
  fi
  echo "PASS: marker present: ${needle}"
}

assert_order() {
  local first="$1"
  local second="$2"
  python3 - "$DASHBOARD_HTML" "$first" "$second" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
first = sys.argv[2]
second = sys.argv[3]
text = path.read_text()

a = text.find(first)
b = text.find(second)

if a == -1 or b == -1:
    print(f"FAIL: order anchor missing: {first} / {second}")
    raise SystemExit(1)

if a >= b:
    print(f"FAIL: order {first} -> {second}")
    raise SystemExit(1)

print(f"PASS: order {first} -> {second}")
PY
}

echo "PHASE 62 DASHBOARD GOLDEN VERIFY"
echo "--------------------------------"
echo "PHASE 62.2 LAYOUT CONTRACT VERIFY"

assert_count_eq "agent-status-container" 'id="agent-status-container"' 1
assert_count_eq "metrics-row" 'id="metrics-row"' 1
assert_count_eq "phase61-workspace-shell" 'id="phase61-workspace-shell"' 1
assert_count_eq "phase61-workspace-grid" 'id="phase61-workspace-grid"' 1
assert_count_eq "operator-workspace-card" 'Operator Workspace' 1
assert_count_eq "observational-workspace-card" 'Telemetry Workspace' 1
assert_count_eq "phase61-atlas-band" 'id="phase61-atlas-band"' 1
assert_count_eq "atlas-status-card" 'id="atlas-status-card"' 1

assert_present "phase62-top-row class" 'class="phase62-top-row"'
assert_present "Agent Pool marker" 'Agent Pool'
assert_present "System metrics aria" 'aria-label="System metrics"'
assert_present "Operator Workspace marker" 'Operator Workspace'
assert_present "Telemetry Workspace marker" 'Telemetry Workspace'
assert_present "Atlas Subsystem Status marker" 'Atlas Subsystem Status'

assert_order 'id="agent-status-container"' 'id="metrics-row"'
assert_order 'id="metrics-row"' 'id="phase61-workspace-shell"'
assert_order 'id="phase61-workspace-shell"' 'id="phase61-atlas-band"'
assert_order 'id="phase61-atlas-band"' 'id="atlas-status-card"'

echo "PHASE 62.2 CONTRACT PASSED"
echo ""
echo "PHASE 62B METRIC BINDING VERIFY"

assert_present "metric-agents present" 'id="metric-agents"'
assert_present "metric-tasks present" 'id="metric-tasks"'
assert_present "metric-success present" 'id="metric-success"'
assert_present "metric-latency present" 'id="metric-latency"'
assert_present "phase62b metric anchor attribute present" 'data-phase62b-metric-anchor="true"'

assert_count_eq "metric-agents" 'id="metric-agents"' 1
assert_count_eq "metric-tasks" 'id="metric-tasks"' 1
assert_count_eq "metric-success" 'id="metric-success"' 1
assert_count_eq "metric-latency" 'id="metric-latency"' 1

echo "PHASE 62B METRIC BINDINGS VERIFIED"
echo ""
echo "PHASE 62 DASHBOARD GOLDEN STATE VERIFIED"
