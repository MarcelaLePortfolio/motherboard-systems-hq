#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILE="PHASE42_SCOPE.md"

echo "=== phase42_scope_gate ==="
echo "file=$FILE"

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: missing $FILE" >&2
  exit 2
fi

# Prefer rg if present; otherwise use portable grep.
has_tbd=0
if command -v rg >/dev/null 2>&1; then
  if rg -n --fixed-strings "TBD" "$FILE" >/dev/null 2>&1; then
    has_tbd=1
  fi
else
  if grep -nF "TBD" "$FILE" >/dev/null 2>&1; then
    has_tbd=1
  fi
fi

if [[ "$has_tbd" -eq 1 ]]; then
  echo "FAIL: $FILE still contains 'TBD' — Phase 42 scope is not finalized." >&2
  echo
  echo "Matches:"
  if command -v rg >/dev/null 2>&1; then
    rg -n --fixed-strings "TBD" "$FILE" || true
  else
    grep -nF "TBD" "$FILE" || true
  fi
  exit 1
fi

echo "OK: no TBD remains in $FILE"
