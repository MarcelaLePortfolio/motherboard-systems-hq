
#!/bin/bash

set -euo pipefail

echo "== PHASE 731 RECOVER FAILED DR SNAPSHOT ATTEMPT =="

echo

echo "Current git status:"

git status --short

echo

echo "Restoring accidentally modified backup script from HEAD..."

git restore PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh

echo

echo "Removing incomplete refresh-state file if present..."

rm -f runtime/semantic-preview-planning/PHASE731_DISASTER_RECOVERY_REFRESH_STATE.md

echo

echo "Status after recovery:"

git status --short

echo

echo "Inspecting backup script failure area:"

nl -ba PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh | sed -n '1,80p'

echo

echo "RECOVERY COMPLETE: backup script restored; failed snapshot attempt not sealed."

