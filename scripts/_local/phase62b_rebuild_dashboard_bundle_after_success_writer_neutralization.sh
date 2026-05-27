#!/usr/bin/env bash
set -euo pipefail

SUMMARY="PHASE62B_BUNDLE_REBUILD_AFTER_SUCCESS_NEUTRALIZATION_SUMMARY.txt"
OUT="PHASE62B_BUNDLE_REBUILD_AFTER_SUCCESS_NEUTRALIZATION.txt"

: > "$SUMMARY"
: > "$OUT"

{
  echo "PHASE 62B — BUNDLE REBUILD AFTER SUCCESS WRITER NEUTRALIZATION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== precheck source neutralization =="
  grep -n "successNode = null" public/js/agent-status-row.js || {
    echo "ERROR: source neutralization not present in public/js/agent-status-row.js"
    exit 1
  }
  echo

  echo "== precheck dashboard asset path =="
  grep -n 'bundle.js' public/dashboard.html
  echo

  echo "== rebuild dashboard bundle =="
  npm run build:dashboard-bundle
  echo

  echo "== post-rebuild success writer checks =="
  echo "-- bundle successNode binding --"
  grep -n "successNode" public/bundle.js | head -20 || true
  echo
  echo "-- bundle direct success writer --"
  if grep -n "successNode.textContent" public/bundle.js; then
    echo "bundle_direct_success_writer_present=yes"
  else
    echo "bundle_direct_success_writer_present=no"
  fi
  echo
  echo "-- bundle neutralization proof --"
  grep -n "successNode = null" public/bundle.js || true
  echo
  echo "-- bundle source map includes agent-status-row origin --"
  grep -n 'js/agent-status-row.js' public/bundle.js.map | head -5 || true
  echo
  echo "== decision =="
  echo "PASS only if bundle_direct_success_writer_present=no"
} | tee "$SUMMARY"

{
  echo "FULL OUTPUT"
  echo
  echo "== package.json build script =="
  nl -ba package.json | sed -n '1,80p'
  echo
  echo "== bundle excerpts =="
  grep -n "successNode\|completedCount\|failedCount" public/bundle.js | head -80 || true
} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"
