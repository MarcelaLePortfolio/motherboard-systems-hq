
#!/usr/bin/env bash

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

OUT_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots/full_${TIMESTAMP}"

mkdir -p "$OUT_DIR"

echo "[1] Docker snapshot"

docker compose ps > "$OUT_DIR/docker_ps.txt" || true

echo "[2] Git state"

git status > "$OUT_DIR/git_status.txt" || true

git log --oneline -n 50 > "$OUT_DIR/git_log.txt" || true

echo "[3] API snapshot"

curl -s http://localhost:3000/api/tasks > "$OUT_DIR/api_tasks.json" || true

echo "[4] Logs"

docker compose logs --tail=500 worker > "$OUT_DIR/worker_logs.txt" || true

docker compose logs --tail=500 dashboard > "$OUT_DIR/dashboard_logs.txt" || true

echo "[5] Database dump"

docker compose exec -T postgres pg_dump -U postgres postgres > "$OUT_DIR/db.sql" || true

echo "[6] Artifacts archive"

docker compose exec -T worker tar -czf - /app/data/artifacts > "$OUT_DIR/artifacts.tar.gz" 2>/dev/null || true

echo "[7] Manifest"

cat > "$OUT_DIR/MANIFEST.txt" << MANIFEST

FULL SYSTEM BACKUP (MODE A)

Timestamp: $TIMESTAMP

Includes:

- docker compose ps

- git status + git log

- api tasks snapshot

- worker + dashboard logs

- postgres full dump

- artifacts archive

RESTORE ORDER:

1. git checkout <commit>

2. docker compose up -d

3. psql -U postgres postgres < db.sql

4. extract artifacts.tar.gz into /app/data/artifacts

Location:

$OUT_DIR

MANIFEST

echo "$OUT_DIR"

echo "BACKUP COMPLETE (MODE A)"

