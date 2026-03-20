#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SUCCESS_RATE_SINGLE_WRITER_SELECTION_INSPECTION.txt"
: > "$OUT"

{
echo "PHASE 62B — SUCCESS RATE SINGLE WRITER CORRIDOR SELECTION"
echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo

echo "== branch =="
git branch --show-current
echo

echo "== locate all success metric writers =="
grep -RIn "metric-success" public --exclude-dir=node_modules 2>/dev/null || true
echo

echo "== locate all successNode writers =="
grep -RIn "successNode" public --exclude-dir=node_modules 2>/dev/null || true
echo

echo "== locate completed/failed counters =="
grep -RIn "completedCount\|failedCount" public --exclude-dir=node_modules 2>/dev/null || true
echo

echo "== telemetry module load confirmation =="
grep -RIn "success_rate_metric.js" public --exclude-dir=node_modules 2>/dev/null || true
echo

echo "== bootstrap load path =="
nl -ba public/js/telemetry/phase65b_metric_bootstrap.js | sed -n '1,200p' || true
echo

echo "== bundle writer presence check =="
grep -n "metric-success\|successNode\|completedCount\|failedCount" public/bundle.js 2>/dev/null || true
echo

echo "== authoritative corridor decision rule =="
echo "Authoritative writer must be:"
echo "1 telemetry module based"
echo "2 loaded via bootstrap"
echo "3 single writer confirmed"
echo

echo "== next action =="
echo "If multiple writers exist, select telemetry module as authority and neutralize others without layout or transport change."

} | tee "$OUT"
