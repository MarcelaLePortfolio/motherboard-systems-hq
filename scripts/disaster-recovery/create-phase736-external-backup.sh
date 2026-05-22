
#!/bin/bash

set -euo pipefail

SNAPSHOT_ROOT="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

if [ ! -x "./scripts/recovery/run-complete-disaster-recovery-backup.sh" ]; then

  echo "Missing executable full DR script: ./scripts/recovery/run-complete-disaster-recovery-backup.sh"

  exit 1

fi

BEFORE_LATEST="$(find "$SNAPSHOT_ROOT" -maxdepth 1 -type d -name "full-disaster-recovery-*" | sort | tail -1 || true)"

./scripts/recovery/run-complete-disaster-recovery-backup.sh

AFTER_LATEST="$(find "$SNAPSHOT_ROOT" -maxdepth 1 -type d -name "full-disaster-recovery-*" | sort | tail -1 || true)"

if [ -z "$AFTER_LATEST" ]; then

  echo "DR BACKUP FAILED: no full-disaster-recovery folder found."

  exit 1

fi

if [ "$AFTER_LATEST" = "$BEFORE_LATEST" ]; then

  echo "DR BACKUP FAILED: no new full-disaster-recovery folder created."

  exit 1

fi

FILE_COUNT="$(find "$AFTER_LATEST" -type f | wc -l | tr -d ' ')"

if [ "$FILE_COUNT" -lt 20 ]; then

  echo "DR BACKUP FAILED: suspiciously low file count: $FILE_COUNT"

  echo "$AFTER_LATEST"

  exit 1

fi

cat > "$AFTER_LATEST/PHASE736_SANDBOX_BACKUP_NOTE.txt" << 'NOTE'

Phase 736 Render-Native Sandbox External DR Note

Protected corridor:

- deterministic semantic compiler

- render-native payload validator

- sandbox renderer

- payload inspector

- orchestration command

Canonical command:

node scripts/render-native/run-sandbox-chain.mjs

Containment:

- Live Preview renderer untouched

- Runtime integration deferred

- Sandbox-only validation preserved

NOTE

echo "PHASE736 FULL DR BACKUP VERIFIED:"

echo "$AFTER_LATEST"

echo "FILE COUNT: $FILE_COUNT"

