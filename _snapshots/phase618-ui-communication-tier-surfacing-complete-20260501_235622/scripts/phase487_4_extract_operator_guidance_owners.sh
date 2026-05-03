#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_guidance_owner_extract.txt"

FILES=(
  "src/cognition/operatorGuidanceReducer.ts"
  "src/cognition/operator-read/cognition.operator-read.ts"
  "src/cognition/operatorGuidanceMapping.ts"
  "src/cognition/operatorGuidanceConfidence.ts"
  "dashboard/src/cognition/operatorGuidance/operatorGuidanceReducer.ts"
  "dashboard/src/cognition/operatorGuidance/operatorGuidanceSelectors.ts"
  "dashboard/src/cognition/operatorGuidance/operatorGuidanceStore.ts"
  "dashboard/src/cognition/operatorGuidance/operatorGuidanceEffects.ts"
  "dashboard/src"
  "public/js/dashboard-status.js"
)

{
  echo "PHASE 487 — OPERATOR GUIDANCE OWNER EXTRACT"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] FILE EXISTENCE"
  for f in "${FILES[@]}"; do
    if [ -e "$f" ]; then
      echo "FOUND  $f"
    else
      echo "MISS   $f"
    fi
  done
  echo

  echo "[2] GUIDANCE / STREAM REFERENCES IN DASHBOARD SOURCE"
  grep -RniE "operatorGuidance|streamEvent|EventSource|fetch\\(|setInterval|setTimeout|diagnostics/system-health|SYSTEM_HEALTH|guidance" \
    dashboard/src public/js \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null || true
  echo

  for f in \
    src/cognition/operatorGuidanceReducer.ts \
    src/cognition/operator-read/cognition.operator-read.ts \
    src/cognition/operatorGuidanceMapping.ts \
    src/cognition/operatorGuidanceConfidence.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceReducer.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceSelectors.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceStore.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceEffects.ts \
    public/js/dashboard-status.js
  do
    if [ -f "$f" ]; then
      echo
      echo "===== FILE: $f ====="
      nl -ba "$f" | sed -n '1,260p'
    fi
  done

  echo
  echo "EXTRACT COMPLETE"
} > "$OUTPUT"

echo "Generated: $OUTPUT"
