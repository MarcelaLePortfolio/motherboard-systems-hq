
#!/usr/bin/env bash

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

SNAPSHOT_DIR="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

OUT_DIR_META="$SNAPSHOT_DIR/phase719_full_backup_${TIMESTAMP}"

OUT_FILE="$SNAPSHOT_DIR/phase719_full_backup_${TIMESTAMP}.tar.gz"

mkdir -p "$OUT_DIR_META"

echo "[1] Docker snapshot"

docker compose ps > "$OUT_DIR_META/docker_ps.txt" || true

echo "[2] Git state"

git status > "$OUT_DIR_META/git_status.txt" || true

git log --oneline -n 50 > "$OUT_DIR_META/git_log.txt" || true

echo "[3] API snapshot"

curl -s http://localhost:3000/api/tasks > "$OUT_DIR_META/api_tasks.json" || true

echo "[4] Logs"

docker compose logs --tail=500 worker > "$OUT_DIR_META/worker_logs.txt" || true

docker compose logs --tail=500 dashboard > "$OUT_DIR_META/dashboard_logs.txt" || true

echo "[5] Database dump"

docker compose exec -T postgres pg_dump -U postgres postgres > "$OUT_DIR_META/db.sql" || true

echo "[6] Artifacts archive"

docker compose exec -T worker tar -czf - /app/data/artifacts > "$OUT_DIR_META/artifacts.tar.gz" 2>/dev/null || true

echo "[7] Create full archive bundle"

tar -czf "$OUT_FILE" -C "$SNAPSHOT_DIR" "$(basename "$OUT_DIR_META")" || true

echo "[8] Retention policy (keep last 5 full backups)"

cd "$SNAPSHOT_DIR"

ls -1t phase719_full_backup_*.tar.gz 2>/dev/null | tail -n +6 | while read -r oldfile; do

  echo "Deleting old backup: $oldfile"

  rm -f "$oldfile"

done

echo "[9] Manifest"

{

  echo "FULL SYSTEM BACKUP (ROLLING MODE - KEEP LAST 5)"

  echo "Timestamp: $TIMESTAMP"

  echo ""

  echo "Includes:"

  echo "- docker compose ps"

  echo "- git status + git log"

  echo "- api tasks snapshot"

  echo "- logs (worker + dashboard)"

  echo "- postgres dump"

  echo "- artifacts archive"

  echo "- full compressed bundle"

  echo ""

  echo "Retention policy: keep last 5 full backups"

  echo "Location: $SNAPSHOT_DIR"

} > "$OUT_DIR_META/MANIFEST.txt"

echo "$OUT_FILE"

echo "BACKUP COMPLETE (ROLLING MODE v2)"

