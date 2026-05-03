#!/bin/bash
set -euo pipefail

OUT="PHASE534_EXECUTION_INSPECTOR_EXPAND_AUDIT.txt"

{
  echo "PHASE 534 EXECUTION INSPECTOR EXPANDED VIEW AUDIT"
  echo
  echo "=== Active client ==="
  sed -n '1,180p' public/js/task-events-sse-client.js
  echo
  echo "=== Active layout fix ==="
  sed -n '1,180p' public/js/phase533_execution_inspector_layout_fix.js
  echo
  echo "=== Previous expanded feature references ==="
  grep -n "selectedPanel\|Selected Task\|View JSON\|Copy ID\|Requeue\|Retry Differently\|Cancel\|data-action\|selectedEventId\|showJsonForEventId" public/js/phase457_restore_task_panels.BROKEN_BACKUP.js || true
  echo
  echo "=== Previous expanded implementation excerpt ==="
  sed -n '120,323p' public/js/phase457_restore_task_panels.BROKEN_BACKUP.js
} > "$OUT"

cat "$OUT"
