#!/bin/bash
set -u

echo "---- COMMIT ANY LOCAL SCRIPT ARTIFACTS ----"
git add PHASE703_SAFE_DISK_RECOVERY.sh PHASE703_SPACE_INSPECT_ONLY.sh PHASE703_SAFE_SPACE_RECOVERY_STEP2.sh 2>/dev/null || true
git commit -m "Phase 703: preserve safe disk recovery scripts" || true
git push

echo "---- DISK BEFORE ----"
df -h /

echo "---- REPO GIT CLEANUP (SAFE) ----"
git gc --prune=now

echo "---- SAFE DOCKER BUILD CACHE CLEANUP ----"
docker builder prune -af || true

echo "---- DISK AFTER CLEANUP ----"
df -h /

echo "---- REBUILD DASHBOARD ----"
docker compose up -d --build dashboard

echo "---- VALIDATE CHAT ----"
curl -i -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"test advisory"}' | head -n 40

echo "---- FINAL GIT STATE ----"
git status --short
