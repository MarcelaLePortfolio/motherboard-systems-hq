#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 531 — FIND EXECUTION TRAIL"
echo "────────────────────────────────"

echo ""
echo "Searching for Execution Trail / task-events UI consumers..."

grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=build \
  "task-events\|Execution Trail\|eventSource\|addEventListener" public/js || true

echo ""
echo "No changes made. Identify the primary UI file rendering Execution Trail."
