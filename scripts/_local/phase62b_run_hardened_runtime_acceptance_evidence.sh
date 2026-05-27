#!/usr/bin/env bash
set -euo pipefail

echo "== phase62b hardened terminal evidence run =="

./scripts/_local/phase62b_extract_runtime_acceptance_evidence.sh

echo
echo "== latest evidence artifacts =="

LATEST_LOG="$(ls -1t PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_SUMMARY="$(ls -1t PHASE62B_RUNTIME_ACCEPTANCE_EVIDENCE_SUMMARY_*.md 2>/dev/null | head -n 1 || true)"

echo "evidence_log=${LATEST_LOG:-missing}"
echo "summary=${LATEST_SUMMARY:-missing}"

echo
echo "== quick acceptance indicators =="

if [ -n "${LATEST_SUMMARY:-}" ]; then
  grep "terminal_success_event_observed" "$LATEST_SUMMARY" || true
  grep "terminal_failure_event_observed" "$LATEST_SUMMARY" || true
  grep "bundle_writer_regression" "$LATEST_SUMMARY" || true
  grep "ownership_regression" "$LATEST_SUMMARY" || true
fi

echo
echo "== optional: open artifacts locally =="
if [ -n "${LATEST_LOG:-}" ]; then
  open "$LATEST_LOG" || true
fi

if [ -n "${LATEST_SUMMARY:-}" ]; then
  open "$LATEST_SUMMARY" || true
fi

echo
echo "phase62b_terminal_acceptance_check=complete"

