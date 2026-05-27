#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SUCCESS_RATE_WRITER_CONFLICT_INSPECTION.txt"
: > "$OUT"

{
  echo "PHASE 62B — SUCCESS RATE WRITER CONFLICT INSPECTION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== agent-status-row.js around success ownership =="
  nl -ba public/js/agent-status-row.js | sed -n '340,540p'
  echo

  echo "== success_rate_metric.js =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,240p'
  echo

  echo "== running_tasks_metric.js =="
  nl -ba public/js/telemetry/running_tasks_metric.js | sed -n '1,220p'
  echo

  echo "== latency_metric.js =="
  nl -ba public/js/telemetry/latency_metric.js | sed -n '1,260p'
  echo

  echo "== metric bootstrap =="
  nl -ba public/js/telemetry/phase65b_metric_bootstrap.js | sed -n '1,220p' || true
  echo

  echo "== all metric-success writers in source =="
  grep -RIn "metric-success|successNode|textContent = total > 0|Success Rate" public/js 2>/dev/null || true
  echo

  echo "== bundle duplicate writer evidence =="
  grep -n "successNode" public/bundle.js 2>/dev/null || true
  echo

  echo "== decision =="
  echo "If success metric already has multiple live writers, do not patch hydration logic yet."
  echo "First reduce to a single source-of-truth writer within existing ownership discipline."
} | tee "$OUT"
