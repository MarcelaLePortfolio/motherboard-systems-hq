
#!/usr/bin/env bash

set -euo pipefail

OUT="governance-schema-for-operational-intake-inspection.txt"

{

  echo "# Governance Schema for Operational Intake Inspection"

  echo

  echo "Generated: $(date)"

  echo

  echo "## db/governance.schema.ts"

  sed -n '1,260p' db/governance.schema.ts

  echo

  echo "## drizzle/0004_governance_lifecycle_artifacts.sql"

  sed -n '1,260p' drizzle/0004_governance_lifecycle_artifacts.sql

} > "$OUT"

cat "$OUT"

