#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-real-task-ui-inspection.md"

{
  echo "# Phase 625 Real Task UI Inspection"
  echo
  echo "## dashboard-tasks-widget.js"
  sed -n '1,220p' public/js/dashboard-tasks-widget.js
  echo
  echo "## phase565_recent_tasks_wire.js"
  sed -n '1,220p' public/js/phase565_recent_tasks_wire.js
  echo
  echo "## task-events-sse-client.js"
  sed -n '1,220p' public/js/task-events-sse-client.js
  echo
  echo "## operatorGuidance.sse.js"
  sed -n '1,220p' public/js/operatorGuidance.sse.js
} > "$REPORT"
