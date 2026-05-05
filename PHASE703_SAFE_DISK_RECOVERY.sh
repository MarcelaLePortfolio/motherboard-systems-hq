#!/bin/bash
set -u

echo "PHASE703 safe disk recovery starting"

echo "---- DISK BEFORE ----"
df -h /

echo "---- STOP DASHBOARD ONLY ----"
docker compose stop dashboard || true

echo "---- SAFE DOCKER BUILD CACHE PRUNE ----"
docker builder prune -f || true

echo "---- SAFE USER CACHE CLEANUP ----"
rm -rf "$HOME/.npm/_cacache" 2>/dev/null || true
rm -rf "$HOME/Library/Caches/pnpm" 2>/dev/null || true
rm -rf "$HOME/Library/Caches/Homebrew" 2>/dev/null || true

echo "---- DISK AFTER CLEANUP ----"
df -h /

echo "---- REBUILD DASHBOARD ----"
docker compose up -d --build dashboard

echo "---- RUNTIME STATUS ----"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "---- CHAT VALIDATION ----"
curl -i -s -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"test advisory"}' | head -n 40

echo "---- GIT STATE ----"
git status --short

git add PHASE703_SAFE_DISK_RECOVERY.sh
git commit -m "Phase 703: add safe disk recovery script for dashboard rebuild" || true
git push
