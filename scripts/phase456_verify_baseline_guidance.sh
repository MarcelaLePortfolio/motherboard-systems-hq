#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_verify_baseline_guidance.txt"

{
  echo "PHASE 456 — VERIFY BASELINE GUIDANCE RENDER"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== DASHBOARD HTML CHECK (SNIPPET) ==="
  curl -fsS http://localhost:8080/dashboard.html | grep -n "operator-guidance" || true
  echo

  echo "=== JS ASSET CONFIRM ==="
  curl -fsS http://localhost:8080/js/operatorGuidance.sse.js | sed -n '1,80p'
  echo

  echo "=== EXPECTED STATE ==="
  echo "Open http://localhost:8080/dashboard.html"
  echo "You should now see:"
  echo "SYSTEM_HEALTH • INFO • HIGH"
  echo "System operational. No active tasks. Awaiting operator input."
  echo

} | tee "$OUT"
