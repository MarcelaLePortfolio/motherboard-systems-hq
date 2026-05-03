#!/bin/bash
set -euo pipefail

echo "=== PHASE488: TRACE TASK EVENT PRODUCERS (BACKEND + FRONTEND) ==="

echo
echo "=== 1. FIND ALL EVENT ENDPOINTS ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "app.get\\|router.get\\|/events" .

echo
echo "=== 2. FIND TASK EVENT EMITTERS ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "task.created\\|task.updated\\|task.completed\\|task.failed\\|emit(" .

echo
echo "=== 3. FIND SSE HEARTBEAT SOURCES ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "heartbeat\\|setInterval\\|setTimeout" .

echo
echo "=== 4. FIND SERVER-SIDE EVENTSTREAM HANDLERS ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "text/event-stream\\|res.write\\|flush\\|cursor" .

echo
echo "=== 5. CHECK FOR MULTIPLE TASK EVENT STREAMS ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git "/events/task\\|task-events\\|task/event" .

echo
echo "=== 6. SUMMARY COMPLETE ==="
