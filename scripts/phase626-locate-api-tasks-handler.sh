#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase626-api-tasks-handler-location.md"

{
  echo "# Phase 626 API Tasks Handler Location"
  echo
  grep -RIn --include="*.js" --include="*.ts" --include="*.mjs" \
    --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=.git \
    "app.get.(.*/api/tasks\\|/api/tasks\\|tasks.*payload\\|SELECT.*tasks" . || true
} > "$REPORT"

cat "$REPORT"
