
#!/usr/bin/env bash

set -euo pipefail

echo "--- verify governed_planning exclusions in active claim SQL paths ---"

for f in server/worker/phase32_claim_one.sql server/sql/phase39_claim_one_with_value_gate.sql sql/phase40_claim_one_tierA.sql server/worker/phase35_claim_one_pg.sql server/worker/phase27_claim_one.sql; do

  echo

  echo "===== $f ====="

  if grep -n "governed_planning" "$f"; then

    :

  else

    echo "MISSING governed_planning exclusion in $f"

  fi

done

echo

echo "--- planning-only exclusion checks ---"

for f in server/worker/phase32_claim_one.sql server/sql/phase39_claim_one_with_value_gate.sql sql/phase40_claim_one_tierA.sql server/worker/phase35_claim_one_pg.sql server/worker/phase27_claim_one.sql; do

  echo

  echo "===== $f ====="

  grep -nE "planning_only|governed_planning|kind" "$f" || true

done

