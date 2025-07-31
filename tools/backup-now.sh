#!/bin/bash
set -e

PROJECT_DIR="$HOME/Desktop/Motherboard_Systems_HQ"
BACKUP_DIR="$PROJECT_DIR"
ARCHIVE_DIR="$PROJECT_DIR/Backups/Archive"
LOG_DIR="$PROJECT_DIR/Backups/Logs"

mkdir -p "$ARCHIVE_DIR" "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M)
ZIP_NAME="MOTHERBOARD_SYSTEMS_BACKUP_${TIMESTAMP}.zip"
ZIP_PATH="$BACKUP_DIR/$ZIP_NAME"
LOG_FILE="$LOG_DIR/backup_${TIMESTAMP}.log"

echo "📦 Starting backup at $(date)" | tee -a "$LOG_FILE"

# Create zip, excluding archives and top-level .log files
cd "$PROJECT_DIR/.."
zip -r "$ZIP_PATH" "Motherboard_Systems_HQ" \
  -x "Motherboard_Systems_HQ/Backups/Archive/*" \
  -x "Motherboard_Systems_HQ/*.zip" \
  -x "Motherboard_Systems_HQ/*.log" \
  | tee -a "$LOG_FILE"

echo "✅ Backup complete: $ZIP_PATH" | tee -a "$LOG_FILE"

# Move old zip backups to archive if >2 exist
cd "$BACKUP_DIR"
ls -tp MOTHERBOARD_SYSTEMS_BACKUP_*.zip | tail -n +3 | while read old_zip; do
  mv "$old_zip" "$ARCHIVE_DIR/" && echo "↪️ Moved old backup to archive: $old_zip" | tee -a "$LOG_FILE"
done

# Rotate logs: keep last 10
cd "$LOG_DIR"
ls -tp backup_*.log | tail -n +11 | xargs -I {} rm -- {}

echo "🧹 Log rotation complete. Old logs removed." | tee -a "$LOG_FILE"
