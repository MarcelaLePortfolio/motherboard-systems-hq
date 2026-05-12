
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 REMOVE TRIAGE BACKUP HELPER ====="

echo ""

rm -f PHASE719_TRIAGE_UI_CHECKPOINT_BACKUP.sh

echo "[1] Repo status"

git status --short

echo ""

echo "[2] Recent commits"

git log --oneline --decorate -3

echo ""

echo "===== CLEANUP COMPLETE ====="

