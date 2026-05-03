#!/usr/bin/env bash
set -euo pipefail

echo "== phase62b manual validation gate =="
echo "Open the dashboard and record runtime evidence before final acceptance."
echo

echo "== dashboard =="
open "http://127.0.0.1:8080/dashboard" || true
echo

echo "== validation result template =="
open "PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md" || true
echo

echo "== latest runtime validation log =="
LATEST_LOG="$(ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt 2>/dev/null | head -n 1 || true)"
echo "${LATEST_LOG:-<missing>}"
if [ -n "${LATEST_LOG:-}" ]; then
  open "$LATEST_LOG" || true
fi
echo

echo "== latest concise runtime summary =="
LATEST_SUMMARY="$(ls -1t PHASE62B_RUNTIME_STATUS_CONCISE_SUMMARY_20260317.md 2>/dev/null | head -n 1 || true)"
echo "${LATEST_SUMMARY:-<missing>}"
if [ -n "${LATEST_SUMMARY:-}" ]; then
  open "$LATEST_SUMMARY" || true
fi
echo

echo "== manual acceptance checklist =="
echo "- initial_success_rate"
echo "- post_success_terminal_success_rate"
echo "- post_failure_terminal_success_rate"
echo "- running_tasks_notes"
echo "- latency_notes"
echo "- layout_notes"
echo "- ownership_notes"
echo "- final_status"
echo
echo "Proceed to final acceptance only if visual runtime proof is clear."
