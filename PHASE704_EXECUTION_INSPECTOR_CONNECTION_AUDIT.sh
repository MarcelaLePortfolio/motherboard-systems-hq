#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Execution Inspector connection audit"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Container state..."
docker compose ps
docker ps

echo ""
echo "3) Search for Execution Inspector files/routes..."
grep -RIn \
  "Execution Inspector\|ExecutionInspector\|execution inspector\|inspector\|task_events\|/events/tasks\|/api/tasks\|run_view" \
  app server public src components pages 2>/dev/null || true

echo ""
echo "4) Probe likely task/execution endpoints..."
for url in \
  "http://localhost:3000/api/health" \
  "http://localhost:3000/api/tasks" \
  "http://localhost:3000/api/tasks/recent" \
  "http://localhost:3000/api/task-events" \
  "http://localhost:3000/api/runs" \
  "http://localhost:3000/api/guidance" \
  "http://localhost:3000/events/tasks"
do
  echo ""
  echo "---- $url ----"
  timeout 5 curl -i -sS "$url" | sed -n '1,80p' || true
done

echo ""
echo "5) Dashboard logs recent..."
docker compose logs --tail=120 dashboard || true

echo ""
echo "6) Worker logs recent..."
docker compose logs --tail=120 worker || true

echo ""
echo "7) Postgres table inventory..."
docker compose exec -T postgres psql -U postgres -d postgres -c "\dt" || true

echo ""
echo "8) Task/runtime table samples..."
docker compose exec -T postgres psql -U postgres -d postgres -c "select id, task_id, status, kind, created_at, updated_at from tasks order by id desc limit 10;" || true
docker compose exec -T postgres psql -U postgres -d postgres -c "select * from task_events order by id desc limit 10;" || true
docker compose exec -T postgres psql -U postgres -d postgres -c "select * from run_view limit 10;" || true

echo ""
echo "Execution Inspector audit complete."
