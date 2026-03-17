#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE80_2_DASHBOARD_ENTRY_DISCOVERY_${STAMP}.md"

{
  echo "# Phase 80.2 — Dashboard Entry Discovery"
  echo
  echo "Generated: ${STAMP}"
  echo

  echo "## Possible app roots"
  echo
  find dashboard -type f \( -name "page.tsx" -o -name "layout.tsx" -o -name "App.tsx" -o -name "index.tsx" \) | sort
  echo

  echo "## Files exporting React components"
  echo
  grep -RIn "export default function" dashboard/src || true
  echo

  echo "## Files using task data"
  echo
  grep -RIn "tasks" dashboard/src || true
  echo

  echo "## Any existing telemetry display"
  echo
  grep -RIn "Success Rate\|Tasks Running\|Tasks Completed\|Tasks Failed" dashboard/src || true

} > "${OUT}"

echo "Wrote ${OUT}"
