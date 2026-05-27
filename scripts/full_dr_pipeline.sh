
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

EXTERNAL="/Volumes/DRIVE"

STAGING="$BACKUP_ROOT/staging"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "RUNNING DR SYSTEM (EXTERNAL DRIVE ONLY)"

# -------------------------

# HARD REQUIREMENT: EXTERNAL DRIVE MUST EXIST

# -------------------------

if [ ! -d "$EXTERNAL" ]; then

  echo "❌ CRITICAL: EXTERNAL DRIVE NOT MOUNTED"

  echo "ABORTING - NO BACKUP CREATED"

  exit 1

fi

echo "✔ External drive detected: $EXTERNAL"

# -------------------------

# PREP

# -------------------------

rm -rf "$STAGING"

mkdir -p "$STAGING"

mkdir -p "$EXTERNAL/backups"

# -------------------------

# GIT SNAPSHOT (SOURCE OF TRUTH)

# -------------------------

git bundle create "$EXTERNAL/backups/repo_$TIMESTAMP.bundle" --all

# -------------------------

# FILE SNAPSHOT

# -------------------------

rsync -a \

  --exclude="backups" \

  --exclude=".git" \

  "$ROOT_DIR/" "$STAGING/"

# -------------------------

# COMPRESS SNAPSHOT

# -------------------------

tar -czf "$EXTERNAL/backups/source_$TIMESTAMP.tar.gz" -C "$STAGING" .

rm -rf "$STAGING"

# -------------------------

# RETENTION (14 DAYS)

# -------------------------

find "$EXTERNAL/backups" -type f -mtime +14 -delete || true

echo "✔ DR COMPLETE: $TIMESTAMP"

echo "✔ ALL BACKUPS STORED ON EXTERNAL DRIVE"

