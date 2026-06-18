
#!/usr/bin/env bash

set -euo pipefail

echo "--- active claim SQL files ---"

for f in \

  server/sql/phase39_claim_one_with_value_gate.sql \

  sql/phase40_claim_one_tierA.sql \

  server/worker/phase35_claim_one_pg.sql \

  server/worker/phase27_claim_one.sql

do

  if [ -f "$f" ]; then

    echo

    echo "===== $f ====="

    sed -n '1,220p' "$f"

  else

    echo

    echo "===== $f missing ====="

  fi

done

