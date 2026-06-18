
#!/usr/bin/env bash

set -euo pipefail

echo "--- governed planning task record creation ---"

grep -nE "status|kind|source|governed_planning|planning_only|dbDelegateTask" server/routes/governed-planning-route.mjs

echo

echo "--- authoritative task mutation status writers ---"

grep -nE "const status|status =|kind:|task.completed|task.failed|task.created" server/tasks-mutations.mjs server/routes/api-tasks-mutations.mjs server/routes/api-tasks-postgres.mjs

echo

echo "--- active worker claim status assumptions ---"

grep -nE "status|governed_planning|queued|delegated|created|running" server/worker/phase32_claim_one.sql server/sql/phase39_claim_one_with_value_gate.sql sql/phase40_claim_one_tierA.sql server/worker/phase35_claim_one_pg.sql server/worker/phase27_claim_one.sql

echo

echo "--- recent tasks status rendering only ---"

grep -nE "queued|delegated|running|done|failed|planning_record|task.status|data-task-status" public/js/phase565_recent_tasks_wire.js public/js/phase22_task_delegation_live_bindings.js public/dashboard.html public/index.html || true

