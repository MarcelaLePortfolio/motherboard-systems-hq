#!/bin/bash
# 🛠️ Cade Maintenance Script
# Backs up current runtime log, clears it, restarts Cade, and starts live monitoring

MEMORY_DIR="$(dirname "$0")/../memory"
LOG_FILE="$MEMORY_DIR/cade_runtime.log"
BACKUP_FILE="$MEMORY_DIR/cade_runtime_backup_$(date +%Y%m%d_%H%M%S).log"

echo "📦 Backing up Cade runtime log..."
cp "$LOG_FILE" "$BACKUP_FILE"
echo "   ➜ Backup saved as $BACKUP_FILE"

echo "🧹 Clearing current Cade runtime log..."
echo "" > "$LOG_FILE"

echo "🔄 Restarting Cade via PM2..."
pm2 restart cade

echo "👀 Starting live log monitoring. Press Ctrl+C to exit."
tail -f "$LOG_FILE"
