#!/bin/bash
# 🔍 Inspect latest backup archive contents
LATEST=$(ls -1t "$HOME/Desktop"/MOTHERBOARD_SYSTEMS_BACKUP_*.zip 2>/dev/null | head -n 1)

if [ ! -f "$LATEST" ]; then
  echo "❌ No backup zip found on Desktop"
  exit 1
fi

echo "🗂️ Latest backup: $LATEST"
unzip -l "$LATEST"
