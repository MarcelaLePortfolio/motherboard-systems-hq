#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

OUT="docs/phase464_x_system_health_repeat_evidence.txt"

{
  echo "PHASE 464.X — SYSTEM HEALTH REPEAT EVIDENCE"
  echo "==========================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Browser files mentioning Atlas / system health / operator guidance"
  rg -n 'Atlas Subsystem Status|atlas-status|atlas-health|system health|SYSTEM_HEALTH|operator-guidance|telemetry workspace|global-status|health-status' \
    public bundle.js 2>/dev/null || true
  echo

  echo "2) Browser files using append / innerHTML / insertAdjacent / appendChild"
  rg -n 'appendChild|append\(|insertAdjacent|innerHTML|outerHTML|replaceChildren|textContent' \
    public/js bundle.js 2>/dev/null | head -n 500 || true
  echo

  echo "3) Browser files using intervals / SSE / reconnect / DOMContentLoaded"
  rg -n 'setInterval|clearInterval|EventSource|WebSocket|DOMContentLoaded|load|visibilitychange|document.hidden|pageshow|pagehide|beforeunload' \
    public/js bundle.js 2>/dev/null | head -n 500 || true
  echo

  echo "4) Focused likely candidates"
  for f in \
    public/js/dashboard-status.js \
    public/js/phase457_restore_task_panels.js \
    public/js/ops-globals-bridge.js \
    public/js/ops-sse-listener.js \
    public/js/agent-status-row.js \
    public/js/dashboard-tasks-widget.js \
    public/js/operatorGuidance.sse.js \
    public/dashboard.html \
    bundle.js
  do
    if [ -f "$f" ]; then
      echo
      echo "FILE: $f"
      echo "----------------------------------------"
      rg -n 'Atlas Subsystem Status|atlas-status|atlas-health|SYSTEM_HEALTH|system health|appendChild|append\(|insertAdjacent|innerHTML|replaceChildren|setInterval|clearInterval|EventSource|DOMContentLoaded|load|operator-guidance' "$f" 2>/dev/null || true
      echo
    fi
  done

  echo
  echo "5) Focused excerpts: dashboard-status.js"
  if [ -f public/js/dashboard-status.js ]; then
    sed -n '1,260p' public/js/dashboard-status.js
  fi
  echo

  echo "6) Focused excerpts: agent-status-row.js"
  if [ -f public/js/agent-status-row.js ]; then
    sed -n '1,260p' public/js/agent-status-row.js
  fi
  echo

  echo "7) Focused excerpts: phase457_restore_task_panels.js"
  if [ -f public/js/phase457_restore_task_panels.js ]; then
    sed -n '1,260p' public/js/phase457_restore_task_panels.js
  fi
  echo

  echo "8) Focused excerpts: dashboard.html around operator guidance + Atlas"
  if [ -f public/dashboard.html ]; then
    sed -n '470,620p' public/dashboard.html
  fi
  echo

  echo "9) Decision gate"
  echo "- Identify the file that both receives health/task/SSE input and performs append/growth behavior."
  echo "- Next mutation must remain ONE FILE ONLY after explicit producer proof."
} > "$OUT"

echo "Wrote $OUT"
