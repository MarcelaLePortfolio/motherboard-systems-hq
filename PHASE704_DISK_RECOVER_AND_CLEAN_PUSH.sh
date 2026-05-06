#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Disk recover + clean push without tar snapshots"
echo "────────────────────────────────"

PHASE_TAG="phase704-final-authoritative-containerized"
SNAPSHOT_DIR="snapshots/phase704-final-authoritative-containerized"
RESCUE_DIR="/tmp/phase704_rescue_small_files"

echo ""
echo "1) Disk state before cleanup..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "2) Removing duplicate/rescued tar snapshots that filled disk..."
rm -rf "$RESCUE_DIR/local_tar_snapshots" || true
rm -f "$SNAPSHOT_DIR"/*.tar || true

echo ""
echo "3) Removing stale git lock from failed reset..."
rm -f .git/index.lock

echo ""
echo "4) Disk state after tar cleanup..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "5) Rescuing small files only again..."
rm -rf "$RESCUE_DIR"
mkdir -p "$RESCUE_DIR/$SNAPSHOT_DIR"

for f in \
  PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md \
  PHASE704_FINAL_SEAL_TAG_CONTAINER_SNAPSHOT.sh \
  PHASE704_DISK_RECOVER_AND_CLEAN_PUSH.sh \
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
echo "6) Resetting branch to clean remote history..."
git fetch origin dev
git reset --hard origin/dev

echo ""
echo "7) Restoring small seal/snapshot files only..."
cp -R "$RESCUE_DIR"/. .

echo ""
echo "8) Ensuring tar snapshots are ignored and absent..."
touch .gitignore
grep -qxF "*.tar" .gitignore || echo "*.tar" >> .gitignore
grep -qxF "snapshots/**/*.tar" .gitignore || echo "snapshots/**/*.tar" >> .gitignore
rm -f "$SNAPSHOT_DIR"/*.tar || true

echo ""
echo "9) Git status before clean commit..."
git status --short

echo ""
echo "10) Commit repaired final seal without tar payloads..."
git add \
  .gitignore \
  PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md \
  PHASE704_FINAL_SEAL_TAG_CONTAINER_SNAPSHOT.sh \
  PHASE704_DISK_RECOVER_AND_CLEAN_PUSH.sh \
  "$SNAPSHOT_DIR/MANIFEST.md" \
  "$SNAPSHOT_DIR/PHASE704_FINAL_AUTHORITATIVE_CONTAINERIZED_SEAL.md" \
  "$SNAPSHOT_DIR/api_chat.json" \
  "$SNAPSHOT_DIR/api_guidance.json" \
  "$SNAPSHOT_DIR/api_tasks.json" \
  "$SNAPSHOT_DIR/docker_compose_ps.txt" \
  "$SNAPSHOT_DIR/docker_info.txt" \
  "$SNAPSHOT_DIR/docker_ps.txt" \
  "$SNAPSHOT_DIR/task_events_sse.txt"

git commit -m "Phase 704: final authoritative seal without Docker image tars"

echo ""
echo "11) Repointing tag to clean commit..."
git tag -f "$PHASE_TAG"

echo ""
echo "12) Pushing clean commit and tag..."
git push
git push -f origin "$PHASE_TAG"

echo ""
echo "13) Final verification..."
git status --short
git log --oneline -6
git tag --list "$PHASE_TAG"
df -h /

echo ""
echo "Phase 704 clean push complete. Docker image tar files were removed to protect disk and Git transport."
