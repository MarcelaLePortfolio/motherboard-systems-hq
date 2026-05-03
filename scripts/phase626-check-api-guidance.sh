#!/usr/bin/env bash
set -euo pipefail

curl -s http://localhost:8080/api/tasks | node -e '
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
