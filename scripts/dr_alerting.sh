
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING DR ALERTING LAYER..."

LOG_FILE="logs/dr.log"

mkdir -p logs

if [ ! -f "$LOG_FILE" ]; then

  echo "NO DR LOG FOUND - SYSTEM MAY NOT BE RUNNING"

  exit 1

fi

FAILURES=$(grep -i "error\|fail\|missing" "$LOG_FILE" | tail -n 20 || true)

if [ -n "$FAILURES" ]; then

  echo "DR ALERT: ISSUES DETECTED"

  echo "$FAILURES"

  exit 2

fi

echo "DR ALERTING: ALL SYSTEMS HEALTHY"

