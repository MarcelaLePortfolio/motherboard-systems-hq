#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD_PREFIX="774f0f6f3"
CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
[[ "${CURRENT_HEAD}" == "${EXPECTED_HEAD_PREFIX}"* ]]

echo "=== DASHBOARD RUNTIME OWNER ==="
echo "CLIENT_RUNTIME=client/package.json"
echo "CLIENT_DEV_COMMAND=npm run dev"
echo "EXPECTED_CLIENT_PORT=5173"

echo
echo "=== EXISTING LISTENER ==="
if lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "DASHBOARD_5173_ALREADY_RUNNING=YES"
else
  echo "DASHBOARD_5173_ALREADY_RUNNING=NO"
  cd client
  nohup npm run dev -- --host 127.0.0.1 \
    >/tmp/motherboard-dashboard-vite.log 2>&1 &
  echo "$!" >/tmp/motherboard-dashboard-vite.pid
  cd ..
fi

echo
echo "=== WAIT FOR DASHBOARD ==="
READY=NO
for _ in $(seq 1 15); do
  if curl -fsS http://127.0.0.1:5173/ >/tmp/motherboard-dashboard-response.html 2>/dev/null; then
    READY=YES
    break
  fi
  sleep 1
done

if [[ "${READY}" != "YES" ]]; then
  echo "DASHBOARD_RESTORE=FAIL"
  echo "=== VITE LOG ==="
  cat /tmp/motherboard-dashboard-vite.log 2>/dev/null || true
  exit 1
fi

echo "DASHBOARD_RESTORE=PASS"
echo "DASHBOARD_URL=http://localhost:5173/"
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

echo
echo "PRODUCTION_ROUTE_ACTIVATION_ATTEMPTED=NO"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
