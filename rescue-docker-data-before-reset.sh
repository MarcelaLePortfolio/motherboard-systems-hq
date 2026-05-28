
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DOCKER_DATA_RESCUE_BEFORE_RESET.txt"

STAMP="$(date +%Y%m%d_%H%M%S)"

RESCUE_DIR="$HOME/Desktop/docker-rescue-$STAMP"

rm -f "$OUTPUT"

mkdir -p "$RESCUE_DIR"

echo "===== DOCKER DATA RESCUE BEFORE RESET =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== REMOVE EMPTY FAILED PG DUMP IF PRESENT =====" | tee -a "$OUTPUT"

if [ -f postgres_backup_before_docker_reset.sql ] && [ ! -s postgres_backup_before_docker_reset.sql ]; then

  rm -f postgres_backup_before_docker_reset.sql

  echo "Removed empty postgres_backup_before_docker_reset.sql" | tee -a "$OUTPUT"

fi

echo "" | tee -a "$OUTPUT"

echo "===== CONTAINER LIST =====" | tee -a "$OUTPUT"

docker container ls -a 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== CONTAINER MOUNT INSPECTION =====" | tee -a "$OUTPUT"

docker inspect motherboard_systems_hq-postgres-1 --format '{{json .Mounts}}' 2>&1 | tee -a "$OUTPUT" || true

docker inspect motherboard_systems_hq-dashboard-1 --format '{{json .Mounts}}' 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== ATTEMPT RAW POSTGRES DATA COPY =====" | tee -a "$OUTPUT"

docker cp motherboard_systems_hq-postgres-1:/var/lib/postgresql/data "$RESCUE_DIR/postgres-data" 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== ATTEMPT APP COPY =====" | tee -a "$OUTPUT"

docker cp motherboard_systems_hq-dashboard-1:/app "$RESCUE_DIR/dashboard-app" 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== RESCUE DIRECTORY CONTENTS =====" | tee -a "$OUTPUT"

du -sh "$RESCUE_DIR" 2>&1 | tee -a "$OUTPUT" || true

find "$RESCUE_DIR" -maxdepth 3 -type f | head -80 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== RESULT =====" | tee -a "$OUTPUT"

echo "Rescue directory: $RESCUE_DIR" | tee -a "$OUTPUT"

echo "If this directory is empty or copy failed with input/output error, Docker data is not recoverable through normal CLI." | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add rescue-docker-data-before-reset.sh DOCKER_DATA_RESCUE_BEFORE_RESET.txt

git commit -m "Attempt Docker data rescue before reset" || true

git push

