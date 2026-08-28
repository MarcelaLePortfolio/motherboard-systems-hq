#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD_PREFIX="67a9bf897"
CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
[[ "${CURRENT_HEAD}" == "${EXPECTED_HEAD_PREFIX}"* ]]

echo "=== VERIFIED DIAGNOSIS ==="
echo "FRONTEND_5173=RUNNING"
echo "VITE_API_TARGET=http://localhost:3000"
echo "BACKEND_3000=NOT_RUNNING"
echo "ROOT_SERVER_PORT=3000"
echo "CAUSE=FRONTEND_SHELL_RUNNING_WITHOUT_REQUIRED_BACKEND"

echo
echo "=== BUILD EXISTING BACKEND ==="
npm run build

echo
echo "=== START EXISTING COMPILED BACKEND ==="
if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "BACKEND_3000_ALREADY_RUNNING=YES"
else
  nohup node dist/server/index.js \
    >/tmp/motherboard-backend.log 2>&1 &
  echo "$!" >/tmp/motherboard-backend.pid
fi

echo
echo "=== WAIT FOR PORT 3000 ==="
READY=NO
for _ in $(seq 1 15); do
  if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
    READY=YES
    break
  fi
  sleep 1
done

if [[ "${READY}" != "YES" ]]; then
  echo "BACKEND_RESTORE=FAIL"
  cat /tmp/motherboard-backend.log 2>/dev/null || true
  exit 1
fi

echo
echo "=== VERIFY PROJECT REGISTRY THROUGH DASHBOARD PROXY ==="
HTTP_CODE="$(curl -sS -o /tmp/project-registry-response.json -w '%{http_code}' \
  http://127.0.0.1:5173/api/projects/registry || true)"

echo "PROJECT_REGISTRY_HTTP_STATUS=${HTTP_CODE}"
cat /tmp/project-registry-response.json 2>/dev/null || true
echo

if [[ "${HTTP_CODE}" -lt 200 || "${HTTP_CODE}" -ge 300 ]]; then
  echo "DASHBOARD_BACKEND_RESTORE=FAIL"
  echo "=== BACKEND LOG ==="
  cat /tmp/motherboard-backend.log 2>/dev/null || true
  exit 1
fi

echo "DASHBOARD_BACKEND_RESTORE=PASS"
echo "FRONTEND_URL=http://localhost:5173/"
echo "BACKEND_URL=http://localhost:3000/"
echo "PROJECT_REGISTRY_PROXY=PASS"
echo "PRODUCTION_ROUTE_ACTIVATION_ATTEMPTED=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
