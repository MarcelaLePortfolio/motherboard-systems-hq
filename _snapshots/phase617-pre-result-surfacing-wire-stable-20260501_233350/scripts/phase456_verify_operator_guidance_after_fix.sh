#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_verify_operator_guidance_after_fix.txt"

{
  echo "PHASE 456 — VERIFY OPERATOR GUIDANCE AFTER FIX"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  docker compose ps
  echo

  echo "=== ASSET CHECK ==="
  curl -fsS http://localhost:8080/js/operatorGuidance.sse.js | sed -n '1,120p'
  echo

  echo "=== OPS STREAM SAMPLE (SAFE CUT) ==="
  (curl -NsS http://localhost:8080/events/ops | head -12) || true
  echo

  echo "=== DASHBOARD LOGS (LAST 40) ==="
  docker compose logs --tail 40 dashboard 2>&1 || true
  echo
} | tee "$OUT"
