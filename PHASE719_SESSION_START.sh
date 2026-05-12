
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 SESSION START ====="

echo ""

echo "[1] Current repo state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Runtime state"

docker compose ps

echo ""

echo "[3] Verify dashboard and task API"

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo "dashboard + /api/tasks: PASS"

echo ""

echo "[4] Verify Phase 718 stable tag"

git tag --points-at HEAD | grep "phase718-operator-lineage-ui-stable" || true

echo ""

echo "[5] Note remaining cleanup"

echo "If PHASE718_FINAL_CHECKPOINT_AND_BACKUP.sh is still untracked, decide whether to commit it as a reusable helper or remove it."

echo ""

echo "===== PHASE 719 READY ====="

