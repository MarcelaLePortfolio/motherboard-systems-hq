
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 INCREMENTAL BACKUP START ====="

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

BACKUP_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

BACKUP_NAME="phase719_incremental_${TIMESTAMP}"

mkdir -p "$BACKUP_DIR"

echo "[1] Docker snapshot"

docker compose ps > "$BACKUP_DIR/${BACKUP_NAME}_docker_ps.txt" || true

echo "[2] Git snapshot"

git status --short > "$BACKUP_DIR/${BACKUP_NAME}_git_status.txt" || true

git log --oneline -20 > "$BACKUP_DIR/${BACKUP_NAME}_git_log.txt" || true

echo "[3] Worker logs"

docker compose logs --tail=200 worker > "$BACKUP_DIR/${BACKUP_NAME}_worker_logs.txt" || true

echo "[4] Dashboard logs"

docker compose logs --tail=200 dashboard > "$BACKUP_DIR/${BACKUP_NAME}_dashboard_logs.txt" || true

echo "[5] API snapshot"

curl -s http://localhost:3000/api/tasks > "$BACKUP_DIR/${BACKUP_NAME}_api_tasks.json" || true

echo "[6] Lightweight repo delta (no tar freeze risk)"

git diff --name-only > "$BACKUP_DIR/${BACKUP_NAME}_git_diff.txt" || true

echo "[7] Manifest"

cat > "$BACKUP_DIR/${BACKUP_NAME}_MANIFEST.txt" << MANIFEST

Incremental Backup: ${BACKUP_NAME}

Timestamp: ${TIMESTAMP}

Includes:

- docker ps snapshot

- git status + log

- worker logs

- dashboard logs

- API tasks snapshot

- git diff (changed files only)

NOTE:

No full tar archive included to avoid I/O stall on external drive.

Location:

$BACKUP_DIR/

MANIFEST

echo ""

echo "Backup complete:"

echo "$BACKUP_DIR/${BACKUP_NAME}_MANIFEST.txt"

echo "===== PHASE 719 INCREMENTAL BACKUP COMPLETE ====="

