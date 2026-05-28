
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DASHBOARD_UI_SURFACE_RESTORE.txt"

rm -f "$OUTPUT"

{

  echo "===== DASHBOARD UI SURFACE RESTORE ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== SEARCH FOR UI DATA SOURCES ====="

  grep -RniE 'agent-status|Loading agents|tasks-widget|metric-agents|metric-tasks|EventSource|/events/task-events|/api/tasks' public server 2>/dev/null | head -250

  echo

  echo "===== BUNDLE REFERENCES ====="

  grep -RniE 'agent-status|tasks-widget|metric-agents|metric-tasks|health-status|EventSource' public/bundle.js public/js 2>/dev/null | head -250

  echo

  echo "===== CHECK FOR MISSING ROUTES ====="

  (

    curl -i --max-time 2 http://localhost:8080/agent-status.json || true

    echo

    curl -i --max-time 2 http://localhost:8080/api/agent-status || true

    echo

    curl -i --max-time 2 http://localhost:8080/api/agents || true

  )

  echo

  echo "===== TASK_EVENTS LIVE SAMPLE ====="

  curl -s --max-time 2 http://localhost:8080/events/task-events || true

  echo

  echo "===== ARTIFACTS LIVE SAMPLE ====="

  curl -s --max-time 2 http://localhost:8080/events/artifacts || true

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 200 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== WORKTREE ====="

  git status --short

  echo

  echo "Diagnosis complete."

} | tee "$OUTPUT"

git add restore-dashboard-ui-surface.sh DASHBOARD_UI_SURFACE_RESTORE.txt

git commit -m "Inspect dashboard UI surface restoration" || true

git push

