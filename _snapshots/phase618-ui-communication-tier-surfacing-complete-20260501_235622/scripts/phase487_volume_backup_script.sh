#!/bin/bash

set -euo pipefail

VOLUME_NAME="motherboard_systems_hq_pgdata"
BACKUP_ROOT="${HOME}/Desktop/Motherboard_Systems_HQ_Backups/postgres_volume"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}.tar.gz"
MANIFEST_FILE="${BACKUP_DIR}/backup_manifest.txt"

mkdir -p "$BACKUP_DIR"

echo "PHASE 487 — PROTECTED VOLUME BACKUP"
echo "Target volume: ${VOLUME_NAME}"
echo "Backup dir: ${BACKUP_DIR}"
echo ""

docker volume inspect "$VOLUME_NAME" >/dev/null

cat > "$MANIFEST_FILE" <<MANIFEST
phase=487
type=postgres_volume_backup
volume_name=${VOLUME_NAME}
created_at=$(date)
host=$(hostname)
backup_file=${BACKUP_FILE}
MANIFEST

docker run --rm \
  -v "${VOLUME_NAME}:/source:ro" \
  -v "${BACKUP_DIR}:/backup" \
  alpine:3.22 \
  sh -lc 'cd /source && tar -czf /backup/'"${VOLUME_NAME}"'.tar.gz .'

echo ""
echo "Backup created:"
echo "  ${BACKUP_FILE}"
echo "Manifest created:"
echo "  ${MANIFEST_FILE}"
echo ""

ls -lh "$BACKUP_FILE" "$MANIFEST_FILE"
