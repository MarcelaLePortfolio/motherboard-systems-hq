
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

STAGING_DIR="$BACKUP_ROOT/_staging"

mkdir -p "$BACKUP_ROOT"

rm -rf "$STAGING_DIR"

mkdir -p "$STAGING_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "CREATING LOCAL BACKUP: $TIMESTAMP"

# 1. Git bundle (repo state)

git bundle create "$BACKUP_ROOT/repo_$TIMESTAMP.bundle" --all

# 2. Stage clean snapshot (prevents recursion entirely)

rsync -a \

  --exclude "backups" \

  --exclude ".git" \

  "$ROOT_DIR/" "$STAGING_DIR/"

# 3. Archive ONLY staging (safe, no self-reference possible)

tar -czf "$BACKUP_ROOT/source_$TIMESTAMP.tar.gz" -C "$STAGING_DIR" .

rm -rf "$STAGING_DIR"

# 4. Optional DB dump

if command -v pg_dump >/dev/null 2>&1 && [ -n "${DATABASE_URL:-}" ]; then

  pg_dump "$DATABASE_URL" > "$BACKUP_ROOT/db_$TIMESTAMP.sql" || true

fi

# 5. Retention

find "$BACKUP_ROOT" -type f -mtime +14 -delete || true

echo "BACKUP COMPLETE: $TIMESTAMP"

