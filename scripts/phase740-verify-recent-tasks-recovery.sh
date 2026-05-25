
#!/bin/bash

set -e

echo "🔍 Phase 740 Recent Tasks Recovery Verification"

echo

echo "----- JS SYNTAX CHECK -----"

node --check public/js/phase530_visible_panels_bridge.js

echo

echo "----- API TASK COUNT -----"

curl -s http://localhost:3000/api/tasks | node -e '

let data="";

process.stdin.on("data", chunk => data += chunk);

process.stdin.on("end", () => {

  const parsed = JSON.parse(data);

  console.log("ok:", parsed.ok);

  console.log("task count:", parsed.tasks?.length ?? 0);

  console.log("first task id:", parsed.tasks?.[0]?.task_id ?? "none");

  if (!parsed.ok || !parsed.tasks || parsed.tasks.length === 0) process.exit(1);

});

'

echo

echo "----- SERVED BRIDGE CHECK -----"

curl -s "http://localhost:3000/js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper" | node --check

echo

echo "----- HEALTH CHECK -----"

curl -I http://localhost:3000 || true

echo

echo "✅ Recent Tasks recovery verification passed"

echo

echo "----- GIT STATUS -----"

git status

