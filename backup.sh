
#!/usr/bin/env bash

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

BACKUP_NAME="full_backup_${TIMESTAMP}"

OUT_DIR="${BACKUP_DIR}/${BACKUP_NAME}"

mkdir -p "$OUT_DIR"

echo "[1] Docker state" > "$OUT_DIR/docker_ps.txt"

docker compose ps >> "$OUT_DIR/docker_ps.txt" || true

docker ps >> "$OUT_DIR/docker_ps.txt" || true

echo "[2] Git state" > "$OUT_DIR/git_status.txt"

git status >> "$OUT_DIR/git_status.txt" || true

git log --oneline -20 > "$OUT_DIR/git_log.txt" || true

echo "[3] API snapshot" > "$OUT_DIR/api_tasks.txt"

curl -s http://localhost:3000/api/tasks > "$OUT_DIR/api_tasks.json" || true

echo "[4] Worker logs" > "$OUT_DIR/worker_logs.txt"

docker compose logs --tail=200 worker >> "$OUT_DIR/worker_logs.txt" || true

echo "[5] Dashboard logs" > "$OUT_DIR/dashboard_logs.txt"

docker compose logs --tail=200 dashboard >> "$OUT_DIR/dashboard_logs.txt" || true

echo "[6] Postgres dump"

docker compose exec -T postgres pg_dump -U postgres postgres > "$OUT_DIR/db.sql" || true

echo "[7] Artifact directory snapshot (if mounted)"

docker compose exec -T worker sh -lc "tar -czf - /app/data/artifacts" > "$OUT_DIR/artifacts.tar.gz" || true

echo "[8] Manifest"

cat > "$OUT_DIR/MANIFEST.txt" << MANIFEST

FULL SYSTEM SNAPSHOT

Timestamp: $TIMESTAMP

Includes:

- docker state

- git state

- logs

- api snapshot

- postgres dump

- artifacts archive

Restore order:

1. git checkout repo

2. docker compose up -d

3. psql -U postgres postgres < db.sql

4. extract artifacts.tar.gz into /app/data/artifacts

Location:

$OUT_DIR

MANIFEST

echo "Backup complete:"

echo "$OUT_DIR"

