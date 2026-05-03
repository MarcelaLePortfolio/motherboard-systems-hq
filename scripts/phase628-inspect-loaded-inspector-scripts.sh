#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase628-loaded-inspector-scripts.md"

{
  echo "# Phase 628 Loaded Inspector Scripts"
  echo
  echo "## Dashboard HTML script references"
  curl -sS http://localhost:3000/ | grep -o 'src="[^"]*"' | grep -i "inspector\\|task-events\\|phase61\\|phase53\\|phase57" || true
  echo
  echo "## Local index script references"
  grep -RIn "phase61_recent_history_wire\\|task-events-sse-client\\|execution_inspector" public index.html server.js server.mjs 2>/dev/null || true
} > "$REPORT"

cat "$REPORT"
