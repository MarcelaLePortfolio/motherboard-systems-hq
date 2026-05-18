
#!/bin/bash

set -euo pipefail

LATEST_EXPORT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | sort | tail -n 1)

if [[ -z "$LATEST_EXPORT" ]]; then

  echo "ERROR: No semantic preview snapshot export found."

  exit 1

fi

echo "Validating export:"

echo "$LATEST_EXPORT"

grep '"rendererAuthority": "preserved"' "$LATEST_EXPORT" >/dev/null

grep '"executionAuthority": "preserved"' "$LATEST_EXPORT" >/dev/null

grep '"mode": "observational-only"' "$LATEST_EXPORT" >/dev/null

echo "Semantic preview export validation: PASS"

