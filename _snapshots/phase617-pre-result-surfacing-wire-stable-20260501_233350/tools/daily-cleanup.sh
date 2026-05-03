/* eslint-disable import/no-commonjs */
#!/bin/bash
DESKTOP="$HOME/Desktop"
PROJECT_DIR="$DESKTOP/Motherboard_Systems_HQ"
ARCHIVE_DIR="$PROJECT_DIR/Backups/Archive"
LOG_FILE="$DESKTOP/MOTHERBOARD_CLEANUP_LOG_$(date +"%Y%m%d_%H%M").txt"

echo "🧹 Daily Cleanup started at $(date)" | tee -a "$LOG_FILE"

# 1️⃣ Move older backups & logs to Archive (keep 2 latest on Desktop)
cd "$DESKTOP"

ls -t MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | tail -n +3 | while read old_backup; do
  mv "$old_backup" "$ARCHIVE_DIR/"
  echo "📦 Moved old backup: $old_backup" | tee -a "$LOG_FILE"
done

ls -t MOTHERBOARD_BACKUP_LOG_*.txt 2>/dev/null | tail -n +3 | while read old_log; do
  mv "$old_log" "$ARCHIVE_DIR/"
  echo "📄 Moved old log: $old_log" | tee -a "$LOG_FILE"
done

# 2️⃣ Purge Archive files older than 30 days
find "$ARCHIVE_DIR" -type f -mtime +30 -print -delete | while read deleted; do
  echo "🗑️ Deleted old archive file: $deleted" | tee -a "$LOG_FILE"
done

echo "✅ Cleanup complete at $(date)" | tee -a "$LOG_FILE"
