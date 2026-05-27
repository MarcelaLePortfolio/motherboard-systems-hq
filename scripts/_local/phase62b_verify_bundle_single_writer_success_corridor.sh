#!/usr/bin/env bash
set -euo pipefail

SUMMARY="PHASE62B_POST_REBUILD_SUCCESS_SINGLE_WRITER_SUMMARY.txt"
OUT="PHASE62B_POST_REBUILD_SUCCESS_SINGLE_WRITER_VERIFICATION.txt"
: > "$SUMMARY"
: > "$OUT"

{
  echo "PHASE 62B — POST-REBUILD SUCCESS SINGLE WRITER VERIFICATION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== source neutralization =="
  grep -n "successNode = null" public/js/agent-status-row.js || echo "NOT FOUND"
  echo

  echo "== telemetry authority present =="
  grep -n 'load("/js/telemetry/success_rate_metric.js")' public/js/telemetry/phase65b_metric_bootstrap.js || echo "NOT FOUND"
  echo

  echo "== bundle success writer check =="
  if grep -n "successNode.textContent" public/bundle.js; then
    echo "bundle_direct_success_writer_present=yes"
  else
    echo "bundle_direct_success_writer_present=no"
  fi
  echo

  echo "== bundle neutralization proof =="
  grep -n "successNode = null" public/bundle.js || echo "NOT FOUND"
  echo

  echo "== bundle success corridor references =="
  grep -n "metric-success\\|successNode\\|completedCount\\|failedCount" public/bundle.js | head -40 || true
  echo

  echo "== key decision summary =="
  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "single_writer_bundle_pass=no"
  else
    echo "single_writer_bundle_pass=yes"
  fi

  if grep -q "successNode = null" public/js/agent-status-row.js 2>/dev/null; then
    echo "source_neutralized=yes"
  else
    echo "source_neutralized=no"
  fi

  if grep -q 'load("/js/telemetry/success_rate_metric.js")' public/js/telemetry/phase65b_metric_bootstrap.js 2>/dev/null; then
    echo "telemetry_authority_present=yes"
  else
    echo "telemetry_authority_present=no"
  fi
} | tee "$SUMMARY"

{
  echo "FULL OUTPUT"
  echo

  echo "== public/js/agent-status-row.js relevant area =="
  nl -ba public/js/agent-status-row.js | sed -n '360,540p'
  echo

  echo "== public/js/telemetry/success_rate_metric.js =="
  nl -ba public/js/telemetry/success_rate_metric.js | sed -n '1,240p'
  echo

  echo "== public/js/telemetry/phase65b_metric_bootstrap.js =="
  nl -ba public/js/telemetry/phase65b_metric_bootstrap.js | sed -n '1,120p'
  echo

  echo "== public/bundle.js focused excerpts =="
  grep -n "metric-success\\|successNode\\|completedCount\\|failedCount" public/bundle.js | head -120 || true
} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"
