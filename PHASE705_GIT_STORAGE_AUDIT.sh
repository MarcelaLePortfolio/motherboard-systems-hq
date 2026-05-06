
#!/bin/bash

set -euo pipefail

echo "PHASE 705 — GIT STORAGE AUDIT"

echo ""

echo "[1] Repo size overview"

du -sh .git

du -sh .git/objects

echo ""

echo "[2] Largest Git packfiles"

find .git/objects/pack -type f | xargs ls -lh | sort -k5 -hr | head -20

echo ""

echo "[3] Git count-objects"

git count-objects -vH

echo ""

echo "[4] Recent heavyweight snapshot references"

git log --all --stat -- '*.tar.gz' '*.tar' | head -120 || true

echo ""

echo "[5] Current runtime safety"

docker compose ps || true

echo ""

echo "[6] Disk"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

echo ""

echo "DONE"

