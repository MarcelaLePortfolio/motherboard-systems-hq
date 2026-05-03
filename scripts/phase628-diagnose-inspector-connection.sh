#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase628-inspector-connection-diagnostic.md"
mkdir -p _reports

{
  echo "# Phase 628 Inspector Connection Diagnostic"
  echo
  echo "## /api/tasks response"
  curl -sS http://localhost:3000/api/tasks || true
  echo
  echo
  echo "## Dashboard logs"
  docker compose logs --tail=120 dashboard || true
  echo
  echo
  echo "## Inspector script markers"
  grep -n "INSPECTOR_ENDPOINT\\|fetch(INSPECTOR_ENDPOINT\\|execution-inspector:selected-task\\|selectedTaskId\\|renderGuidance" public/js/phase61_recent_history_wire.js || true
  echo
  echo
  echo "## Dashboard task widget bridge markers"
  grep -n "data-task-row\\|execution-inspector:selected-task\\|selectedTaskId" public/js/dashboard-tasks-widget.js || true
} > "$REPORT"

cat "$REPORT"
