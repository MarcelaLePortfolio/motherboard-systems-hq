
#!/bin/bash

set -euo pipefail

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

COMMIT="$(git rev-parse --short HEAD)"

BACKUP_ROOT="${HOME}/RioDrive/Motherboard_Systems_Backups"

BACKUP_DIR="${BACKUP_ROOT}/phase726-final-${TIMESTAMP}-${COMMIT}"

mkdir -p "${BACKUP_DIR}"

echo "Creating Phase 726 final backup checkpoint..."

echo "Commit: ${COMMIT}"

echo "Destination: ${BACKUP_DIR}"

rsync -a --exclude='node_modules' --exclude='.git/objects' --exclude='.next' --exclude='dist' --exclude='coverage' ./ "${BACKUP_DIR}/"

git rev-parse HEAD > "${BACKUP_DIR}/FULL_COMMIT_SHA.txt"

git status --short > "${BACKUP_DIR}/GIT_STATUS.txt"

git status > "${BACKUP_DIR}/GIT_STATUS_FULL.txt"

git log --oneline -25 > "${BACKUP_DIR}/GIT_LOG.txt"

docker compose ps > "${BACKUP_DIR}/DOCKER_COMPOSE_PS.txt" || true

echo "Backup complete."

