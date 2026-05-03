#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase628-selection-bridge-zone.md"
mkdir -p _reports

{
  echo "# Phase 628 Selection Bridge Patch Zone"
  echo
  echo "## dashboard task render zone"
  sed -n '90,145p' public/js/dashboard-tasks-widget.js
  echo
  echo "## inspector render/filter zone"
  sed -n '35,95p' public/js/phase61_recent_history_wire.js
} > "$REPORT"

cat "$REPORT"
