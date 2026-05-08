
#!/bin/bash

set -euo pipefail

BACKUP_NAME="phase715-pre-execution-evidence-ui"

STAMP="$(date +%Y%m%d_%H%M%S)"

SNAPSHOT_ROOT="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

SNAPSHOT_DIR="${SNAPSHOT_ROOT}/${BACKUP_NAME}_${STAMP}"

HEAD_SHORT="$(git rev-parse --short HEAD)"

test -d "/Volumes/Rio Drive" || {

  echo "ERROR: Rio Drive not mounted"

  exit 1

}

mkdir -p "${SNAPSHOT_DIR}"

git status > "${SNAPSHOT_DIR}/git-status.txt"

git log --oneline -n 25 > "${SNAPSHOT_DIR}/git-log.txt"

git tag --points-at HEAD > "${SNAPSHOT_DIR}/head-tags.txt" || true

docker ps > "${SNAPSHOT_DIR}/docker-ps.txt" || true

docker compose ps > "${SNAPSHOT_DIR}/docker-compose-ps.txt" || true

curl -sS http://localhost:3000/api/chat/context > "${SNAPSHOT_DIR}/api-chat-context.json" || true

curl -sS http://localhost:3000/api/tasks > "${SNAPSHOT_DIR}/api-tasks.json" || true

curl -sS http://localhost:3000/api/guidance > "${SNAPSHOT_DIR}/api-guidance.json" || true

curl -sS http://localhost:3000/events/task-events --max-time 5 > "${SNAPSHOT_DIR}/task-events-sse.txt" || true

git archive --format=tar.gz --output="${SNAPSHOT_DIR}/source-${HEAD_SHORT}.tar.gz" HEAD

cat > "${SNAPSHOT_DIR}/manifest.txt" << MANIFEST

Backup: ${BACKUP_NAME}

Timestamp: ${STAMP}

HEAD: $(git rev-parse HEAD)

HEAD short: ${HEAD_SHORT}

Archive: ${SNAPSHOT_DIR}/source-${HEAD_SHORT}.tar.gz

Backup type: old external archive pattern

GitHub push status: intentionally skipped because current local history attempts to push a 3.48 GiB pack

MANIFEST

echo "External archive backup complete:"

echo "${SNAPSHOT_DIR}"

ls -lh "${SNAPSHOT_DIR}"

du -sh "${SNAPSHOT_DIR}"

open "${SNAPSHOT_DIR}"

