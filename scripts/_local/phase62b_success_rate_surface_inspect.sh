#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SUCCESS_RATE_SURFACE_INSPECTION.txt"
: > "$OUT"

{
  echo "PHASE 62B — SUCCESS RATE SURFACE INSPECTION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== target file =="
  ls -l public/js/telemetry/success_rate_metric.js
  echo

  echo "== success_rate_metric.js =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,260p'
  echo

  echo "== neighboring telemetry files =="
  ls -l public/js/telemetry || true
  echo

  echo "== metric ownership guard =="
  nl -ba public/js/telemetry/phase65b_metric_ownership_guard.js | sed -n '1,220p' || true
  echo

  echo "== dashboard hook confirmation =="
  grep -n 'metric-success' public/dashboard.html public/index.html public/bundle.js 2>/dev/null || true
  echo

  echo "== task-events signal references =="
  grep -RIn 'task.completed\|task.failed\|success rate\|metric-success\|successNode' public/js public/bundle.js 2>/dev/null || true
  echo

  echo "== decision target =="
  echo "Confirm exact hydration logic and ownership boundaries before patching success_rate_metric.js"
} | tee "$OUT"
