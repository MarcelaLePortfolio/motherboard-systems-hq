#!/usr/bin/env bash

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUT_DIR="backups"
OUT_FILE="$OUT_DIR/postgres_backup_$TIMESTAMP.sql"

echo "== ensuring backup directory exists =="
mkdir -p "$OUT_DIR"

echo "== running pg_dump from container =="
docker compose exec -T postgres pg_dump -U postgres > "$OUT_FILE"

echo "== backup complete =="
echo "File: $OUT_FILE"

echo
echo "IMPORTANT:"
echo "- move this file to a cloud location (Google Drive, iCloud, etc.)"
echo "- this file is your off-device recovery anchor"
