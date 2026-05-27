
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

STAGING_DIR="$BACKUP_ROOT/_staging"

INDEX_FILE="$BACKUP_ROOT/backup_index.json"

mkdir -p "$BACKUP_ROOT"

rm -rf "$STAGING_DIR"

mkdir -p "$STAGING_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "CREATING BACKUP: $TIMESTAMP"

git bundle create "$BACKUP_ROOT/repo_$TIMESTAMP.bundle" --all

rsync -a --exclude="backups" --exclude=".git" --exclude="_staging" "$ROOT_DIR/" "$STAGING_DIR/"

tar -czf "$BACKUP_ROOT/source_$TIMESTAMP.tar.gz" -C "$STAGING_DIR" .

rm -rf "$STAGING_DIR"

if command -v pg_dump >/dev/null 2>&1 && [ -n "${DATABASE_URL:-}" ]; then

  pg_dump "$DATABASE_URL" > "$BACKUP_ROOT/db_$TIMESTAMP.sql" || true

fi

sha256sum "$BACKUP_ROOT/repo_$TIMESTAMP.bundle" "$BACKUP_ROOT/source_$TIMESTAMP.tar.gz" > "$BACKUP_ROOT/checksums_$TIMESTAMP.txt"

echo "{\"timestamp\":\"$TIMESTAMP\",\"bundle\":\"repo_$TIMESTAMP.bundle\",\"archive\":\"source_$TIMESTAMP.tar.gz\"}" >> "$INDEX_FILE"

find "$BACKUP_ROOT" -type f -mtime +14 -delete || true

echo "BACKUP COMPLETE: $TIMESTAMP"

