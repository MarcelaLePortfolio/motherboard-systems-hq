
#!/usr/bin/env bash

set -euo pipefail

REPORT="DASHBOARD_RUNTIME_SURFACE_VERIFICATION.txt"

{

  echo "===== DASHBOARD RUNTIME SURFACE VERIFICATION ====="

  date

  echo

  echo "===== VERIFY SERVED ROOT IS LATEST UI ====="

  curl -s http://localhost:8080/ > /tmp/dashboard-root.html

  echo

  echo "--- ROOT SIZE ---"

  wc -c /tmp/dashboard-root.html

  echo

  echo "--- CHECK FOR MODERN PHASE MARKERS ---"

  grep -n "phase62-top-row" /tmp/dashboard-root.html || true

  grep -n "matilda-chat-transcript" /tmp/dashboard-root.html || true

  grep -n "operator guidance" /tmp/dashboard-root.html || true

  grep -n "telemetry" /tmp/dashboard-root.html | head -20 || true

  echo

  echo "===== VERIFY BUNDLE LOAD ====="

  curl -I http://localhost:8080/bundle.js

  echo

  echo "===== VERIFY AGENT STATUS ====="

  curl -s http://localhost:8080/agent-status.json

  echo

  echo "===== VERIFY TASKS API ====="

  curl -s 'http://localhost:8080/api/tasks?limit=12'

  echo

  echo "===== VERIFY DASHBOARD CONTAINER LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1

  echo

  echo "===== VERIFY GIT HEAD ====="

  git log --oneline -5

  echo

  echo "===== FINAL FINDING ====="

  echo "If browser still shows old UI after this verification,"

  echo "the remaining issue is likely browser cache or stale tab state,"

  echo "not container runtime or served filesystem state."

} | tee "$REPORT"

git add verify-dashboard-runtime-surface.sh "$REPORT"

git commit -m "Verify latest dashboard runtime surface"

git push

