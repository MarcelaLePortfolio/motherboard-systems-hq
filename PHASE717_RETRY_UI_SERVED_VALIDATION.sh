
#!/bin/bash

set -euo pipefail

docker compose up -d --build dashboard

echo "Waiting for dashboard HTTP readiness..."

for i in {1..30}; do

  if curl -fsS http://localhost:3000/api/tasks >/tmp/phase717_ready_check.json 2>/dev/null; then

    break

  fi

  sleep 1

done

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js -o /tmp/phase717_visible_panels_bridge.js

grep -q "phase717RetryTask" /tmp/phase717_visible_panels_bridge.js

grep -q 'fetch("/api/delegate-task"' /tmp/phase717_visible_panels_bridge.js

grep -q 'kind: "retry"' /tmp/phase717_visible_panels_bridge.js

grep -q "retry_of_task_id" /tmp/phase717_visible_panels_bridge.js

grep -q "data-phase717-requeue" /tmp/phase717_visible_panels_bridge.js

grep -q "data-phase717-retry-differently" /tmp/phase717_visible_panels_bridge.js

echo "PASS: served retry UI wiring markers verified"

docker compose ps

git status --short

git log --oneline --decorate -5

