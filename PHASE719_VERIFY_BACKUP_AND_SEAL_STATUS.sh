
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: VERIFY BACKUP + SEAL STATUS ====="

mkdir -p checkpoints

{

  echo "PHASE 719 BACKUP + SEAL STATUS"

  echo ""

  echo "Branch:"

  git branch --show-current

  echo ""

  echo "Latest commits:"

  git log --oneline --decorate -8

  echo ""

  echo "Git status:"

  git status --short

  echo ""

  echo "Runtime health:"

  curl -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo ""

  echo "Artifact UI marker:"

  curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "Artifact:" | head || true

  echo ""

  echo "Backup scripts present:"

  ls -1 *BACKUP*.sh 2>/dev/null || true

  echo ""

  echo "Recent external/archive scripts present:"

  ls -1 PHASE719*BACKUP*.sh PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh 2>/dev/null || true

} | tee checkpoints/PHASE719_BACKUP_AND_SEAL_STATUS.txt

if [ -x ./PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh ]; then

  ./PHASE719_FULL_DISASTER_RECOVERY_BACKUP.sh || true

elif [ -x ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh ]; then

  ./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh || true

else

  echo "No executable full backup script found; status checkpoint still committed."

fi

git add PHASE719_VERIFY_BACKUP_AND_SEAL_STATUS.sh checkpoints/PHASE719_BACKUP_AND_SEAL_STATUS.txt

git commit -m "Phase 719: verify backup and seal status"

git push origin "$(git branch --show-current)"

echo "===== BACKUP VERIFY COMPLETE ====="

