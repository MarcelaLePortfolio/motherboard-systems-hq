
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="MOUNTED_GOVERNED_PLANNING_ROUTE_SMOKE.txt"

RESPONSE="/tmp/governed-planning-response.json"

PORT="${PORT:-3000}"

URL="http://localhost:${PORT}/api/governed-planning/dry-run"

rm -f "$OUTPUT" "$RESPONSE"

echo "===== MOUNTED GOVERNED PLANNING ROUTE SMOKE =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== ROUTE =====" | tee -a "$OUTPUT"

echo "$URL" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== SERVER SYNTAX =====" | tee -a "$OUTPUT"

node --check server.mjs | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== ROUTE SYNTAX =====" | tee -a "$OUTPUT"

node --check server/routes/governed-planning-route.mjs | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== HTTP RESPONSE =====" | tee -a "$OUTPUT"

curl -sS -X POST "$URL" -H "Content-Type: application/json" --data @server/execution/smoke-test-governed-route-payload.json > "$RESPONSE"

cat "$RESPONSE" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== RESPONSE AUTHORITY CHECK =====" | tee -a "$OUTPUT"

node - "$RESPONSE" << 'NODE' | tee -a "$OUTPUT"

const fs = require("fs");

const responsePath = process.argv[2];

const raw = fs.readFileSync(responsePath, "utf8");

const parsed = JSON.parse(raw);

const bundle =

  parsed.bundle ||

  parsed.response?.bundle ||

  parsed.response ||

  parsed;

const authority =

  bundle.execution_authority ||

  bundle.response?.execution_authority ||

  bundle.artifacts?.response?.execution_authority ||

  {};

const failed =

  authority.mutation_performed === true ||

  authority.shell_execution_performed === true ||

  authority.autonomous_execution_performed === true;

console.log(JSON.stringify({

  ok: !failed,

  mutation_performed: authority.mutation_performed === true,

  shell_execution_performed: authority.shell_execution_performed === true,

  autonomous_execution_performed: authority.autonomous_execution_performed === true

}, null, 2));

if (failed) process.exit(1);

NODE

echo "" | tee -a "$OUTPUT"

echo "===== GIT HEAD =====" | tee -a "$OUTPUT"

git log --oneline -5 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add smoke-mounted-governed-planning-route.sh MOUNTED_GOVERNED_PLANNING_ROUTE_SMOKE.txt

git commit -m "Smoke test mounted governed planning route"

git push

