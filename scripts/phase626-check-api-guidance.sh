#!/usr/bin/env bash
set -euo pipefail

echo "Container status:"
docker compose ps

echo
echo "Checking /api/tasks guidance exposure..."
RAW="$(curl -fsS http://localhost:8080/api/tasks || true)"

if [ -z "$RAW" ]; then
  echo "ERROR: Empty response from http://localhost:8080/api/tasks"
  echo "Start or restart the stack with: docker compose up -d"
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
