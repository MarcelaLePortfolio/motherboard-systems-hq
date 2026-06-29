
#!/usr/bin/env bash

set -euo pipefail

OUT="governance-runtime-patterns-inspection.txt"

{

  echo "# Governance Runtime Pattern Inspection"

  echo

  echo "Generated: $(date)"

  echo

  echo "## governance-runtime.ts"

  sed -n '1,250p' db/governance-runtime.ts

  echo

  echo "## governance-lifecycle-persistence.ts"

  sed -n '1,250p' db/governance-lifecycle-persistence.ts

  echo

  echo "## governance-lifecycle-composition.ts"

  sed -n '1,250p' db/governance-lifecycle-composition.ts

} > "$OUT"

cat "$OUT"

