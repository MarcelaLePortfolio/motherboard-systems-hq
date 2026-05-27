#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_DASHBOARD_ASSET_LOAD_PATH_INSPECTION.txt"
SUMMARY="PHASE62B_DASHBOARD_ASSET_LOAD_PATH_SUMMARY.txt"

: > "$OUT"
: > "$SUMMARY"

{
  echo "PHASE 62B — DASHBOARD ASSET LOAD PATH INSPECTION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "== branch =="
  git branch --show-current
  echo

  echo "== dashboard script tags =="
  grep -nE 'bundle\.js|bundle-core\.js|phase65b_metric_bootstrap\.js|telemetry/' public/dashboard.html public/index.html 2>/dev/null || true
  echo

  echo "== server asset routes =="
  grep -nE 'bundle\.js|dashboard\.html|express\.static|/dashboard|/bundle\.js' server.mjs 2>/dev/null || true
  echo

  echo "== bundle source map clues =="
  grep -nE 'agent-status-row\.js|success_rate_metric\.js|running_tasks_metric\.js|latency_metric\.js|phase65b_metric_bootstrap\.js' public/bundle.js.map 2>/dev/null | head -40 || true
  echo

  echo "== build tool clues =="
  grep -RInE 'esbuild|rollup|webpack|parcel|vite|bundle\.js|bundle-core\.js' package.json package-lock.json .github public scripts 2>/dev/null | head -80 || true
  echo

  echo "== key decision summary =="
  if grep -q "successNode.textContent" public/bundle.js 2>/dev/null; then
    echo "bundle_writer_present=yes"
  else
    echo "bundle_writer_present=no"
  fi

  if grep -q "successNode = null" public/js/agent-status-row.js 2>/dev/null; then
    echo "source_neutralized=yes"
  else
    echo "source_neutralized=no"
  fi

  if grep -q 'src="/bundle.js"' public/dashboard.html 2>/dev/null || grep -q "bundle.js" public/dashboard.html 2>/dev/null; then
    echo "dashboard_uses_bundle=yes"
  else
    echo "dashboard_uses_bundle=no"
  fi

  if grep -q 'phase65b_metric_bootstrap.js' public/dashboard.html 2>/dev/null; then
    echo "dashboard_loads_bootstrap_directly=yes"
  else
    echo "dashboard_loads_bootstrap_directly=no"
  fi
} | tee "$SUMMARY"

{
  echo "FULL OUTPUT"
  echo
  echo "== public/dashboard.html =="
  nl -ba public/dashboard.html | sed -n '1,260p'
  echo
  echo "== public/index.html =="
  nl -ba public/index.html | sed -n '1,220p'
  echo
  echo "== server.mjs relevant area =="
  nl -ba server.mjs | sed -n '320,380p'
} >> "$OUT"

echo "Summary written to $SUMMARY"
echo "Full log written to $OUT"
