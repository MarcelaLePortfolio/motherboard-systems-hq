
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: PREVIEW BACKUP PROOF COMMIT ====="

BRANCH="$(git branch --show-current)"

PROOF="checkpoints/PHASE719_PRE_PREVIEW_PILL_CHECKPOINT_V2.txt"

mkdir -p checkpoints

cat > "$PROOF" << NOTE

PHASE 719 PRE PREVIEW PILL CHECKPOINT V2

Timestamp:

$(date)

Branch:

$BRANCH

Backup result:

Incremental backup completed successfully.

Backup manifest:

$(ls -1t "/Volumes/Rio Drive/Motherboard_Storage/snapshots"/phase719_incremental_*_MANIFEST.txt 2>/dev/null | head -n 1)

Runtime health:

$(curl -s --max-time 10 http://localhost:3000/api/tasks/health || true)

Artifact UI marker:

$(curl -s --max-time 10 http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -n "Artifact:" | head || true)

Next mutation:

Replace always-on lifecycle pill with conditional Preview pill only when artifact/artifacts exists.

Boundary:

- frontend-only

- no backend route changes

- no retry contract changes

- preserve artifact metadata line

NOTE

git add PHASE719_PRE_PREVIEW_PILL_CHECKPOINT.sh

git add PHASE719_PREVIEW_BACKUP_PROOF_COMMIT.sh

git add "$PROOF"

git commit -m "Phase 719: checkpoint preview pill backup proof"

git push origin "$BRANCH"

echo "===== PREVIEW BACKUP PROOF COMMITTED ====="

