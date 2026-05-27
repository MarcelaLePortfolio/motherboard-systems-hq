#!/usr/bin/env bash
set -euo pipefail

SUMMARY="PHASE62B_SUCCESS_RATE_LIVE_HYDRATION_READINESS_SUMMARY.txt"
OUT="PHASE62B_SUCCESS_RATE_LIVE_HYDRATION_READINESS.txt"
: > "$SUMMARY"
: > "$OUT"

{
  echo "PHASE 62B — SUCCESS RATE LIVE HYDRATION READINESS CHECK"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== single-writer corridor precondition =="
  grep -n "successNode = null" public/js/agent-status-row.js || echo "SOURCE NEUTRALIZATION NOT FOUND"
  grep -n 'load("/js/telemetry/success_rate_metric.js")' public/js/telemetry/phase65b_metric_bootstrap.js || echo "TELEMETRY AUTHORITY NOT FOUND"
  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "bundle_direct_success_writer_present=yes"
  else
    echo "bundle_direct_success_writer_present=no"
  fi
  echo

  echo "== success metric attach corridor =="
  grep -n "addEventListener(\"message\"" public/js/telemetry/success_rate_metric.js || true
  grep -n "task.completed\\|task.failed\\|task.complete\\|task.done\\|task.success" public/js/telemetry/success_rate_metric.js || true
  echo

  echo "== task-events client named events =="
  grep -n "\"task.event\"\\|\"task.created\"\\|\"task.completed\"\\|\"task.failed\"\\|\"task.updated\"\\|\"task.status\"" public/js/task-events-sse-client.js || true
  echo

  echo "== success metric bootstrap path =="
  grep -n "success_rate_metric.js" public/js/telemetry/phase65b_metric_bootstrap.js || true
  echo

  echo "== key decision summary =="
  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "ready_for_hydration_patch=no"
  else
    echo "ready_for_hydration_patch=yes"
  fi

  if grep -q 'addEventListener("message"' public/js/telemetry/success_rate_metric.js 2>/dev/null; then
    echo "success_metric_currently_reads_message=yes"
  else
    echo "success_metric_currently_reads_message=no"
  fi

  if grep -q '"task.completed"' public/js/task-events-sse-client.js 2>/dev/null && grep -q '"task.failed"' public/js/task-events-sse-client.js 2>/dev/null; then
    echo "named_terminal_events_present=yes"
  else
    echo "named_terminal_events_present=no"
  fi
} | tee "$SUMMARY"

{
  echo "FULL OUTPUT"
  echo

  echo "== public/js/telemetry/success_rate_metric.js =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,240p'
  echo

  echo "== public/js/task-events-sse-client.js relevant area =="
  nl -ba public/js/task-events-sse-client.js | sed -n '300,380p'
  echo

  echo "== public/js/agent-status-row.js relevant area =="
  nl -ba public/js/agent-status-row.js | sed -n '360,540p'
  echo

  echo "== public/bundle.js focused excerpts =="
  grep -n "metric-success\\|successNode\\|completedCount\\|failedCount" public/bundle.js | head -120 || true
} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"
