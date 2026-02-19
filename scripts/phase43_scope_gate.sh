#!/usr/bin/env bash
set -euo pipefail

echo "=== phase43_scope_gate ==="
file="PHASE43_SCOPE.md"

if [[ ! -f "$file" ]]; then
  echo "ERROR: missing $file" >&2
  exit 2
fi

# Gate rule: no TBD markers (keeps scope explicit)
if rg -n "\bTBD\b" "$file" >/dev/null; then
  echo "ERROR: TBD remains in $file" >&2
  rg -n "\bTBD\b" "$file" || true
  exit 2
fi

echo "file=$file"
echo "OK: no TBD remains in $file"
