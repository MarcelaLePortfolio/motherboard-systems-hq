#!/usr/bin/env bash
set -euo pipefail

API_URL="http://localhost:3000/api/tasks"

echo "Container status:"
docker compose ps

echo
echo "Checking guidance exposure at $API_URL..."
RAW="$(curl -fsS "$API_URL" || true)"

if [ -z "$RAW" ]; then
  echo "ERROR: Empty response from $API_URL"
  exit 1
fi

printf '%s' "$RAW" | node -e '
let data="";
process.stdin.on("data", c => data += c);
process.stdin.on("end", () => {
  const json = JSON.parse(data);
  const latest = (json.tasks || [])[0];
  console.log(JSON.stringify({
    latestTaskId: latest?.task_id || latest?.taskId || latest?.id,
    hasGuidance: Boolean(latest?.guidance),
    guidance: latest?.guidance || null,
    payloadGuidance: latest?.payload?.guidance || null
  }, null, 2));
});
'
