#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_operator_guidance_frontend_loop_focus.txt"

{
  echo "PHASE 456 — OPERATOR GUIDANCE FRONTEND LOOP FOCUS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== HTTP CHECKS ==="
  curl -I --max-time 10 http://localhost:8080/dashboard.html || true
  curl -I --max-time 10 "http://localhost:8080/js/operatorGuidance.sse.js?v=phase96-live-1" || true
  echo

  echo "=== DASHBOARD HTML: GUIDANCE / ASSET REFERENCES ==="
  curl -sS http://localhost:8080/dashboard.html | grep -nE "operatorGuidance|guidance|events/ops|events/reflections|phase457|bundle|SYSTEM_HEALTH|Operator Guidance" || true
  echo

  echo "=== SERVED operatorGuidance.sse.js (FIRST 260 LINES) ==="
  curl -sS "http://localhost:8080/js/operatorGuidance.sse.js?v=phase96-live-1" | sed -n '1,260p' || true
  echo

  echo "=== REPO SEARCH: GUIDANCE FRONTEND WRITERS ==="
  grep -RniE "operatorGuidance|Operator Guidance|SYSTEM_HEALTH|events/ops|events/reflections|appendChild|innerHTML|textContent|insertAdjacent|createElement|renderGuidance|guidance" \
    public src server app routes . 2>/dev/null | head -500 || true
  echo

  echo "=== REPO FILE DUMPS: MOST LIKELY FRONTEND TARGETS ==="
  for f in \
    public/js/operatorGuidance.sse.js \
    public/dashboard.html \
    public/bundle.js \
    public/js/phase457_restore_task_panels.js \
    public/js/phase457_neutralize_legacy_observational_consumers.js
  do
    if [ -f "$f" ]; then
      echo "----- FILE: $f (FIRST 260 LINES) -----"
      sed -n '1,260p' "$f" || true
      echo
    fi
  done

  echo "=== DASHBOARD LOGS (LAST 80) ==="
  docker compose logs --tail 80 dashboard 2>&1 || true
  echo
} | tee "$OUT"
