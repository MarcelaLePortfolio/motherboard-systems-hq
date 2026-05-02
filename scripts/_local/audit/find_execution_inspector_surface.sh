#!/bin/bash
set -euo pipefail

echo "=== Execution Inspector candidates ==="
find app public src server -type f 2>/dev/null | grep -Ei "execution|inspector|task|telemetry" || true

echo ""
echo "=== Direct references ==="
grep -RIn "Execution Inspector\|ExecutionInspector\|execution inspector\|outcome_preview\|explanation_preview" app public src server \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  2>/dev/null || true

echo ""
echo "=== Git status excluding snapshots ==="
git status --short ':!_snapshots'
