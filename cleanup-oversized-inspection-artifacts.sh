
#!/usr/bin/env bash

set -euo pipefail

echo "===== DISK BEFORE CLEANUP ====="

df -h .

echo

echo "===== STOP STUCK INSPECTION ====="

pkill -f inspect-missing-task-card-controls.sh || true

echo

echo "===== REMOVE OVERSIZED INSPECTION OUTPUTS ====="

rm -f missing-task-card-controls-inspection-20260528_210608.md

rm -f missing-task-card-controls-inspection-20260528_210911.md

rm -f missing-task-card-controls-inspection-20260528_211710.md

rm -f api-tasks-probe-20260528_211710.json

echo

echo "===== VERIFY REMAINING INSPECTION FILES ====="

ls -lh missing-task-card-controls-inspection-*.md 2>/dev/null || true

echo

echo "===== DISK AFTER CLEANUP ====="

df -h .

git add cleanup-oversized-inspection-artifacts.sh

git commit -m "Add oversized inspection cleanup script"

git push

