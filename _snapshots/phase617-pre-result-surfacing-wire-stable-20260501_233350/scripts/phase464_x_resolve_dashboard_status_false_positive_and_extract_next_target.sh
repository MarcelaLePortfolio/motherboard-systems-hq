#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

DECISION_OUT="docs/phase464_x_dashboard_status_false_positive_decision.txt"
NEXT_FILE="public/js/phase457_restore_task_panels.js"
NEXT_OUT="docs/phase464_x_phase457_restore_task_panels_hotspots.txt"

{
  echo "PHASE 464.X — DASHBOARD STATUS FALSE POSITIVE DECISION"
  echo "======================================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Direct operator-guidance / Atlas matches in public/js/dashboard-status.js"
  rg -n 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|atlas-status|Atlas Subsystem Status|No active tasks|Awaiting operator input' public/js/dashboard-status.js || true
  echo

  echo "2) connect/handle/tick ownership markers"
  rg -n 'function connect|const handle|setInterval|EventSource|dispatchEvent' public/js/dashboard-status.js || true
  echo

  echo "3) Decision"
  if rg -q 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|atlas-status|Atlas Subsystem Status|No active tasks|Awaiting operator input' public/js/dashboard-status.js; then
    echo "dashboard-status.js is a DIRECT producer candidate"
    echo "NEXT TARGET: public/js/dashboard-status.js"
  else
    echo "dashboard-status.js is a FALSE POSITIVE"
    echo "NEXT TARGET: ${NEXT_FILE}"
  fi
} > "$DECISION_OUT"

{
  echo "PHASE 464.X — NEXT TARGET HOTSPOTS"
  echo "=================================="
  echo
  echo "Target: ${NEXT_FILE}"
  echo

  if [ -f "${NEXT_FILE}" ]; then
    echo "1) High-risk patterns"
    rg -n 'SYSTEM_HEALTH|operator-guidance|append|innerHTML|textContent|setInterval|EventSource|MutationObserver' "${NEXT_FILE}" || true
    echo

    echo "2) Focused excerpts"
    while IFS=: read -r line _; do
      start=$(( line > 20 ? line - 20 : 1 ))
      end=$(( line + 40 ))
      echo "----- lines ${start}-${end} -----"
      sed -n "${start},${end}p" "${NEXT_FILE}"
      echo
    done < <(rg -n 'append|innerHTML|textContent|setInterval|EventSource|MutationObserver' "${NEXT_FILE}" | cut -d: -f1 | awk '!seen[$0]++' | head -n 10)
  else
    echo "File not found: ${NEXT_FILE}"
  fi
} > "$NEXT_OUT"

echo "Wrote:"
echo "$DECISION_OUT"
echo "$NEXT_OUT"
