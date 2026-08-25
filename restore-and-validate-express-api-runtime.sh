#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RESTORE AND VALIDATE EXPRESS API RUNTIME ==="
echo "BASELINE_COMMIT=04ac79b5"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DEV_RUNTIME_STARTUP_MISMATCH=ESTABLISHED"

echo
echo "=== PRE-START PORT 3000 ==="
(lsof -nP -iTCP:3000 -sTCP:LISTEN || true)

echo
echo "=== START EXPRESS DEV SERVER ==="
if ! lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  nohup npm run dev > /tmp/motherboard-express-dev.log 2>&1 &
  echo $! > /tmp/motherboard-express-dev.pid
fi

for _ in 1 2 3 4 5; do
  if curl -sS http://localhost:3000/api/projects/registry >/tmp/project-registry-direct.json 2>/dev/null; then
    break
  fi
  sleep 1
done

echo
echo "=== EXPRESS PROCESS ==="
(lsof -nP -iTCP:3000 -sTCP:LISTEN || true)

echo
echo "=== DIRECT API VALIDATION ==="
DIRECT_CODE="$(curl -sS -o /tmp/project-registry-direct.json -w '%{http_code}' http://localhost:3000/api/projects/registry || true)"
echo "DIRECT_HTTP_STATUS=${DIRECT_CODE}"
cat /tmp/project-registry-direct.json 2>/dev/null || true
echo

echo
echo "=== VITE PROXY VALIDATION ==="
for port in 5173 5174; do
  body="/tmp/project-registry-vite-${port}.json"
  code="$(curl -sS -o "$body" -w '%{http_code}' "http://localhost:${port}/api/projects/registry" || true)"
  echo "VITE_${port}_HTTP_STATUS=${code}"
  cat "$body" 2>/dev/null || true
  echo
done

echo
echo "=== SERVER LOG TAIL ==="
tail -n 80 /tmp/motherboard-express-dev.log 2>/dev/null || true

echo
echo "=== VALIDATION BOUNDARY ==="
echo "EXPECTED_DIRECT_STATUS=200"
echo "EXPECTED_VITE_PROXY_STATUS=200"
echo "EXPECTED_ACTIVE_PROJECT_ID=executive-agent-suite"
echo "CODE_CHANGE_REQUIRED=NO"
echo "NEXT_ACTION=RELOAD_UI_AND_VERIFY_MISSION_CONTROL_AND_APPROVALS_IF_ALL_HTTP_STATUSES_ARE_200"
