#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-45}"

echo "== Phase 64 agent activity probe =="
echo "BASE_URL=$BASE_URL"

echo
echo "-- layout contract"
bash scripts/verify-phase62-layout-contract.sh

echo
echo "-- wait for dashboard readiness"
deadline=$((SECONDS + MAX_WAIT_SECONDS))
until curl -fsS "$BASE_URL/dashboard" >/tmp/phase64_dashboard.html 2>/dev/null; do
  if (( SECONDS >= deadline )); then
    echo "ERROR: dashboard did not become reachable within ${MAX_WAIT_SECONDS}s at $BASE_URL"
    echo
    echo "-- docker port map"
    docker compose port dashboard 3000 || true
    echo
    echo "-- recent dashboard logs"
    docker compose logs --tail=120 dashboard || true
    exit 1
  fi
  sleep 2
done

echo
echo "-- existing loader chain asset"
curl -fsS "$BASE_URL/js/phase61_recent_history_wire.js" >/tmp/phase61_recent_history_wire.js

echo
echo "-- phase64 loader asset"
curl -fsS "$BASE_URL/js/phase64_agent_activity_bootstrap.js" >/tmp/phase64_agent_activity_bootstrap.js

echo
echo "-- phase64 wire asset"
curl -fsS "$BASE_URL/js/phase64_agent_activity_wire.js" >/tmp/phase64_agent_activity_wire.js

echo
echo "-- asset presence checks"
grep -q 'phase64_agent_activity_bootstrap.js' /tmp/phase61_recent_history_wire.js || {
  echo "ERROR: phase61_recent_history_wire.js is not chaining phase64_agent_activity_bootstrap.js"
  exit 1
}

grep -q 'window.__PHASE64_AGENT_WIRE_LOADED__' /tmp/phase64_agent_activity_bootstrap.js || {
  echo "ERROR: bootstrap asset contents unexpected"
  exit 1
}

grep -q 'window.taskEventsStream' /tmp/phase64_agent_activity_wire.js || {
  echo "ERROR: agent activity wire asset contents unexpected"
  exit 1
}

echo
echo "-- live http probe"
bash scripts/_local/phase63_live_http_probe.sh

echo
echo "PASS: Phase 64 agent activity assets reachable, chained, and layout contract still passing"
