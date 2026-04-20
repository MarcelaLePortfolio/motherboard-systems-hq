#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 NARROWED RUNTIME VERIFICATION ==="

TARGETS=(
  "server.ts"
  "scripts/server.cjs"
  "routes/api/delegate.ts"
  "routes/api/tasks.ts"
  "routes/api/logs.ts"
  "routes/diagnostics/systemHealth.ts"
  "scripts/agents/cade.ts"
  "scripts/agents/effie.ts"
  "agents/matilda.ts/matilda.mjs"
)

echo
echo "=== 1) Existence check ==="
for path in "${TARGETS[@]}"; do
  if [ -f "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
  fi
done

echo
echo "=== 2) Import / require lines ==="
for path in "${TARGETS[@]}"; do
  echo "--- $path ---"
  if [ -f "$path" ]; then
    grep -nE '^(import |const .*require\(|require\()' "$path" | head -20 || echo "(no import/require lines found)"
  else
    echo "(missing)"
  fi
  echo
done

echo
echo "=== 3) Bounded header inspection ==="
for path in "${TARGETS[@]}"; do
  echo "--- $path (first 40 lines) ---"
  if [ -f "$path" ]; then
    sed -n '1,40p' "$path"
  else
    echo "(missing)"
  fi
  echo
done

echo "=== END PHASE 487 NARROWED RUNTIME VERIFICATION ==="
