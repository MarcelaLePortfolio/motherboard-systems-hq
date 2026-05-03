#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_dashboard_guidance_consumers.txt"

{
  echo "PHASE 487 — DASHBOARD GUIDANCE CONSUMER EXTRACT"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] DASHBOARD FILES THAT REFERENCE OPERATOR GUIDANCE"
  grep -RnilE "operatorGuidance|OperatorGuidance|mb:ops:update|mb:reflections:update|CustomEvent|addEventListener\\(" \
    dashboard/src public/js \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null | sort -u || true
  echo

  echo "[2] HOTSPOT LINES"
  grep -RniE "operatorGuidance|OperatorGuidance|mb:ops:update|mb:reflections:update|CustomEvent|addEventListener\\(|dispatch\\(|useEffect|useReducer|useMemo|appendChild|append\\(|innerHTML|textContent" \
    dashboard/src public/js \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null || true
  echo

  for f in \
    dashboard/src/cognition/operatorGuidance/operatorGuidancePanel.tsx \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceSelectors.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidance.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceRenderContract.ts \
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
