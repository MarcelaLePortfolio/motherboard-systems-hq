#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/dashboard_down_followup_${STAMP}.txt"

{
echo "DASHBOARD DOWN FOLLOW-UP INSPECTION"
echo "Timestamp: $(date)"
echo

echo "==== LIKELY PRIMARY FINDING ===="
echo "Docker daemon appears unavailable because docker.sock could not be reached."
echo "Dashboard on :8080 appears down."
echo "Something may still be responding on :3000."
echo

echo "==== LAST INSPECTION FILES ===="
ls -1t docs/dashboard_down_inspection_*.txt 2>/dev/null || true
echo

echo "==== LOCAL PORT 3000 / 8080 LISTENERS ===="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
echo

echo "==== HTTP HEADERS ===="
curl -I -sS http://127.0.0.1:3000/ || true
echo
curl -I -sS http://127.0.0.1:8080/ || true
echo

echo "==== HTTP TITLE / FIRST LINES FROM :3000 ===="
curl -sS http://127.0.0.1:3000/ | sed -n '1,40p' || true
echo

echo "==== PROCESS MATCHES (node / next / tsx / dashboard) ===="
ps aux | grep -Ei 'next|node|tsx|dashboard' | grep -v grep || true
echo

echo "==== DOCKER CLIENT / DAEMON CHECK ===="
which docker || true
docker version 2>&1 || true
echo

echo "==== DOCKER DESKTOP PROCESS CHECK ===="
ps aux | grep -i "Docker Desktop" | grep -v grep || true
ps aux | grep -i "/Applications/Docker.app" | grep -v grep || true
echo

echo "==== REPO ROOT FILE PRESENCE ===="
find . -maxdepth 2 \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' -o -name 'package.json' \) | sort || true
echo

echo "==== PACKAGE SCRIPTS ===="
if [ -f package.json ]; then
  node -e 'const p=require("./package.json"); console.log(JSON.stringify(p.scripts||{}, null, 2))' 2>/dev/null || cat package.json
else
  echo "No package.json at repo root"
fi
echo

echo "==== QUICK DIAGNOSIS ===="
echo "1) If Docker daemon is down, the containerized dashboard cannot be serving :8080."
echo "2) If :3000 responds, a local non-Docker process may still be running."
echo "3) Next step is to identify whether :3000 is the dashboard and whether Docker needs restarting."
echo

} > "$OUT"

echo "Follow-up inspection report written to:"
echo "$OUT"
