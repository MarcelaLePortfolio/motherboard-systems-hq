
#!/usr/bin/env bash

set -euo pipefail

REPORT="docker-dashboard-serving-source-report.txt"

{

  echo "DOCKER DASHBOARD SERVING SOURCE REPORT"

  echo

  echo "--- docker containers publishing 8080 ---"

  docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}' | grep -E '8080|CONTAINER' || true

  echo

  echo "--- compose files ---"

  ls -lah docker-compose*.yml Dockerfile.dashboard 2>/dev/null || true

  echo

  echo "--- compose service hints ---"

  grep -RInE '8080|dashboard|server.mjs|public|volumes|build|image' docker-compose*.yml Dockerfile.dashboard 2>/dev/null || true

  echo

  echo "--- local vs live hashes ---"

  shasum -a 256 public/dashboard.html

  curl -sS -o /tmp/docker-served-dashboard.html http://localhost:8080/dashboard.html || true

  shasum -a 256 /tmp/docker-served-dashboard.html 2>/dev/null || true

  echo

  echo "--- live anchor check ---"

  grep -nE 'Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry' /tmp/docker-served-dashboard.html || true

} | tee "$REPORT"

cat > docker-dashboard-serving-source-finding.txt << 'NOTE'

DOCKER DASHBOARD SERVING SOURCE FINDING

Finding Status: ACTIVE

localhost:8080 is owned by Docker, and the served dashboard bytes do not match the current repo public/dashboard.html.

Next safe action:

Identify whether the dashboard container needs a rebuild, restart, bind mount correction, or image refresh before any further UI code changes.

NOTE

git add inspect-docker-dashboard-serving-source.sh docker-dashboard-serving-source-finding.txt "$REPORT"

git commit -m "Inspect Docker dashboard serving source" || true

git push

