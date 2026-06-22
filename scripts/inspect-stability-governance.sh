
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="stability-governance-inspection.txt"

{

  echo "=================================================="

  echo "STABILITY GOVERNANCE INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "stability|stable|stabilized|interpretation stability|meaning stability|stability assessment|architectural change rate declines|converge|convergence|reconciliation-ready|mature|maturity" \

  docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

