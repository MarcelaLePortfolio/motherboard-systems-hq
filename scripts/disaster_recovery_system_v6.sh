
#!/bin/bash

set -euo pipefail

echo "🛡️ Disaster Recovery System v6 — BASTION MODE (BULLETPROOF)"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ ! -d "$PROJECT_ROOT" ]; then

  echo "❌ INVALID PROJECT ROOT"

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

  echo "❌ NO EXTERNAL DRIVE DETECTED"

  exit 1

fi

DEST="$EXTERNAL/Motherboard_External_Backup"

CMD="${1:-help}"

TARGET="${2:-}"

RUN_ID="$(date +%Y%m%d_%H%M%S)"

SNAP_DIR="$DEST/snapshots/$RUN_ID"

LOCK="$DEST/.dr_lock"

if [ -f "$LOCK" ]; then

  echo "❌ SYSTEM LOCKED"

  exit 1

fi

trap 'rm -f "$LOCK"' EXIT

touch "$LOCK"

mkdir -p "$DEST/snapshots" "$DEST/logs" "$DEST/archives"

generate_manifest() {

  echo "🧾 Generating manifest..."

  find "$SNAP_DIR/project" -type f > "$SNAP_DIR/files.txt"

  find "$SNAP_DIR/project" -type f -exec shasum {} \; > "$SNAP_DIR/checksums.sha"

  wc -l < "$SNAP_DIR/files.txt" > "$SNAP_DIR/file_count.txt"

  du -sh "$SNAP_DIR/project" > "$SNAP_DIR/size.txt"

}

backup() {

  echo "📦 BACKUP START (BASTION)"

  mkdir -p "$SNAP_DIR/project"

  rsync -a --delete \

    --exclude node_modules \

    --exclude .git \

    "$PROJECT_ROOT/" "$SNAP_DIR/project/"

  generate_manifest

  echo "$RUN_ID" > "$DEST/latest_snapshot.txt"

  echo "✅ BACKUP COMPLETE: $RUN_ID"

}

list() {

  echo "📦 SNAPSHOTS:"

  ls -1 "$DEST/snapshots" 2>/dev/null || echo "none"

}

verify_snapshot() {

  echo "🔍 VERIFY SNAPSHOT"

  if [ -z "$TARGET" ]; then

    TARGET="$(cat "$DEST/latest_snapshot.txt" 2>/dev/null || echo "")"

  fi

  SNAP="$DEST/snapshots/$TARGET"

  if [ ! -d "$SNAP" ] || [ ! -f "$SNAP/checksums.sha" ]; then

    echo "❌ INVALID OR CORRUPT SNAPSHOT"

    exit 1

  fi

  echo "✅ SNAPSHOT VERIFIED"

}

restore() {

  if [ -z "$TARGET" ]; then

    echo "❌ restore <RUN_ID> required"

    exit 1

  fi

  SRC="$DEST/snapshots/$TARGET/project"

  if [ ! -d "$SRC" ]; then

    echo "❌ SNAPSHOT NOT FOUND"

    exit 1

  fi

  echo "⚠️ BASTION RESTORE INITIATED"

  verify_snapshot

  ROLLBACK="$DEST/archives/pre_restore_$RUN_ID"

  mkdir -p "$ROLLBACK"

  rsync -a "$PROJECT_ROOT/" "$ROLLBACK/"

  STAGE="$DEST/staging_$RUN_ID"

  mkdir -p "$STAGE"

  rsync -a --delete "$SRC/" "$STAGE/"

  rsync -a --delete "$STAGE/" "$PROJECT_ROOT/"

  echo "✅ RESTORE COMPLETE (BASTION SAFE MODE)"

}

case "$CMD" in

  backup) backup ;;

  list) list ;;

  verify) verify_snapshot ;;

  restore) restore ;;

  *) echo "backup | list | verify | restore <RUN_ID>" ;;

esac

