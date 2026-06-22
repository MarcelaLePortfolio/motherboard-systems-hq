
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="interpretation-event-inspection.txt"

{

  echo "=================================================="

  echo "INTERPRETATION EVENT INSPECTION"

  echo "=================================================="

  echo

  grep -RniE "Interpretation Event|Matilda Observation|observation|evidence capture|evidence preservation|interpretation" \

    docs/governance docs/contracts 2>/dev/null || true

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

