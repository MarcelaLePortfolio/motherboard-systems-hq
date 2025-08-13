#!/bin/zsh

BACKUP_DIR="$HOME/Desktop/Motherboard_Systems_HQ/Backups"
ARCHIVE_DIR="$BACKUP_DIR/Archive"
LOG_DIR="$BACKUP_DIR/Logs"
mkdir -p "$ARCHIVE_DIR" "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M)
BACKUP_FILE="$BACKUP_DIR/MOTHERBOARD_SYSTEMS_BACKUP_${TIMESTAMP}.zip"

echo "[$(date)] Starting backup to $BACKUP_FILE" >> "$LOG_DIR/backup_rotation.log"

cd ~/Desktop/Motherboard_Systems_HQ
zip -r "$BACKUP_FILE" . -x "Backups/*" >> "$LOG_DIR/backup_rotation.log" 2>&1

# 1️⃣ Rotate backups (keep 2 in main, 3 in archive)
ls -1t "$BACKUP_DIR"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | tail -n +3 | while read -r file; do
  mv "$file" "$ARCHIVE_DIR"/
done

ls -1t "$ARCHIVE_DIR"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | tail -n +4 | xargs rm -f

# 2️⃣ Clean up ghost log files
# Detect files that were deleted but still consuming disk space
lsof +L1 | grep "$BACKUP_DIR" | awk '{print $2}' | sort -u | while read -r pid; do
  echo "[$(date)] Killing process $pid holding deleted backup log files" >> "$LOG_DIR/backup_rotation.log"
  kill -9 "$pid"
done

echo "[$(date)] Backup complete and rotation/cleanup done." >> "$LOG_DIR/backup_rotation.log"
