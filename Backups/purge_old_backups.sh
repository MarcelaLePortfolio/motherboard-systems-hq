#!/bin/bash
BACKUP_DIR="$(pwd)"
ARCHIVE_DIR="$BACKUP_DIR/Archive"

mkdir -p "$ARCHIVE_DIR"

# Combine both naming patterns and sort by newest first
BACKUPS=$(ls -1t MOTHERBOARD*_BACKUP_*.zip Motherboard_Backup_*.zip 2>/dev/null)

# Keep the 2 most recent in Backups, move the rest to Archive
echo "$BACKUPS" | tail -n +3 | while read FILE; do
  mv "$FILE" "$ARCHIVE_DIR/"
done

# Keep only 3 most recent in Archive, delete older ones
ls -1t "$ARCHIVE_DIR"/*.zip 2>/dev/null | tail -n +4 | while read OLD_FILE; do
  rm "$OLD_FILE"
done

echo "✅ Purge complete. 2 newest backups in Backups/, 3 in Archive/"
