#!/bin/zsh
BACKUP_DIR="$HOME/Desktop/Motherboard_Systems_HQ/Backups"
ARCHIVE_DIR="$BACKUP_DIR/Archive"

# Ensure directories exist
mkdir -p "$ARCHIVE_DIR" "$BACKUP_DIR/Logs"

# Step 1: Move old backups from main folder to archive, keeping 2 newest
ls -1t "$BACKUP_DIR"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | tail -n +3 | while read -r file; do
  mv "$file" "$ARCHIVE_DIR"/
done

# Step 2: Keep only 3 newest in archive
ls -1t "$ARCHIVE_DIR"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | tail -n +4 | xargs rm -f

# Optional: Log the rotation
echo "[$(date)] Backup rotation complete." >> "$BACKUP_DIR/Logs/backup_rotation.log"
