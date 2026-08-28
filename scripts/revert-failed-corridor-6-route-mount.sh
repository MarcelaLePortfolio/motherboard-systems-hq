#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD_PREFIX="62d15f9ba"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== REVERT FAILED CORRIDOR 6 ROUTE MOUNT ==="
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
echo "RECOVERY_POINT=DR_20260828_102500"
echo "FAILURE_CLASS=ROUTE_HANDLER_MOUNT_SIGNATURE_MISMATCH"
echo "PRODUCTION_ROUTE_ACTIVATION=FAILED"
echo "NEXT_HYPOTHESIS=NOT_YET_AUTHORIZED"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

git revert --no-edit 62d15f9ba65cb6ccfc83cd0e336af3575e7b0c5f

npm run build

if [[ -f /tmp/motherboard-backend.pid ]]; then
  OLD_PID="$(cat /tmp/motherboard-backend.pid 2>/dev/null || true)"
  if [[ -n "${OLD_PID}" ]] && kill -0 "${OLD_PID}" 2>/dev/null; then
    kill "${OLD_PID}"
    sleep 1
  fi
fi

nohup node dist/server/index.js >/tmp/motherboard-backend.log 2>&1 &
echo "$!" >/tmp/motherboard-backend.pid

READY=NO
for _ in $(seq 1 15); do
  if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
    READY=YES
    break
  fi
  sleep 1
done

if [[ "${READY}" != "YES" ]]; then
  echo "BACKEND_RUNTIME_RESTORE=FAIL"
  cat /tmp/motherboard-backend.log 2>/dev/null || true
  exit 1
fi

REGISTRY_STATUS="$(
  curl -sS -o /tmp/post-revert-registry.json -w '%{http_code}' \
    http://127.0.0.1:5173/api/projects/registry || true
)"

if [[ "${REGISTRY_STATUS}" != "200" ]]; then
  echo "DASHBOARD_RUNTIME_RESTORE=FAIL"
  exit 1
fi

echo "REVERT=PASS"
echo "BACKEND_RUNTIME=PASS"
echo "DASHBOARD_RUNTIME=PASS"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_STEP=REASSESS_ROUTE_ADAPTER_SHAPE_BEFORE_REAUTHORIZATION"
