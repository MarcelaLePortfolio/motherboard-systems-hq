
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_ROOT="$ROOT_DIR/backups"

DRIVE_NAME="DRIVE"

EXTERNAL="/Volumes/$DRIVE_NAME"

STAGING="$BACKUP_ROOT/staging"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "RUNNING DR SYSTEM (EXTERNAL DRIVE ONLY)"

# -------------------------

# HARD REQUIREMENT: DRIVE MUST BE MOUNTED

# -------------------------

if [ ! -d "$EXTERNAL" ]; then

  echo "❌ CRITICAL: EXTERNAL DRIVE NOT MOUNTED"

  echo "ABORTING BACKUP"

  exit 1

fi

if ! mount | grep -q "$EXTERNAL"; then

  echo "❌ CRITICAL: INVALID MOUNT STATE"

  exit 1

fi

echo "✔ External drive verified: $EXTERNAL"

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

# RETENTION POLICY

# -------------------------

find "$EXTERNAL/backups" -type f -mtime +14 -delete || true

echo "✔ DR COMPLETE: $TIMESTAMP"

echo "✔ STORED ONLY ON EXTERNAL DRIVE"

