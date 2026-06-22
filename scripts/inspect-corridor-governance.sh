
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="corridor-governance-inspection.txt"

{

  echo "=================================================="

  echo "CORRIDOR GOVERNANCE INSPECTION"

  echo "=================================================="

  echo

  grep -RniE \

  "corridor|interpretation corridor|discovery corridor|reconciliation corridor|organizational understanding|understanding may have changed|context boundary|corridor boundary|stability|reconciliation-ready" \

  docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

