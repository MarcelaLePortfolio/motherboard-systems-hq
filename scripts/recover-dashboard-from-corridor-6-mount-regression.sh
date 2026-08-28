#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="0724d9f2798ecfb6ed3758fcbb37514fe619de61"
STABLE_PRE_MOUNT_COMMIT="feba46c6fec03fd10fca09538d2e62c3d013a2a6"

cd "$(git rev-parse --show-toplevel)"

CURRENT_HEAD="$(git rev-parse HEAD)"
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

git diff --quiet
git diff --cached --quiet

git checkout "${STABLE_PRE_MOUNT_COMMIT}" -- server/index.ts
git rm -f --ignore-unmatch \
  server/execution/production-governance-execution-mount.test.mjs \
  scripts/implement-corridor-6-dynamic-bootstrap-route-mount.sh

npm run build

node dist/server/index.js > /tmp/dashboard-recovery.log 2>&1 &
SERVER_PID=$!
sleep 3

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
  cat /tmp/dashboard-recovery.log
  echo "RECOVERY_RUNTIME_CHECK=FAIL"
  exit 1
fi

kill "${SERVER_PID}" 2>/dev/null || true
wait "${SERVER_PID}" 2>/dev/null || true

echo "RECOVERY_RUNTIME_CHECK=PASS"
echo "DEDICATED_ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=ROLLED_BACK"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"

git add server/index.ts scripts/recover-dashboard-from-corridor-6-mount-regression.sh
git commit -m "Rollback Corridor 6 mount after production runtime regression"
git push
