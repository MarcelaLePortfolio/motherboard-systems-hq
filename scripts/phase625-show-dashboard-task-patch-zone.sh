#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-dashboard-task-patch-zone.md"

{
  echo "# Phase 625 Dashboard Task Patch Zone"
  echo
  echo "## Lines 35-175 from public/js/dashboard-tasks-widget.js"
  sed -n '35,175p' public/js/dashboard-tasks-widget.js
} > "$REPORT"
