
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="iel-foundations-inspection.txt"

{

  echo "=================================================="

  echo "IEL FOUNDATIONS INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "IEL|Interpretation Evidence Ledger|Evidence Ledger|Raw Evidence|intent evidence|evidence preservation|evidence record" docs contracts server . 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

