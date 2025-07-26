#!/bin/bash
# 🧰 Create a full backup of the Motherboard Systems HQ folder to Desktop
TIMESTAMP=$(date +"%Y%m%d_%H%M")
DEST="$HOME/Desktop/MOTHERBOARD_SYSTEMS_BACKUP_$TIMESTAMP.zip"
SRC="$HOME/Desktop/Motherboard Systems HQ"

if [ ! -d "$SRC" ]; then
  echo "❌ Project folder not found at: $SRC"
  exit 1
fi

echo "📦 Creating backup: $DEST"

if [ "$1" == "--include-hidden" ]; then
  echo "🕵️ Including hidden files (excluding .git)..."
  cd "$SRC/.." || exit 1
  zip -r -q "$DEST" "Motherboard Systems HQ" -x "Motherboard Systems HQ/.git/*"
else
  cd "$SRC/.." || exit 1
  zip -r -q "$DEST" "Motherboard Systems HQ"
fi

echo "✅ Backup created at $DEST"
