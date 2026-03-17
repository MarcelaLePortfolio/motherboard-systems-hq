#!/usr/bin/env bash
set -euo pipefail

SUMMARY="PHASE62B_SUCCESS_RATE_TERMINAL_LISTENER_VERIFICATION_FIX_SUMMARY.txt"
OUT="PHASE62B_SUCCESS_RATE_TERMINAL_LISTENER_VERIFICATION_FIX.txt"
: > "$SUMMARY"
: > "$OUT"

{
  echo "PHASE 62B — SUCCESS RATE TERMINAL LISTENER VERIFICATION FIX"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== named terminal listener evidence in source =="
  grep -n '"task.completed"\|"task.failed"\|"task.event"\|"task.updated"\|"task.status"' public/js/telemetry/success_rate_metric.js || true
  echo

  echo "== direct addEventListener evidence in source =="
  grep -n 'source.addEventListener' public/js/telemetry/success_rate_metric.js || true
  echo

  echo "== bundle bootstrap presence check =="
  if grep -q 'phase65b_metric_bootstrap' public/bundle.js 2>/dev/null; then
    echo "bundle_bootstrap_present=yes"
  else
    echo "bundle_bootstrap_present=no"
  fi
  echo

  echo "== bundle direct success writer check =="
  if grep -q 'successNode.textContent' public/bundle.js 2>/dev/null; then
    echo "bundle_direct_success_writer_present=yes"
  else
    echo "bundle_direct_success_writer_present=no"
  fi
  echo

  echo "== corrected key decision summary =="
  if grep -q 'telemetry/phase65b_metric_bootstrap.js' public/js/dashboard-bundle-entry.js 2>/dev/null; then
    echo "dashboard_bundle_imports_bootstrap=yes"
  else
    echo "dashboard_bundle_imports_bootstrap=no"
  fi

  if grep -q '"task.completed"' public/js/telemetry/success_rate_metric.js 2>/dev/null && \
     grep -q '"task.failed"' public/js/telemetry/success_rate_metric.js 2>/dev/null && \
     grep -q 'eventNames.forEach' public/js/telemetry/success_rate_metric.js 2>/dev/null; then
    echo "success_metric_listens_named_terminal_events=yes"
  else
    echo "success_metric_listens_named_terminal_events=no"
  fi

  if grep -q 'successNode = null' public/js/agent-status-row.js 2>/dev/null; then
    echo "shared_metrics_success_writer_neutralized=yes"
  else
    echo "shared_metrics_success_writer_neutralized=no"
  fi
} | tee "$SUMMARY"

{
  echo "FULL OUTPUT"
  echo
  echo "== public/js/telemetry/success_rate_metric.js =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,280p'
  echo
  echo "== public/js/dashboard-bundle-entry.js =="
  nl -ba public/js/dashboard-bundle-entry.js | sed -n '1,120p'
  echo
  echo "== public/bundle.js focused excerpts =="
  grep -n 'phase65b_metric_bootstrap\|successNode\|task.completed\|task.failed\|eventNames' public/bundle.js | head -200 || true
} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"
