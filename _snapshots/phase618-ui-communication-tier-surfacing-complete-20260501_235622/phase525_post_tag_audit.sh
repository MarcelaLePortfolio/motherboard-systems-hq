#!/usr/bin/env bash
set -euo pipefail

echo "[1] Verify current commit"
git log --oneline -1

echo
echo "[2] Verify tag exists locally"
git tag --list | grep phase-525-completion-pipeline-verified

echo
echo "[3] Verify tag exists on remote"
git ls-remote --tags origin | grep phase-525-completion-pipeline-verified

echo
echo "[4] Verify containers running"
docker compose ps

echo
echo "[5] Verify API health"
curl -sS 'http://localhost:8080/api/health'
echo

echo "[6] Verify task completion state"
curl -sS 'http://localhost:8080/api/tasks?limit=3' | jq

echo
echo "[7] Verify recent task events"
docker exec -i motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c \
  "select kind, task_id, actor, created_at from task_events order by created_at desc limit 10;"

echo
echo "=== POST-TAG AUDIT COMPLETE ==="
echo "Everything should read: CLEAN / CONSISTENT / VERIFIED"
