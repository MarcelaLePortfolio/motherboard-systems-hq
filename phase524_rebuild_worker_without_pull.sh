#!/usr/bin/env bash
set -euo pipefail

docker compose build --pull=false dashboard
docker compose up -d --force-recreate worker

sleep 8

docker exec -i motherboard_systems_hq-worker-1 grep -n "stableTaskId\|markSuccess(c" /app/server/worker/phase26_task_worker.mjs

echo
docker logs --tail 120 motherboard_systems_hq-worker-1

echo
curl -sS 'http://localhost:8080/api/tasks?limit=1' | jq

git add phase524_rebuild_worker_without_pull.sh
git commit -m "Phase 524: add no-pull worker rebuild verification script"
git push
