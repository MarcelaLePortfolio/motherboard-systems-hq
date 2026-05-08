
#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 FINAL CLEANUP RECOVERY ====="

rm -f PHASE717_PATCH_RECENT_TASKS_ARCHITECTURAL_LABELS.sh PHASE717_VERIFY_LIFECYCLE_LABELS.sh PHASE717_FORCE_CLEAN_DISCOVERY_ARTIFACTS.sh

git rm -f --ignore-unmatch PHASE717_CLEAN_HELPER_SCRIPTS.sh

cat > PHASE717_HELPER_SCRIPT_CLEANUP.txt << 'EON'

PHASE 717 — HELPER SCRIPT CLEANUP

Removed transient helper scripts after successful execution.

Preserved durable notes:

- PHASE717_DISCOVERY_RESET_NOTE.txt

- PHASE717_RECENT_TASKS_LIFECYCLE_LABELS.txt

- PHASE717_LIFECYCLE_LABELS_VERIFIED.txt

Current stable state:

- Recent Tasks renderer has lifecycle-card marker.

- Disabled operator-action placeholders are visible in task cards.

- Runtime verification passed on dashboard, containers, and /api/tasks.

- Retry/requeue remains disabled until exact safe endpoint contract is confirmed.

Cleanup note:

- The broken helper cleanup script was removed.

- Future cleanup commands should avoid multiline rm continuations in this shell.

EON

git add -A

git commit -m "Phase 717: finalize cleanup recovery" || true

git push origin dev

git status --short

git log --oneline --decorate -6

echo "===== PHASE 717 FINAL CLEANUP RECOVERY COMPLETE ====="

