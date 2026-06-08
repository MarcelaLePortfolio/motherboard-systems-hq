
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="governance-validation-operationalization-inspection.txt"

{

  echo "=================================================="

  echo "GOVERNANCE VALIDATION OPERATIONALIZATION INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "operationalizes|operationalization|Governance Validation|consumes Delegation|Envelope created|Envelope creation|routing|assignment|planning" docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

