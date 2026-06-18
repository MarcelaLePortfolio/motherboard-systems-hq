
#!/usr/bin/env bash

set -euo pipefail

REPORT="dashboard-container-current-ui-rebuild-report.txt"

{

  echo "DASHBOARD CONTAINER CURRENT UI REBUILD REPORT"

  echo

  echo "--- current head ---"

  git log --oneline -5

  echo

  echo "--- rebuild dashboard service ---"

  docker compose build dashboard

  echo

  echo "--- restart dashboard service ---"

  docker compose up -d dashboard

  echo

  echo "--- wait and verify served dashboard ---"

  sleep 3

  curl -sS -D /tmp/dashboard-current-ui.headers -o /tmp/dashboard-current-ui.html http://localhost:8080/dashboard.html

  cat /tmp/dashboard-current-ui.headers

  echo

  echo "--- local vs served hashes ---"

  shasum -a 256 public/dashboard.html /tmp/dashboard-current-ui.html

  echo

  echo "--- served current UI anchors ---"

  grep -nE 'Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry|planning-preview-card' /tmp/dashboard-current-ui.html || true

  echo

  echo "--- byte equality ---"

  diff -q public/dashboard.html /tmp/dashboard-current-ui.html

} | tee "$REPORT"

cat > dashboard-container-current-ui-rebuild-finding.txt << 'NOTE'

DASHBOARD CONTAINER CURRENT UI REBUILD FINDING

Finding Status: VERIFIED BY SCRIPT

localhost:8080 is served by the Docker dashboard container.

Because Dockerfile.dashboard copies public/ into the image, dashboard HTML changes require rebuilding and restarting the dashboard service before browser validation.

NOTE

git add rebuild-dashboard-container-for-current-ui.sh dashboard-container-current-ui-rebuild-finding.txt "$REPORT"

git commit -m "Rebuild dashboard container for current UI" || true

git push

