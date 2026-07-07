#!/bin/bash
# <0001fad8> Phase 5.3 — Automated backup + restore utility
set -e
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
DB_PATH="$BASE_DIR/db/main.db"
BACKUP_DIR="$BASE_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/main_backup_$TIMESTAMP.db"

mkdir -p "$BACKUP_DIR"

if [ "$1" == "restore" ]; then
  echo "🧩 Restoring most recent backup..."
  LATEST=$(ls -t "$BACKUP_DIR"/main_backup_*.db | head -n 1)
  if [ -z "$LATEST" ]; then
    echo "❌ No backups found to restore."
    exit 1
  fi
  cp "$LATEST" "$DB_PATH"
  echo "✅ Restored from $LATEST"
  exit 0
fi

echo "💾 Creating new backup snapshot..."
cp "$DB_PATH" "$BACKUP_FILE"
echo "✅ Backup saved → $BACKUP_FILE"
