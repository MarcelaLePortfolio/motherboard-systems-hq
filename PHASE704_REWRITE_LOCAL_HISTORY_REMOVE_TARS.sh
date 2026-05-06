#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Rewrite local history to remove oversized tar blobs"
echo "────────────────────────────────"

PHASE_TAG="phase704-final-authoritative-containerized"
SNAPSHOT_DIR="snapshots/phase704-final-authoritative-containerized"
RESCUE_DIR="/tmp/phase704_rescue_small_files"

echo ""
echo "1) Current state before rewrite..."
git status --short
git log --oneline -8
mkdir -p "$RESCUE_DIR/$SNAPSHOT_DIR"

echo ""
echo "2) Rescuing small files only..."
for f in \
  PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md \
  PHASE704_FINAL_SEAL_TAG_CONTAINER_SNAPSHOT.sh \
  PHASE704_REWRITE_LOCAL_HISTORY_REMOVE_TARS.sh \
  "$SNAPSHOT_DIR/MANIFEST.md" \
  "$SNAPSHOT_DIR/PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md" \
  "$SNAPSHOT_DIR/api_chat.json" \
  "$SNAPSHOT_DIR/api_guidance.json" \
  "$SNAPSHOT_DIR/api_tasks.json" \
  "$SNAPSHOT_DIR/docker_compose_ps.txt" \
  "$SNAPSHOT_DIR/docker_info.txt" \
  "$SNAPSHOT_DIR/docker_ps.txt" \
  "$SNAPSHOT_DIR/task_events_sse.txt"
do
  if [ -f "$f" ]; then
    mkdir -p "$RESCUE_DIR/$(dirname "$f")"
    cp "$f" "$RESCUE_DIR/$f"
  fi
done

echo ""
echo "3) Rescuing local tar snapshots outside Git..."
mkdir -p "$RESCUE_DIR/local_tar_snapshots"
cp "$SNAPSHOT_DIR"/*.tar "$RESCUE_DIR/local_tar_snapshots/" 2>/dev/null || true
ls -lh "$RESCUE_DIR/local_tar_snapshots" 2>/dev/null || true

echo ""
echo "4) Resetting local branch to clean remote history..."
git fetch origin dev
git reset --hard origin/dev

echo ""
echo "5) Restoring small files only..."
cp -R "$RESCUE_DIR"/. .

echo ""
echo "6) Restoring tar snapshots as local ignored files..."
mkdir -p "$SNAPSHOT_DIR"
cp "$RESCUE_DIR/local_tar_snapshots"/*.tar "$SNAPSHOT_DIR/" 2>/dev/null || true

echo ""
echo "7) Ensuring tar snapshots are ignored..."
touch .gitignore
grep -qxF "*.tar" .gitignore || echo "*.tar" >> .gitignore
grep -qxF "snapshots/**/*.tar" .gitignore || echo "snapshots/**/*.tar" >> .gitignore

echo ""
echo "8) Verifying tar files are local only..."
ls -lh "$SNAPSHOT_DIR"/*.tar 2>/dev/null || true
git status --short

echo ""
echo "9) Committing repaired final seal without tar blobs..."
git add \
  .gitignore \
  PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md \
  PHASE704_FINAL_SEAL_TAG_CONTAINER_SNAPSHOT.sh \
  PHASE704_REWRITE_LOCAL_HISTORY_REMOVE_TARS.sh \
  "$SNAPSHOT_DIR/MANIFEST.md" \
  "$SNAPSHOT_DIR/PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md" \
  "$SNAPSHOT_DIR/api_chat.json" \
  "$SNAPSHOT_DIR/api_guidance.json" \
  "$SNAPSHOT_DIR/api_tasks.json" \
  "$SNAPSHOT_DIR/docker_compose_ps.txt" \
  "$SNAPSHOT_DIR/docker_info.txt" \
  "$SNAPSHOT_DIR/docker_ps.txt" \
  "$SNAPSHOT_DIR/task_events_sse.txt"

git commit -m "Phase 704: final authoritative containerized seal without image tars"

echo ""
echo "10) Repointing tag to clean commit..."
git tag -f "$PHASE_TAG"

echo ""
echo "11) Pushing clean commit and tag..."
git push
git push -f origin "$PHASE_TAG"

echo ""
echo "12) Final verification..."
git status --short
git log --oneline -6
git tag --list "$PHASE_TAG"

echo ""
echo "Phase 704 clean push repaired. Local Docker image tar snapshots remain ignored in $SNAPSHOT_DIR."
