#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase625-dashboard-task-render-target.md"

{
  echo "# Phase 625 Dashboard Task Render Target"
  echo
  echo "## Confirmed target"
  echo "public/js/dashboard-tasks-widget.js"
  echo
  echo "## Key render + task mapping area"
  grep -n "function render\|state.tasks =\|data.tasks\|data-tasks-list\|task.completed\|TASK_EVENT_DEBOUNCE_MS" public/js/dashboard-tasks-widget.js || true
  echo
  echo "## Conclusion"
  echo "Next safe patch should be limited to public/js/dashboard-tasks-widget.js."
  echo "It should preserve existing polling/SSE behavior and only add read-only guidance rendering when guidance exists on task payloads."
} > "$REPORT"
