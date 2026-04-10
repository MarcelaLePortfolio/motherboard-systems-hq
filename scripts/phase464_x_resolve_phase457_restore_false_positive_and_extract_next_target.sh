#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

DECISION_OUT="docs/phase464_x_phase457_restore_false_positive_decision.txt"
NEXT_FILE="public/js/phase457_neutralize_legacy_observational_consumers.js"
NEXT_OUT="docs/phase464_x_phase457_neutralize_hotspots.txt"

{
  echo "PHASE 464.X — PHASE457 RESTORE FALSE POSITIVE DECISION"
  echo "======================================================"
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "1) Direct operator-guidance / Atlas / SYSTEM_HEALTH matches"
  rg -n 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|atlas-status|Atlas Subsystem Status|No active tasks|Awaiting operator input|diagnostics/system-health' public/js/phase457_restore_task_panels.js || true
  echo

  echo "2) Task-event ownership markers"
  rg -n 'task-events|recentLogs|tasks-widget|mb-task-events|Waiting for task events|Task events stream reconnecting|EventSource|setInterval' public/js/phase457_restore_task_panels.js || true
  echo

  echo "3) Decision"
  if rg -q 'operator-guidance|Operator Guidance|SYSTEM_HEALTH|system health|atlas-status|Atlas Subsystem Status|No active tasks|Awaiting operator input|diagnostics/system-health' public/js/phase457_restore_task_panels.js; then
    echo "phase457_restore_task_panels.js remains a DIRECT producer candidate"
    echo "NEXT TARGET: public/js/phase457_restore_task_panels.js"
  else
    echo "phase457_restore_task_panels.js is a FALSE POSITIVE"
    echo "Reason:"
    echo "- owns task-events / recent / history panels"
    echo "- no direct operator guidance or Atlas content strings"
    echo
    echo "NEXT TARGET: ${NEXT_FILE}"
  fi
} > "$DECISION_OUT"

{
  echo "PHASE 464.X — PHASE457 NEUTRALIZE HOTSPOTS"
  echo "=========================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo "Target: ${NEXT_FILE}"
  echo

  if [ -f "${NEXT_FILE}" ]; then
    echo "1) High-risk patterns"
    rg -n 'SYSTEM_HEALTH|operator-guidance|guidance|atlas|append|innerHTML|textContent|setInterval|EventSource|MutationObserver|No active tasks|Awaiting operator input|diagnostics/system-health' "${NEXT_FILE}" || true
    echo

    echo "2) Focused excerpts"
    while IFS=: read -r line _; do
      start=$(( line > 20 ? line - 20 : 1 ))
      end=$(( line + 40 ))
      echo "----- lines ${start}-${end} -----"
      sed -n "${start},${end}p" "${NEXT_FILE}"
      echo
    done < <(rg -n 'SYSTEM_HEALTH|operator-guidance|guidance|atlas|append|innerHTML|textContent|setInterval|EventSource|MutationObserver|No active tasks|Awaiting operator input|diagnostics/system-health' "${NEXT_FILE}" | cut -d: -f1 | awk '!seen[$0]++' | head -n 12)
  else
    echo "File not found: ${NEXT_FILE}"
  fi
} > "$NEXT_OUT"

echo "Wrote:"
echo "$DECISION_OUT"
echo "$NEXT_OUT"
