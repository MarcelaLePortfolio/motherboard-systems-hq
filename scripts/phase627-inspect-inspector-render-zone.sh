#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase627-inspector-render-zone.md"

{
  echo "# Phase 627 Inspector Render Zone"
  echo
  echo "## public/js/phase61_recent_history_wire.js"
  sed -n '1,140p' public/js/phase61_recent_history_wire.js
  echo
  echo "## public/js/task-events-sse-client.js inspector area"
  sed -n '150,220p' public/js/task-events-sse-client.js
} > "$REPORT"

cat "$REPORT"
