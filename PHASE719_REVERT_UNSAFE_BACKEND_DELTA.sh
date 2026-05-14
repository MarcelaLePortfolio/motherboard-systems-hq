
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REVERT UNSAFE BACKEND DELTA ====="

echo ""

echo "[1] Confirm current branch"

git branch --show-current

echo ""

echo "[2] Save unsafe backend diff before revert"

mkdir -p checkpoints

git diff -- server.js server/routes/api-tasks-postgres.mjs > checkpoints/PHASE719_UNSAFE_BACKEND_DELTA_REVERTED.patch || true

echo ""

echo "[3] Revert only unsafe backend tracked files"

git checkout HEAD -- server.js server/routes/api-tasks-postgres.mjs

echo ""

echo "[4] Verify status after revert"

git status --short

echo ""

echo "[5] Restart dashboard container to ensure restored source is active"

docker compose restart dashboard

echo ""

echo "[6] Verify root route"

curl -i -s http://localhost:3000/ | head -n 30 || true

echo ""

echo "[7] Verify task API route"

curl -i -s http://localhost:3000/api/tasks | head -n 60 || true

echo ""

echo "[8] Write revert checkpoint"

cat > checkpoints/PHASE719_BACKEND_DELTA_REVERT_NOTE.md << 'NOTE'

PHASE 719 BACKEND DELTA REVERT NOTE

Reason:

- server.js and server/routes/api-tasks-postgres.mjs showed a destructive rewrite:

  54 insertions, 991 deletions.

- Runtime health check showed:

  / returned placeholder only.

  /api/tasks returned Cannot GET /api/tasks.

- This is not a safe baseline for artifact UI work.

Action:

- Reverted only:

  server.js

  server/routes/api-tasks-postgres.mjs

Preserved:

- Unsafe diff saved at:

  checkpoints/PHASE719_UNSAFE_BACKEND_DELTA_REVERTED.patch

Next:

- Restore stable task API/dashboard behavior first.

- Only then proceed to UI artifact visibility wiring.

NOTE

echo ""

echo "[9] Commit checkpoint + revert"

git add checkpoints/PHASE719_UNSAFE_BACKEND_DELTA_REVERTED.patch checkpoints/PHASE719_BACKEND_DELTA_REVERT_NOTE.md PHASE719_REVERT_UNSAFE_BACKEND_DELTA.sh server.js server/routes/api-tasks-postgres.mjs

git commit -m "Phase 719: revert unsafe backend delta before UI work"

echo ""

echo "[10] Push branch"

git push origin phase719-artifact-visibility-ui

echo ""

echo "===== REVERT COMPLETE ====="

