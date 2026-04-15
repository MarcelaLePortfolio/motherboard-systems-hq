#!/usr/bin/env bash
set -euo pipefail

echo "=== REBUILD / REFRESH ==="
docker compose up -d --build >/dev/null
open "http://localhost:8080/?v=$(date +%s)"
sleep 3
echo

echo "=== LATEST PHASE490 HEIGHT EVIDENCE FROM DASHBOARD LOGS ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 200 | sed -n '/\[phase490\] height evidence/,$p' | tail -n 160 || true
echo

echo "=== CURRENT UI COMMITS ==="
git log --oneline -n 8
