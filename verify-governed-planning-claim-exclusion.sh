
#!/usr/bin/env bash

set -euo pipefail

echo "--- verify governed_planning exclusions in active claim SQL paths ---"

for f in \

  server/worker/phase32_claim_one.sql \

  server/sql/phase39_claim_one_with_value_gate.sql \

  sql/phase40_claim_one_tierA.sql \

  server/worker/phase35_claim_one_pg.sql \

  server/worker/phase27_claim_one.sql

do

  echo

  echo "===== $f ====="

  grep -n "governed_planning" "$f" || {

    echo "MISSING governed_planning exclusion in $f"

    exit 1

  }

done

echo

echo "PASS: all active claim SQL paths exclude governed_planning records."

