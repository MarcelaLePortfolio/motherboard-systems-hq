#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_verify_final_guidance_render.txt"

{
  echo "PHASE 456 — FINAL GUIDANCE RENDER CHECK"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== VERIFY LIVE JS (SHOULD BE BASELINE EMITTER) ==="
  curl -fsS http://localhost:8080/js/operatorGuidance.sse.js | grep PHASE456_MINIMAL_GUIDANCE_EMITTER || true
  echo

  echo "=== QUICK UI CHECK INSTRUCTION ==="
  echo "1. Open: http://localhost:8080/dashboard.html"
  echo "2. Confirm Operator Guidance shows:"
  echo "   SYSTEM_HEALTH • INFO • HIGH"
  echo "   System operational. No active tasks. Awaiting operator input."
  echo

} | tee "$OUT"
