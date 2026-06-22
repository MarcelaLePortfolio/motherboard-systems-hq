
#!/usr/bin/env bash

set -euo pipefail

echo "--- worker sql selection logic ---"

grep -n "CLAIM_ONE_PATH" server/worker/phase26_task_worker.mjs

echo

echo "--- phase32 env references ---"

git grep -n "PHASE32_CLAIM_ONE_SQL"

echo

echo "--- phase27 env references ---"

git grep -n "PHASE27_CLAIM_ONE_SQL"

echo

echo "--- phase35 env references ---"

git grep -n "phase35_claim_one_pg.sql"

echo

echo "--- docker worker configs ---"

git grep -n "phase32_claim_one.sql\|phase35_claim_one_pg.sql\|phase27_claim_one.sql" \

  Dockerfile* docker-compose* scripts server . || true

