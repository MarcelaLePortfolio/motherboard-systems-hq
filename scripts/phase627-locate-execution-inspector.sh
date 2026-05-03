#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase627-execution-inspector-location.md"
mkdir -p _reports

{
  echo "# Phase 627 Execution Inspector Location"
  echo
  echo "## Files referencing Execution Inspector"
  grep -RIn --include="*.js" --include="*.ts" --include="*.tsx" --include="*.mjs" \
    --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=.git \
    "Execution Inspector\|execution inspector\|execution-inspector\|ExecutionInspector" . || true

  echo
  echo "## Files referencing retry/requeue inspector logic"
  grep -RIn --include="*.js" --include="*.ts" --include="*.tsx" --include="*.mjs" \
    --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=.git \
    "retry\|requeue\|delegate-task\|selected task\|selectedTask" public app server 2>/dev/null || true
} > "$REPORT"

cat "$REPORT"
