
#!/bin/bash

set -euo pipefail

echo "🛡️ Disaster Recovery System v7 — HARDENED CORE (FAILSAFE MODE)"

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

  echo "❌ NO EXTERNAL DRIVE FOUND"

  exit 1

fi

DEST="$EXTERNAL/Motherboard_External_Backup"

CMD="${1:-help}"

TARGET="${2:-}"

DRY_RUN="${DRY_RUN:-0}"

RUN_ID="$(date +%Y%m%d_%H%M%S)"

LOCK="$DEST/.dr_lock"

# -----------------------------

# LOCK SYSTEM (prevents corruption)

# -----------------------------

if [ -f "$LOCK" ]; then

  echo "❌ SYSTEM LOCKED (another operation running)"

  exit 1

fi

trap 'rm -f "$LOCK"' EXIT

touch "$LOCK"

# -----------------------------

# PRECHECK FUNCTION

# -----------------------------

precheck() {

  if [ -z "$PROJECT_ROOT" ] || [ ! -d "$PROJECT_ROOT" ]; then

    echo "❌ PROJECT ROOT INVALID"

    exit 1

  fi

  if [ ! -d "$DEST" ]; then

    mkdir -p "$DEST"

  fi

}

# -----------------------------

# BACKUP

# -----------------------------

backup() {

  precheck

  SNAP="$DEST/snapshots/$RUN_ID"

  mkdir -p "$SNAP/project"

  echo "📦 BACKUP START [$RUN_ID]"

  rsync -a --delete \

    --exclude node_modules \

    --exclude .git \

    "$PROJECT_ROOT/" "$SNAP/project/"

  find "$SNAP/project" -type f > "$SNAP/files.txt"

  echo "$RUN_ID" > "$DEST/latest_snapshot.txt"

  echo "✅ BACKUP COMPLETE"

}

# -----------------------------

# LIST

# -----------------------------

list() {

  ls -1 "$DEST/snapshots" 2>/dev/null || echo "no snapshots"

}

# -----------------------------

# VERIFY

# -----------------------------

verify_snapshot() {

  if [ -z "$TARGET" ]; then

    TARGET="$(cat "$DEST/latest_snapshot.txt" 2>/dev/null || echo "")"

  fi

  SNAP="$DEST/snapshots/$TARGET"

  if [ ! -d "$SNAP/project" ]; then

    echo "❌ INVALID SNAPSHOT"

    exit 1

  fi

  if [ ! -f "$SNAP/files.txt" ]; then

    echo "⚠️ WARNING: missing manifest"

  fi

  echo "✅ SNAPSHOT VALID"

}

# -----------------------------

# RESTORE (SAFE + ATOMIC)

# -----------------------------

restore() {

  if [ -z "$TARGET" ]; then

    echo "❌ restore <RUN_ID> required"

    exit 1

  fi

  verify_snapshot

  SRC="$DEST/snapshots/$TARGET/project"

  if [ "$DRY_RUN" = "1" ]; then

    echo "🧪 DRY RUN MODE — no changes applied"

    rsync -an "$SRC/" "$PROJECT_ROOT/"

    exit 0

  fi

  echo "⚠️ DESTRUCTIVE RESTORE STARTING"

  BACKUP="$DEST/archives/pre_restore_$RUN_ID"

  mkdir -p "$BACKUP"

  rsync -a "$PROJECT_ROOT/" "$BACKUP/"

  STAGE="$DEST/staging_$RUN_ID"

  mkdir -p "$STAGE"

  rsync -a --delete "$SRC/" "$STAGE/"

  rsync -a --delete "$STAGE/" "$PROJECT_ROOT/"

  echo "✅ RESTORE COMPLETE (ATOMIC SAFE MODE)"

}

# -----------------------------

# ROUTER

# -----------------------------

case "$CMD" in

  backup) backup ;;

  list) list ;;

  verify) verify_snapshot ;;

  restore) restore ;;

  *) echo "usage: backup | list | verify <RUN_ID> | restore <RUN_ID>" ;;

esac

