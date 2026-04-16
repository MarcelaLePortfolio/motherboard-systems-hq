#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_runtime_guidance_bindings.txt"

{
  echo "PHASE 487 — RUNTIME GUIDANCE BINDINGS EXTRACT"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] TARGET FILE PRESENCE"
  for f in \
    public/js/operatorGuidance.sse.js \
    dashboard/src/cognition/operatorGuidance/useOperatorGuidance.ts \
    dashboard/src/cognition/operatorGuidance/index.ts \
    public/dashboard.html
  do
    if [ -f "$f" ]; then
      echo "FOUND  $f"
    else
      echo "MISS   $f"
    fi
  done
  echo

  echo "[2] GUIDANCE BINDING HOTSPOTS"
  grep -RniE "operatorGuidance|OperatorGuidance|EventSource|addEventListener\\(|dispatchEvent|CustomEvent|replaceReduction|applyStreamEvent|mb:ops:update|mb:reflections:update|SYSTEM_HEALTH|guidance" \
    public/js dashboard/src public/dashboard.html \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null || true
  echo

  for f in \
    public/js/operatorGuidance.sse.js \
    dashboard/src/cognition/operatorGuidance/useOperatorGuidance.ts \
    dashboard/src/cognition/operatorGuidance/index.ts \
    public/dashboard.html
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
