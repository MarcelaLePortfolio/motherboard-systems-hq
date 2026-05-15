
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FULL DISASTER RECOVERY BACKUP START ====="

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

BACKUP_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

BACKUP_NAME="phase719_full_dr_backup_${TIMESTAMP}"

mkdir -p "$BACKUP_DIR"

echo "[1] Docker snapshot"

docker compose ps > "$BACKUP_DIR/${BACKUP_NAME}_docker_ps.txt" || true

docker images > "$BACKUP_DIR/${BACKUP_NAME}_docker_images.txt" || true

docker compose config > "$BACKUP_DIR/${BACKUP_NAME}_docker_compose.yml" || true

echo "[2] Git snapshot"

git status --short > "$BACKUP_DIR/${BACKUP_NAME}_git_status.txt" || true

git log --oneline -50 > "$BACKUP_DIR/${BACKUP_NAME}_git_log.txt" || true

echo "[3] Environment snapshot"

printenv > "$BACKUP_DIR/${BACKUP_NAME}_env.txt" || true

echo "[4] Database dump"

docker compose exec -T postgres pg_dump -U postgres postgres > \

"$BACKUP_DIR/${BACKUP_NAME}_db.sql" || true

echo "[5] Artifact snapshot"

docker compose exec -T worker tar -czf - /app/data/artifacts > \

"$BACKUP_DIR/${BACKUP_NAME}_artifacts.tar.gz" || true

echo "[6] API snapshot"

curl -s http://localhost:3000/api/tasks > \

"$BACKUP_DIR/${BACKUP_NAME}_api_tasks.json" || true

echo "[7] Repo snapshot"

tar -czf "$BACKUP_DIR/${BACKUP_NAME}_repo.tar.gz" . \

  --exclude=node_modules \

  --exclude=.git \

  --exclude=dist \

  --exclude=build \

  --exclude=.next \

  || true

echo "[8] Manifest"

cat > "$BACKUP_DIR/${BACKUP_NAME}_MANIFEST.txt" << MANIFEST

PHASE 719 FULL DISASTER RECOVERY BACKUP

Timestamp: ${TIMESTAMP}

Includes:

- Docker state

- Git state

- Environment snapshot

- PostgreSQL dump

- Artifact archive

- API snapshot

- Repo snapshot

Restore order:

1. git checkout

2. docker compose up -d

3. psql < db.sql

4. extract artifacts

5. restore env

MANIFEST

echo ""

echo "===== BACKUP COMPLETE ====="

echo "$BACKUP_DIR/${BACKUP_NAME}_MANIFEST.txt"

