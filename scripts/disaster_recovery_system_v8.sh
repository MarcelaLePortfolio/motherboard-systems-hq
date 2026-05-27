
#!/bin/bash

set -euo pipefail

echo "🛡️ DR SYSTEM v8 — BULLETPROOF CONTRACT ENGINE"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DEST="${DEST:-/Volumes/Rio Drive/Motherboard_External_Backup}"

CMD="${1:-help}"

TARGET="${2:-}"

RUN_ID="$(date +%Y%m%d_%H%M%S)"

LOCK="$DEST/.dr_lock"

validate_run_id() {

  echo "$1" | grep -Eq '^[0-9]{8}_[0-9]{6}$'

}

require_dir() {

  if [ ! -d "$1" ]; then

    echo "❌ Missing directory: $1"

    exit 1

  fi

}

run_rsync() {

  local src="$1"

  local dst="$2"

  if [ -z "$src" ] || [ -z "$dst" ]; then

    echo "❌ RSYNC CONTRACT VIOLATION"

    exit 1

  fi

  rsync -a "$src" "$dst"

}

if [ -f "$LOCK" ]; then

  echo "❌ SYSTEM LOCKED"

  exit 1

fi

trap 'rm -f "$LOCK"' EXIT

touch "$LOCK"

backup() {

  require_dir "$PROJECT_ROOT"

  SNAP="$DEST/snapshots/$RUN_ID"

  mkdir -p "$SNAP/project"

  echo "📦 BACKUP $RUN_ID"

  rsync -a --delete \

    --exclude node_modules \

    --exclude .git \

    "$PROJECT_ROOT/" "$SNAP/project/"

  echo "$RUN_ID" > "$DEST/latest_snapshot.txt"

  echo "✅ BACKUP DONE"

}

list() {

  ls -1 "$DEST/snapshots" 2>/dev/null || echo "no snapshots"

}

verify_snapshot() {

  local id="${1:-$(cat "$DEST/latest_snapshot.txt" 2>/dev/null || true)}"

  if ! validate_run_id "$id"; then

    echo "❌ INVALID RUN_ID"

    exit 1

  fi

  require_dir "$DEST/snapshots/$id/project"

  echo "✅ SNAPSHOT VALID: $id"

}

restore() {

  if ! validate_run_id "$TARGET"; then

    echo "❌ INVALID RUN_ID FORMAT"

    exit 1

  fi

  SRC="$DEST/snapshots/$TARGET/project"

  require_dir "$SRC"

  require_dir "$PROJECT_ROOT"

  echo "⚠️ RESTORE START"

  BACKUP="$DEST/archives/pre_restore_$RUN_ID"

  mkdir -p "$BACKUP"

  rsync -a "$PROJECT_ROOT/" "$BACKUP/"

  STAGE="$DEST/staging_$RUN_ID"

  mkdir -p "$STAGE"

  run_rsync "$SRC/" "$STAGE/"

  run_rsync "$STAGE/" "$PROJECT_ROOT/"

  echo "✅ RESTORE COMPLETE"

}

case "$CMD" in

  backup) backup ;;

  list) list ;;

  verify) verify_snapshot "$TARGET" ;;

  restore) restore ;;

  *) echo "usage: backup | list | verify <RUN_ID> | restore <RUN_ID>" ;;

esac

