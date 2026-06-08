
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="iel-governance-inspection.txt"

{

  echo "=================================================="

  echo "IEL GOVERNANCE INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "IEL|Interpretation Evidence Ledger" docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

