
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 EXTERNAL ARCHIVE BACKUP ====="

REPO_ROOT="$(pwd)"

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"

SHORT_SHA="$(git rev-parse --short HEAD)"

BACKUP_NAME="motherboard_systems_hq_phase719_${SHORT_SHA}_${TIMESTAMP}"

PRIMARY_ARCHIVE_DIR="/Volumes/RioDrive/MOTHERBOARD_SYSTEMS_ARCHIVES"

FALLBACK_ARCHIVE_DIR="$HOME/Desktop/MOTHERBOARD_SYSTEMS_ARCHIVES"

if [ -d "/Volumes/RioDrive" ]; then

  ARCHIVE_DIR="$PRIMARY_ARCHIVE_DIR"

else

  ARCHIVE_DIR="$FALLBACK_ARCHIVE_DIR"

fi

mkdir -p "$ARCHIVE_DIR"

echo ""

echo "[1] Repo status"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Runtime status"

docker compose ps

echo ""

echo "[3] Create compressed source archive"

tar \

  --exclude='node_modules' \

  --exclude='.next' \

  --exclude='.git' \

  --exclude='dist' \

  --exclude='coverage' \

  --exclude='tmp' \

  --exclude='*.log' \

  -czf "$ARCHIVE_DIR/${BACKUP_NAME}.tar.gz" \

  .

echo ""

echo "[4] Generate manifest"

cat > "$ARCHIVE_DIR/${BACKUP_NAME}_MANIFEST.txt" << MANIFEST

Backup: ${BACKUP_NAME}

Created: $(date)

Repo: ${REPO_ROOT}

Commit: $(git rev-parse HEAD)

Recent commits:

$(git log --oneline -5)

Docker status:

$(docker compose ps)

Artifact persistence status:

- Real worker artifact persistence verified

- Artifact metadata exposed through /api/tasks

- Artifact file existence validated inside worker container

- Worker runtime stabilized after duplicate import repair

- Verification commit: d90d6bdf

Known remaining corridor:

- Add read-only artifact inspection endpoint

- Add dashboard artifact preview surface

MANIFEST

echo ""

echo "[5] Verify archive"

ls -lh "$ARCHIVE_DIR/${BACKUP_NAME}.tar.gz"

ls -lh "$ARCHIVE_DIR/${BACKUP_NAME}_MANIFEST.txt"

echo ""

echo "Archive location:"

echo "$ARCHIVE_DIR/${BACKUP_NAME}.tar.gz"

echo ""

echo "===== PHASE 719 EXTERNAL ARCHIVE BACKUP COMPLETE ====="

