#!/bin/bash
# 🔹 Generates minimal agent status JSON in dashboard/public
DASH_PATH="$HOME/Desktop/Motherboard_Systems_HQ/ui/dashboard/public"
STATUS_FILE="$DASH_PATH/agent-status.json"

while true; do
  cat > "$STATUS_FILE" <<JSON
{
  "matilda": "online",
  "cade": "online",
  "effie": "online",
  "lastUpdate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON
  sleep 30
done
