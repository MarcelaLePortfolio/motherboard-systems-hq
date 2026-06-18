
#!/usr/bin/env bash

set -euo pipefail

REPORT="localhost-8080-serving-source-report.txt"

{

  echo "LOCALHOST 8080 SERVING SOURCE REPORT"

  echo

  echo "--- current repo ---"

  pwd

  git log --oneline -5

  echo

  echo "--- port 8080 listener ---"

  lsof -nP -iTCP:8080 -sTCP:LISTEN || true

  echo

  echo "--- matching node/python/serve processes ---"

  ps aux | grep -E 'node|serve|python|8080|server.mjs' | grep -v grep || true

  echo

  echo "--- local dashboard file evidence ---"

  ls -lah public/dashboard.html

  shasum -a 256 public/dashboard.html

  grep -nE 'Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry' public/dashboard.html || true

  echo

  echo "--- live served evidence ---"

  curl -sS -D /tmp/localhost8080.headers -o /tmp/localhost8080.dashboard.html http://localhost:8080/dashboard.html || true

  cat /tmp/localhost8080.headers || true

  shasum -a 256 /tmp/localhost8080.dashboard.html 2>/dev/null || true

  grep -nE 'Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry' /tmp/localhost8080.dashboard.html || true

} | tee "$REPORT"

cat > localhost-8080-stale-serving-finding.txt << 'NOTE'

LOCALHOST 8080 STALE SERVING FINDING

Finding Status: ACTIVE

The live dashboard served from localhost:8080 does not match the current repo public/dashboard.html.

Next safe action:

Identify the process serving port 8080 and its working directory before making additional UI patches.

NOTE

git add inspect-localhost-8080-serving-source.sh localhost-8080-stale-serving-finding.txt "$REPORT"

git commit -m "Inspect localhost dashboard serving source" || true

git push

