
#!/bin/bash

set -e

echo "🔍 Phase 740 Recent Tasks Empty Diagnostic"

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

});

'

echo

echo "----- ACTIVE DOM MOUNT CHECK -----"

grep -n "id=\"recentTasks\"" public/index.html || true

grep -n "tasks-widget" public/index.html || true

echo

echo "----- AUTHORITATIVE RECENT TASKS BRIDGE CHECK -----"

grep -n "function taskRows\|document.getElementById(\"recentTasks\")\|/api/tasks?limit=12\|recentTasks.innerHTML" public/js/phase530_visible_panels_bridge.js || true

echo

echo "----- LEGACY RECENT TASKS WIRE DISABLED CHECK -----"

grep -n "PHASE719_LEGACY_RECENT_TASKS_DISABLED\|return;" public/js/phase565_recent_tasks_wire.js || true

echo

echo "----- JS SYNTAX CHECKS -----"

node --check public/js/phase530_visible_panels_bridge.js

node --check public/js/phase531_recent_tasks_layout_fix.js

node --check public/js/phase565_recent_tasks_wire.js

echo

echo "----- SERVED BRIDGE VERSION CHECK -----"

curl -s "http://localhost:3000/js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper" | grep -n "function taskRows\|/api/tasks?limit=12\|recentTasks.innerHTML" | head -n 20 || true

echo

echo "----- CONCLUSION HINT -----"

echo "If API count is nonzero and JS syntax passes, empty Recent Tasks is likely browser-side runtime ordering, stale cache, or phase530 render path not firing."

echo

echo "----- GIT STATUS -----"

git status

