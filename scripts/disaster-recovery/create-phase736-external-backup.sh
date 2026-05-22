
#!/bin/bash

set -euo pipefail

SNAPSHOT_ROOT="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

BACKUP_DIR="${SNAPSHOT_ROOT}/full-disaster-recovery-${TIMESTAMP}"

rm -rf "${SNAPSHOT_ROOT}/full-disaster-recovery-20260522-091536" "${SNAPSHOT_ROOT}/full-disaster-recovery-20260522-091609"

mkdir -p "$BACKUP_DIR"

rsync -a --exclude='node_modules' --exclude='.next' --exclude='.git' --exclude='dist' --exclude='coverage' ./ "$BACKUP_DIR/"

cat > "$BACKUP_DIR/PHASE736_BACKUP_MANIFEST.txt" << 'MANIFEST'

Phase 736 Render-Native Sandbox DR Checkpoint

Canonical Sandbox Command:

node scripts/render-native/run-sandbox-chain.mjs

Containment Status:

- Live Preview renderer untouched

- Runtime integration deferred

- Sandbox-only corridor preserved

MANIFEST

FILE_COUNT="$(find "$BACKUP_DIR" -type f | wc -l | tr -d ' ')"

if [ "$FILE_COUNT" -lt 20 ]; then

  echo "DR BACKUP FAILED: suspiciously low file count: $FILE_COUNT"

  exit 1

fi

echo "DR CHECKPOINT COMPLETE:"

echo "$BACKUP_DIR"

echo "FILE COUNT: $FILE_COUNT"

