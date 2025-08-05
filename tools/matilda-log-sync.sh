#!/bin/bash
DESKTOP="$HOME/Desktop"
PROJECT_DIR="$DESKTOP/Motherboard_Systems_HQ"
LOG_TXT="$DESKTOP/memory/matilda_task_log.txt"
LOG_JSON="$PROJECT_DIR/ui/dashboard/public/matilda-log.json"
RUNTIME_LOG="$DESKTOP/MOTHERBOARD_MATILDA_LOGSYNC_$(date +"%Y%m%d_%H%M").txt"

echo "🔄 Matilda Log Sync started at $(date)" | tee -a "$RUNTIME_LOG"

# 1️⃣ Ensure Matilda log exists
if [ ! -f "$LOG_TXT" ]; then
  echo "⚠️ Log file not found: $LOG_TXT" | tee -a "$RUNTIME_LOG"
  exit 0
fi

# 2️⃣ Mirror the last 15 lines of log as JSON array
tail -n 15 "$LOG_TXT" | jq -R . | jq -s . > "$LOG_JSON"
echo "✅ Matilda log mirrored to: $LOG_JSON" | tee -a "$RUNTIME_LOG"

# 3️⃣ Optional: Ping Matilda via PM2 to keep her active
pm2 trigger matilda ping >/dev/null 2>&1 || true

echo "🎉 Log sync complete at $(date)" | tee -a "$RUNTIME_LOG"
