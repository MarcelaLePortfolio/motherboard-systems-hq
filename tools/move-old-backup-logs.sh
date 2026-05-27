/* eslint-disable import/no-commonjs */
#!/bin/bash
# 🗂 Move all old Motherboard backup logs from Desktop to Backups/Logs

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
LOG_DIR="$PROJECT_DIR/Backups/Logs"
mkdir -p "$LOG_DIR"

echo "📦 Moving old backup logs from Desktop to $LOG_DIR ..."

# Move all matching .txt logs from Desktop
mv ~/Desktop/MOTHERBOARD_BACKUP_LOG_*.txt "$LOG_DIR/" 2>/dev/null || true
mv ~/Desktop/MOTHERBOARD_MATILDA_LOGSYNC_*.txt "$LOG_DIR/" 2>/dev/null || true
mv ~/Desktop/MOTHERBOARD_CLEANUP_LOG_*.txt "$LOG_DIR/" 2>/dev/null || true

echo "✅ Logs moved. Current files in Logs directory:"
ls -lh "$LOG_DIR" | head -20
