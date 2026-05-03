#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_BUNDLE_SUCCESS_WRITER_ORIGIN_INSPECTION.txt"
SUMMARY="PHASE62B_BUNDLE_SUCCESS_WRITER_SUMMARY.txt"

: > "$OUT"
: > "$SUMMARY"

{
echo "PHASE 62B — BUNDLE SUCCESS WRITER ORIGIN INSPECTION"
echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo

echo "== key finding summary only =="
echo

echo "1 Source neutralization check:"
grep -n "successNode = null" public/js/agent-status-row.js || echo "NOT FOUND"

echo
echo "2 Telemetry writer present:"
grep -n "success_rate_metric.js" public/js/telemetry/phase65b_metric_bootstrap.js || echo "NOT FOUND"

echo
echo "3 Bundle still contains success writer:"
grep -n "successNode.textContent" public/bundle.js || echo "NOT FOUND"

echo
echo "4 Bundle completed/failed counters:"
grep -n "completedCount" public/bundle.js | head -5 || true
grep -n "failedCount" public/bundle.js | head -5 || true

echo
echo "5 Bundle source origin clues:"
grep -n "agent-status-row" public/bundle.js | head -5 || true

echo
echo "== decision hint =="
echo "If bundle success writer exists while source is neutralized:"
echo "bundle is stale OR separate corridor exists."

} | tee "$SUMMARY"

{
echo "FULL OUTPUT (truncated for safety)"
echo

grep -n "successNode" public/bundle.js | head -50 || true

echo
grep -n "completedCount" public/bundle.js | head -50 || true

echo
grep -n "failedCount" public/bundle.js | head -50 || true

} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"

