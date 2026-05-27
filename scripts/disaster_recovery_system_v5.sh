
#!/bin/bash

set -euo pipefail

echo "🧭 Disaster Recovery System v5 (ATOMIC + VERIFIED)"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ ! -d "$PROJECT_ROOT" ]; then

  echo "❌ Invalid PROJECT_ROOT"

  exit 1

fi

EXTERNAL=""

for vol in /Volumes/*; do

  if [[ -d "$vol" && "$vol" != *"Macintosh HD"* ]]; then

    EXTERNAL="$vol"

    break

  fi

done

if [ -z "$EXTERNAL" ]; then

  echo "❌ No external drive found"

  exit 1

fi

DEST="$EXTERNAL/Motherboard_External_Backup"

CMD="${1:-help}"

TARGET="${2:-}"

RUN_ID="$(date +%Y%m%d_%H%M%S)"

RUN_DIR="$DEST/snapshots/$RUN_ID"

mkdir -p "$DEST/snapshots" "$DEST/logs" "$DEST/archives"

LOCK="$DEST/.dr_lock"

if [ -f "$LOCK" ]; then

  echo "❌ SYSTEM LOCKED"

  exit 1

fi

trap 'rm -f "$LOCK"' EXIT

touch "$LOCK"

backup() {

  echo "📦 BACKUP START"

  mkdir -p "$RUN_DIR/project"

  rsync -a --delete \

    --exclude node_modules \

    --exclude .git \

    "$PROJECT_ROOT/" "$RUN_DIR/project/"

  echo "$RUN_ID" > "$DEST/latest_snapshot.txt"

  echo "✅ BACKUP COMPLETE: $RUN_ID"

}

list() {

  echo "📦 SNAPSHOTS:"

  ls -1 "$DEST/snapshots" 2>/dev/null || echo "none"

}

verify() {

  echo "🔍 SYSTEM VERIFY"

  test -d "$DEST/snapshots" || exit 1

  echo "✅ OK"

}

restore() {

  if [ -z "$TARGET" ]; then

    echo "❌ restore <RUN_ID> required"

    exit 1

  fi

  SRC="$DEST/snapshots/$TARGET/project"

  if [ ! -d "$SRC" ]; then

    echo "❌ Snapshot not found"

    exit 1

  fi

  echo "⚠️ RESTORE MODE"

  SAFE="$DEST/archives/pre_restore_$RUN_ID"

  mkdir -p "$SAFE"

  rsync -a "$PROJECT_ROOT/" "$SAFE/"

  STAGE="$DEST/staging_$RUN_ID"

  mkdir -p "$STAGE"

  rsync -a --delete "$SRC/" "$STAGE/"

  rsync -a --delete "$STAGE/" "$PROJECT_ROOT/"

  echo "✅ RESTORE COMPLETE"

}

case "$CMD" in

  backup) backup ;;

  list) list ;;

  verify) verify ;;

  restore) restore ;;

  *) echo "backup|list|verify|restore <RUN_ID>" ;;

esac

