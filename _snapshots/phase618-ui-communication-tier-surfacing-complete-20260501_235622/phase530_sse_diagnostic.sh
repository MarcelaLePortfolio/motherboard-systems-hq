#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 530 SSE DIAGNOSTIC"
echo "────────────────────────"

echo ""
echo "1. Locating SSE route definitions..."
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build "/events/tasks\|text/event-stream\|EventSource" . || true

echo ""
echo "2. Checking running container health..."
docker compose ps || true

echo ""
echo "3. Checking SSE response headers..."
curl -i -N --max-time 5 http://localhost:8080/events/tasks 2>/dev/null | head -n 40 || true

echo ""
echo "4. Checking recent task events..."
docker compose exec -T postgres psql -U postgres -d postgres -c "SELECT id, task_id, run_id, event_type, created_at FROM task_events ORDER BY id DESC LIMIT 10;" || true

echo ""
echo "5. Diagnostic complete."
