
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_SERVER_RESET_DIAGNOSIS.txt"

PORT="${PORT:-3000}"

URL="http://localhost:${PORT}/api/governed-planning/dry-run"

rm -f "$OUTPUT"

echo "===== GOVERNED ROUTE SERVER RESET DIAGNOSIS =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== ROUTE TEST THAT FAILED =====" | tee -a "$OUTPUT"

echo "$URL" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== SERVER SYNTAX =====" | tee -a "$OUTPUT"

node --check server.mjs | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== GOVERNED ROUTE SYNTAX =====" | tee -a "$OUTPUT"

node --check server/routes/governed-planning-route.mjs | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== STATIC IMPORT CHECK =====" | tee -a "$OUTPUT"

node -e 'import("./server/routes/governed-planning-route.mjs").then(() => console.log("IMPORT_OK")).catch((err) => { console.error(err); process.exit(1); })' 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== SERVER IMPORT CHECK =====" | tee -a "$OUTPUT"

node -e 'import("./server.mjs").then(() => console.log("SERVER_IMPORT_OK")).catch((err) => { console.error(err); process.exit(1); })' 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PORT CHECK =====" | tee -a "$OUTPUT"

lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== PM2 STATUS =====" | tee -a "$OUTPUT"

pm2 ls 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== RECENT PM2 LOGS =====" | tee -a "$OUTPUT"

pm2 logs --nostream --lines 80 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== SERVER MOUNT LINES =====" | tee -a "$OUTPUT"

grep -n "governedPlanningRouter\|governed-planning-route\|apiTasksMutationsRouter\|api/tasks-mutations" server.mjs | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add diagnose-governed-route-server-reset.sh GOVERNED_ROUTE_SERVER_RESET_DIAGNOSIS.txt MOUNTED_GOVERNED_PLANNING_ROUTE_SMOKE.txt smoke-mounted-governed-planning-route.sh

git commit -m "Diagnose governed route server reset" || true

git push

