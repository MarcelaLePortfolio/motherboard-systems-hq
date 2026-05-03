#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-real-ui-targets.md"

{
  echo "# Phase 625 Real UI Targets"
  echo
  echo "## Primary production candidates"
  echo "- public/js/dashboard-tasks-widget.js"
  echo "- public/js/phase565_recent_tasks_wire.js"
  echo "- public/js/task-events-sse-client.js"
  echo "- public/js/operatorGuidance.sse.js"
  echo "- public/js/phase538_execution_inspector_retry_strategies.js"
  echo "- public/js/phase535_execution_inspector_requeue.js"
  echo "- public/js/phase537_execution_inspector_retry.js"
  echo
  echo "## React candidate"
  echo "- app/demo-runtime/page.tsx"
  echo
  echo "## Phase 625 conclusion"
  echo "The real live task UI is currently more likely in public/js dashboard wiring than in app/components."
  echo "Next safe step: inspect public/js/dashboard-tasks-widget.js and public/js/phase565_recent_tasks_wire.js before wiring guidance into the live surface."
} > "$REPORT"

cat "$REPORT"
