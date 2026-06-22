
#!/usr/bin/env bash

set -euo pipefail

echo "--- phase26 configured sql paths ---"

grep -nE "CLAIM_ONE_PATH|MARK_SUCCESS_PATH|MARK_FAILURE_PATH|PHASE32_CLAIM_ONE_SQL|PHASE27_CLAIM_ONE_SQL" \

  server/worker/phase26_task_worker.mjs || true

echo

echo "--- phase32 claim sql ---"

for f in \

  server/worker/phase32_claim_one.sql \

  server/worker/phase35_claim_one_pg.sql \

  server/worker/phase27_claim_one.sql

do

  if [ -f "$f" ]; then

    echo

    echo "===== $f ====="

    cat "$f"

  fi

done

echo

echo "--- task creation routes ---"

git grep -nE "INSERT INTO tasks|status.*queued|status.*delegated|governed|execution envelope|execution_envelope|task_type|action_tier" \

  server scripts public -- '*.mjs' '*.js' 2>/dev/null || true

echo

echo "--- governed planning task production ---"

git grep -nE "governed-planning|execution-envelope|approval-gate|task_type|action_tier" \

  server/execution server/routes server/api 2>/dev/null || true

