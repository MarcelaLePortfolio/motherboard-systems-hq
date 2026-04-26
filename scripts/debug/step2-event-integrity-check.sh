#!/bin/bash

echo "STEP 2 — EVENT STREAM INTEGRITY CHECK"
echo "===================================="

echo ""
echo "1. Trigger a fresh task from UI now."
echo "   (Create any simple task — we are observing lifecycle)"

echo ""
read -p "Press ENTER after task has completed..."

echo ""
echo "2. Checking recent task_events from database..."

docker exec -it $(docker ps --format '{{.Names}}' | grep -i postgres | head -n 1) psql -U postgres -d postgres -c "
SELECT 
  event_type,
  task_id,
  run_id,
  attempts,
  created_at
FROM task_events
ORDER BY created_at DESC
LIMIT 20;
"

echo ""
echo "3. Manual verification required:"
echo "- Ensure SAME task_id appears across:"
echo "  • task.created"
echo "  • task.running"
echo "  • task.completed"
echo ""
echo "- Ensure run_id is consistent"
echo "- Ensure attempts field is consistent"

echo ""
echo "RESULT:"
echo "If all match → STEP 2 PASSED"
echo "If mismatch → STOP and report immediately"
