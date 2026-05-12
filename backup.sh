
#!/usr/bin/env bash

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

OUT_DIR="$BACKUP_DIR/backup_$TIMESTAMP"

mkdir -p "$OUT_DIR"

echo "[1] git snapshot"

git status > "$OUT_DIR/git_status.txt" || true

git log --oneline -20 > "$OUT_DIR/git_log.txt" || true

echo "[2] docker snapshot"

docker compose ps > "$OUT_DIR/docker_ps.txt" || true

docker ps >> "$OUT_DIR/docker_ps.txt" || true

echo "[3] api snapshot"

curl -s http://localhost:3000/api/tasks > "$OUT_DIR/api_tasks.json" || true

echo "[4] logs"

docker compose logs --tail=200 worker > "$OUT_DIR/worker_logs.txt" || true

docker compose logs --tail=200 dashboard > "$OUT_DIR/dashboard_logs.txt" || true

echo "[5] database dump"

docker compose exec -T postgres pg_dump -U postgres postgres > "$OUT_DIR/db.sql" || true

echo "[6] artifacts (if available)"

docker compose exec -T worker tar -czf - /app/data/artifacts > "$OUT_DIR/artifacts.tar.gz" 2>/dev/null || true

echo "[7] manifest"

cat > "$OUT_DIR/MANIFEST.txt" << MANIFEST

Backup created: $TIMESTAMP

Restore order:

1. git checkout <commit>

2. docker compose up -d

3. psql -U postgres postgres < db.sql

4. extract artifacts.tar.gz if needed

Location:

$OUT_DIR

MANIFEST

echo "Backup complete: $OUT_DIR"

