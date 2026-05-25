
#!/bin/bash

set -e

echo "🔧 Rebuilding dashboard so served bridge matches repaired repo source"

docker compose up -d --build dashboard

sleep 8

echo

echo "----- LOCAL BRIDGE SYNTAX -----"

node --check public/js/phase530_visible_panels_bridge.js

echo

echo "----- SERVED BRIDGE SYNTAX -----"

curl -s "http://localhost:3000/js/phase530_visible_panels_bridge.js?v=phase723-visual-wrapper" | node --check

echo

echo "----- API TASK COUNT -----"

curl -s http://localhost:3000/api/tasks | node -e '

let data="";

process.stdin.on("data", chunk => data += chunk);

process.stdin.on("end", () => {

  const parsed = JSON.parse(data);

  console.log("ok:", parsed.ok);

  console.log("task count:", parsed.tasks?.length ?? 0);

  if (!parsed.ok || !parsed.tasks || parsed.tasks.length === 0) process.exit(1);

});

'

echo

echo "----- DASHBOARD HEALTH -----"

curl -I http://localhost:3000 || true

echo

echo "✅ Served phase530 bridge recovery verified"

