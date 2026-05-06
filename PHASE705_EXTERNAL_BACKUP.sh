
#!/bin/bash

set -euo pipefail

PHASE="${1:-phase705-manual-backup}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

EXTERNAL_ROOT="/Volumes/Rio Drive/Motherboard_Storage"

BACKUP_ROOT="$EXTERNAL_ROOT/snapshots/$PHASE-$TIMESTAMP"

CHECKPOINT_FILE="checkpoints/${PHASE}_${TIMESTAMP}.md"

echo "MOTHERBOARD SAFE BACKUP — $PHASE — $TIMESTAMP"

echo ""

echo "[1] Verify external SSD"

if [ ! -d "/Volumes/Rio Drive" ]; then

  echo "ERROR: External SSD not mounted at /Volumes/Rio Drive"

  exit 1

fi

mkdir -p "$BACKUP_ROOT"

mkdir -p checkpoints

echo ""

echo "[2] Runtime/storage snapshot"

{

  echo "# Backup Checkpoint: $PHASE"

  echo ""

  echo "- Timestamp: $TIMESTAMP"

  echo "- Branch: $(git branch --show-current)"

  echo "- HEAD before commit: $(git rev-parse --short HEAD)"

  echo "- External backup path: $BACKUP_ROOT"

  echo ""

  echo "## Disk"

  df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive" || true

  echo ""

  echo "## Docker"

  docker system df || true

  echo ""

  echo "## Compose"

  docker compose ps || true

  echo ""

  echo "## Git status before checkpoint"

  git status --short || true

} > "$CHECKPOINT_FILE"

echo ""

echo "[3] Stage safe source/checkpoint files"

git add -A

echo ""

echo "[4] Block accidental heavy artifacts"

HEAVY_STAGED="$(git diff --cached --name-only | grep -E '\.(tar|tar.gz|tgz|zip|7z|raw)$' || true)"

if [ -n "$HEAVY_STAGED" ]; then

  echo "ERROR: Heavy archive artifacts are staged. Unstage/remove them before backup:"

  echo "$HEAVY_STAGED"

  exit 1

fi

echo ""

echo "[5] Commit lightweight checkpoint"

git commit -m "$PHASE: lightweight checkpoint" || true

HEAD_SHA="$(git rev-parse HEAD)"

HEAD_SHORT="$(git rev-parse --short HEAD)"

TAG_NAME="$PHASE-$TIMESTAMP"

echo ""

echo "[6] Tag and push"

git tag "$TAG_NAME" "$HEAD_SHA"

git push

git push origin "$TAG_NAME"

echo ""

echo "[7] Create external source archive from Git HEAD only"

git archive --format=tar.gz --output="$BACKUP_ROOT/source-$HEAD_SHORT.tar.gz" HEAD

echo ""

echo "[8] Write external manifest"

{

  echo "Backup: $PHASE"

  echo "Timestamp: $TIMESTAMP"

  echo "HEAD: $HEAD_SHA"

  echo "Tag: $TAG_NAME"

  echo "Archive: $BACKUP_ROOT/source-$HEAD_SHORT.tar.gz"

  echo ""

  echo "Disk:"

  df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive" || true

  echo ""

  echo "Docker:"

  docker system df || true

  echo ""

  echo "Compose:"

  docker compose ps || true

  echo ""

  echo "Archive size:"

  ls -lh "$BACKUP_ROOT/source-$HEAD_SHORT.tar.gz"

} > "$BACKUP_ROOT/manifest.txt"

echo ""

echo "[9] Verify backup"

ls -lh "$BACKUP_ROOT"

cat "$BACKUP_ROOT/manifest.txt"

echo ""

echo "DONE — backup created externally at:"

echo "$BACKUP_ROOT"

