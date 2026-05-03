#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase626-api-tasks-list-zone.md"

{
  echo "# Phase 626 API Tasks List Zone"
  echo
  echo "## server/routes/api-tasks-postgres.mjs lines 38-85"
  sed -n '38,85p' server/routes/api-tasks-postgres.mjs
} > "$REPORT"

cat "$REPORT"
