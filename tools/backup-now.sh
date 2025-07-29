#!/bin/bash
# Backup script (with hidden files) for Motherboard_Systems_HQ

TS=$(date +"%Y%m%d_%H%M")
SRC="$HOME/Desktop/Motherboard_Systems_HQ"
DEST="$HOME/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_${TS}.zip"

if [ ! -d "$SRC" ]; then
  echo "❌ Project folder not found at: $SRC"
  exit 1
fi

cd "$HOME/Desktop"
# ✅ Include hidden files (dotglob)
cp -R "$SRC" Motherboard_Systems_HQ_tmp
zip -r -q "$DEST" Motherboard_Systems_HQ_tmp
rm -rf Motherboard_Systems_HQ_tmp

echo "✅ Backup complete: $DEST"
