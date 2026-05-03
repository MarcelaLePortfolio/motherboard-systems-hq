#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SUCCESS_SINGLE_WRITER_VERIFICATION.txt"
: > "$OUT"

{
  echo "PHASE 62B — SUCCESS SINGLE WRITER VERIFICATION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== agent-status-row success neutralization =="
  nl -ba public/js/agent-status-row.js | sed -n '360,540p'
  echo

  echo "== success telemetry writer =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,240p'
  echo

  echo "== bootstrap load path =="
  nl -ba public/js/telemetry/phase65b_metric_bootstrap.js | sed -n '1,120p'
  echo

  echo "== source-level success writer search =="
  grep -RIn "metric-success|successNode|completedCount|failedCount" public/js --exclude-dir=node_modules 2>/dev/null || true
  echo

  echo "== bundle-level success writer evidence =="
  grep -n "metric-success\|successNode\|completedCount\|failedCount" public/bundle.js 2>/dev/null || true
  echo

  echo "== decision =="
  echo "PASS only if source-level writer is telemetry module and shared metrics corridor is observer-only."
  echo "If bundle still contains a live success writer path, stop before further hydration edits and select bounded bundle-neutralization or rebuild inspection."
} | tee "$OUT"
