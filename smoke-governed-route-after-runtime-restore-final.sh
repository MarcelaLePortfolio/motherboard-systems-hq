
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="GOVERNED_ROUTE_AFTER_RUNTIME_RESTORE_FINAL_SMOKE.txt"

URL="http://localhost:8080/api/governed-planning/dry-run"

rm -f "$OUTPUT"

{

  echo "===== GOVERNED ROUTE AFTER RUNTIME RESTORE FINAL SMOKE ====="

  date

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== BASELINE HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== GOVERNED ROUTE HTTP RESPONSE ====="

  curl -sS -i -X POST "$URL" -H "Content-Type: application/json" --data @server/execution/smoke-test-governed-route-payload.json

  echo

  echo "===== GOVERNED ROUTE AUTHORITY ASSERTION ====="

  curl -sS -X POST "$URL" -H "Content-Type: application/json" --data @server/execution/smoke-test-governed-route-payload.json | node -e '

let s="";

process.stdin.on("data", d => s += d);

process.stdin.on("end", () => {

  const body = JSON.parse(s);

  const authority = body.bundle?.execution_authority || body.bundle?.response?.execution_authority || {};

  const failed = authority.mutation_performed === true || authority.shell_execution_performed === true || authority.autonomous_execution_performed === true;

  console.log(JSON.stringify({

    ok: body.ok === true && failed === false,

    route: body.route,

    mutation_performed: authority.mutation_performed === true,

    shell_execution_performed: authority.shell_execution_performed === true,

    autonomous_execution_performed: authority.autonomous_execution_performed === true

  }, null, 2));

  if (body.ok !== true || failed) process.exit(1);

});'

  echo

  echo "===== IN-PROCESS CONTROL ====="

  node server/execution/smoke-test-governed-route-inprocess.mjs

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add smoke-governed-route-after-runtime-restore-final.sh GOVERNED_ROUTE_AFTER_RUNTIME_RESTORE_FINAL_SMOKE.txt

git commit -m "Confirm governed route after runtime restore" || true

git push

