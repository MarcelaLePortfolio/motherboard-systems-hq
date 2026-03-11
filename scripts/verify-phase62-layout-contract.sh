#!/usr/bin/env bash
set -euo pipefail

FILE="public/dashboard.html"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

count_id() {
  grep -c "id=\"$1\"" "$FILE" || true
}

assert_single() {
  local id="$1"
  local count
  count=$(count_id "$id")

  if [[ "$count" -ne 1 ]]; then
    fail "$id count = $count (expected 1)"
  fi

  pass "$id count == 1"
}

assert_present() {
  grep -q "$1" "$FILE" || fail "missing marker: $1"
  pass "marker present: $1"
}

assert_order() {
  local a="$1"
  local b="$2"

  local pos_a
  local pos_b

  pos_a=$(grep -n "$a" "$FILE" | head -1 | cut -d: -f1)
  pos_b=$(grep -n "$b" "$FILE" | head -1 | cut -d: -f1)

  if [[ -z "$pos_a" || -z "$pos_b" ]]; then
    fail "order anchors missing"
  fi

  if (( pos_a >= pos_b )); then
    fail "order violation: $a must appear before $b"
  fi

  pass "order $a -> $b"
}

echo "PHASE 62.2 LAYOUT CONTRACT VERIFY"

assert_single metrics-row
assert_single phase61-workspace-shell
assert_single phase61-workspace-grid
assert_single operator-workspace-card
assert_single observational-workspace-card
assert_single atlas-status-card

assert_present "Operator Workspace"
assert_present "Telemetry Workspace"
assert_present "Atlas Subsystem Status"

assert_order metrics-row phase61-workspace-shell
assert_order phase61-workspace-shell atlas-status-card

echo "PHASE 62.2 CONTRACT PASSED"

