
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="distinct-approved-interpretation-inspection.txt"

{

  echo "=================================================="

  echo "DISTINCT APPROVED INTERPRETATION INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "distinct approved interpretation|approved interpretation|interpretation lineage|lineage|meaning artifact|canonical meaning artifact" docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

