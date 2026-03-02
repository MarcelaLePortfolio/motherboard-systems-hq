#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://127.0.0.1:8080"
PSQL="docker compose exec -T postgres psql -U postgres -d postgres -At"

echo "=== Phase 57 snapshot smoke ==="

# Ensure dashboard is up
for i in {1..30}; do
  code="$(curl -sS -o /dev/null -w "%{http_code}" $BASE_URL/api/runs || true)"
  if [[ "$code" == "200" ]]; then
    break
  fi
  sleep 1
done

echo "Creating synthetic run via probe..."
curl -sS -X POST "$BASE_URL/api/policy/probe" \
  -H "content-type: application/json" \
  -d '{"kind":"phase57.test","task_id":"phase57-task","run_id":"phase57-run"}' \
  >/dev/null || true

sleep 1

echo "Checking run_snapshots..."
COUNT="$($PSQL -c "SELECT count(*) FROM run_snapshots WHERE run_id='phase57-run';")"

if [[ "$COUNT" -eq 0 ]]; then
  echo "❌ No snapshot row created"
  exit 1
fi

echo "✅ Snapshot row present ($COUNT rows)"
