
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FULL SYSTEM BACKUP START ====="

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

BACKUP_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

BACKUP_NAME="phase719_full_backup_${TIMESTAMP}"

mkdir -p "$BACKUP_DIR"

echo "[1] Docker status snapshot"

docker compose ps > "$BACKUP_DIR/${BACKUP_NAME}_docker_ps.txt" || true

echo "[2] Git status snapshot"

git status --short > "$BACKUP_DIR/${BACKUP_NAME}_git_status.txt" || true

echo "[3] Git log snapshot"

git log --oneline --decorate -20 > "$BACKUP_DIR/${BACKUP_NAME}_git_log.txt" || true

echo "[4] Worker + dashboard logs"

docker compose logs --tail=200 worker > "$BACKUP_DIR/${BACKUP_NAME}_worker_logs.txt" || true

docker compose logs --tail=200 dashboard > "$BACKUP_DIR/${BACKUP_NAME}_dashboard_logs.txt" || true

echo "[5] API snapshot"

curl -s http://localhost:3000/api/tasks > "$BACKUP_DIR/${BACKUP_NAME}_api_tasks.json" || true

echo "[6] Repo archive"

tar -czf "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" . \

  --exclude=node_modules \

  --exclude=.git \

  --exclude=dist \

  --exclude=build || true

echo "[7] Manifest"

cat > "$BACKUP_DIR/${BACKUP_NAME}_MANIFEST.txt" << MANIFEST

Backup: ${BACKUP_NAME}

Timestamp: ${TIMESTAMP}

Includes:

- docker ps

- git status

- git log

- worker logs

- dashboard logs

- api tasks snapshot

- repo archive

Location:

$BACKUP_DIR/${BACKUP_NAME}.tar.gz

MANIFEST

echo "$BACKUP_DIR/${BACKUP_NAME}.tar.gz"

echo "===== BACKUP COMPLETE ====="

