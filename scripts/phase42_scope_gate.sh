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

# Gate: no TBD in the scope doc.
if rg -n --fixed-strings "TBD" "$FILE" >/dev/null; then
  echo "FAIL: $FILE still contains 'TBD' — Phase 42 scope is not finalized." >&2
  echo
  echo "Matches:"
  rg -n --fixed-strings "TBD" "$FILE" || true
  exit 1
fi

echo "OK: no TBD remains in $FILE"
