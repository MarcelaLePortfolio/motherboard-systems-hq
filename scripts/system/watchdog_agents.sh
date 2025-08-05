#!/bin/bash
# 🛡️ Motherboard Systems HQ - Agent Watchdog
# Automatically falls back to stub mode if full agents crash repeatedly.

LOG_FILE="scripts/system/watchdog.log"
MAX_RESTARTS=3
WINDOW_SECONDS=60

echo "🔹 Watchdog started at $(date)" >> "$LOG_FILE"

while true; do
  # Capture PM2 JSON status
  STATUS=$(pm2 jlist)
  
  # Extract crash counts and uptime for each agent
  for AGENT in cade effie matilda; do
    RESTARTS=$(echo "$STATUS" | jq ".[] | select(.name==\"$AGENT\") | .pm2_env.restart_time")
    UPTIME=$(echo "$STATUS" | jq ".[] | select(.name==\"$AGENT\") | .pm2_env.pm_uptime")

    # If agent has restarted more than MAX_RESTARTS and uptime < WINDOW_SECONDS
    if [[ "$RESTARTS" -ge "$MAX_RESTARTS" && "$UPTIME" -lt "$WINDOW_SECONDS" ]]; then
      echo "⚠️  Agent $AGENT unstable! Restarted $RESTARTS times in last $WINDOW_SECONDS seconds." >> "$LOG_FILE"
      echo "⚠️  Triggering automatic fallback to stub mode..." >> "$LOG_FILE"
      
      # Switch to stub mode
      bash scripts/system/toggle_agents.sh stub >> "$LOG_FILE" 2>&1
      
      echo "✅ Auto-fallback complete at $(date)" >> "$LOG_FILE"
      exit 0
    fi
  done

  sleep 10
done
