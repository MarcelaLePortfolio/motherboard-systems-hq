
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

STAGING="$BACKUP_ROOT/staging"

mkdir -p "$BACKUP_ROOT"

rm -rf "$STAGING"

mkdir -p "$STAGING"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "CREATING STABLE BACKUP: $TIMESTAMP"

# git snapshot (immutable source layer)

git bundle create "$BACKUP_ROOT/repo_$TIMESTAMP.bundle" --all

# FIX: atomic rsync (NO multiline parsing risk)

rsync -a --exclude=backups --exclude=.git "$ROOT_DIR/" "$STAGING/"

# compress staging

tar -czf "$BACKUP_ROOT/source_$TIMESTAMP.tar.gz" -C "$STAGING" .

rm -rf "$STAGING"

# retention

find "$BACKUP_ROOT" -type f -mtime +14 -delete || true

echo "BACKUP COMPLETE: $TIMESTAMP"

