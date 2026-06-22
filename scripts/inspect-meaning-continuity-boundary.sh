
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="meaning-continuity-boundary-inspection.txt"

PATTERN="refine|refinement|fundamentally alter|alter its meaning|meaning|continuity|current understanding|understanding|interpretation stability|reconciliation-ready|distinct approved interpretation|replace the model|replace meaning|stability"

{

  echo "=================================================="

  echo "MEANING CONTINUITY BOUNDARY INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "$PATTERN" docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

