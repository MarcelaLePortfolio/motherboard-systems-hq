#!/bin/bash
set -u

echo "---- DISK NOW ----"
df -h /

echo "---- LARGE USER-LEVEL TARGETS ----"
du -sh "$HOME"/Library/Caches 2>/dev/null || true
du -sh "$HOME"/.Trash 2>/dev/null || true
du -sh "$HOME"/Downloads 2>/dev/null || true
du -sh "$HOME"/Desktop 2>/dev/null || true
du -sh "$HOME"/Library/Developer/Xcode 2>/dev/null || true
du -sh "$HOME"/Library/Containers/com.docker.docker 2>/dev/null || true

echo "---- TOP 25 HOME ITEMS ----"
du -xh "$HOME" 2>/dev/null | sort -h | tail -n 25

echo "---- GIT STATE ----"
git status --short

git add PHASE703_SPACE_INSPECT_ONLY.sh
git commit -m "Phase 703: add disk space inspection script" || true
git push
