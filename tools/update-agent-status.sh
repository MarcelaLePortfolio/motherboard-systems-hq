#!/bin/bash
# 🔹 Generates agent status + Matilda log JSON for dashboard
DASH_PATH="$HOME/Desktop/Motherboard_Systems_HQ/ui/dashboard/public"
STATUS_FILE="$DASH_PATH/agent-status.json"
LOG_FILE="$DASH_PATH/matilda-log.json"
MEM_LOG="$HOME/Desktop/memory/matilda_task_log.txt"

while true; do
  # Update agent status JSON
  cat > "$STATUS_FILE" <<JSON
{
  "matilda": "online",
  "cade": "online",
  "effie": "online",
  "lastUpdate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

  # Mirror last 10 log entries as JSON array for dashboard
  if [ -f "$MEM_LOG" ]; then
    tail -n 10 "$MEM_LOG" | jq -R . | jq -s . > "$LOG_FILE"
  else
    echo '[]' > "$LOG_FILE"
  fi

  sleep 30
done
