#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_NEXT_SAFE_METRIC_DISCOVERY.txt"
: > "$OUT"

echo "PHASE 62B — NEXT SAFE METRIC DISCOVERY" | tee -a "$OUT"
date -u | tee -a "$OUT"

echo | tee -a "$OUT"
echo "=== DASHBOARD METRIC HOOKS ===" | tee -a "$OUT"

grep -RIn "metric-" \
server.mjs \
public \
dashboard 2>/dev/null | tee -a "$OUT" || true

echo | tee -a "$OUT"
echo "=== TASK EVENT DERIVATIONS ===" | tee -a "$OUT"

grep -RIn \
"runningTasks\|completedTasks\|failedTasks\|activeRuns" \
server.mjs \
public 2>/dev/null | tee -a "$OUT" || true

echo | tee -a "$OUT"
echo "=== EVENT STREAM SURFACES ===" | tee -a "$OUT"

grep -RIn \
"events/tasks\|EventSource\|SSE" \
server.mjs \
public 2>/dev/null | tee -a "$OUT" || true

echo | tee -a "$OUT"
echo "DISCOVERY COMPLETE" | tee -a "$OUT"

