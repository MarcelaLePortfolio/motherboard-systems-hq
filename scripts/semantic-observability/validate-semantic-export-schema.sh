
#!/bin/bash

set -euo pipefail

LATEST_EXPORT=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | sort | tail -n 1)

if [[ -z "$LATEST_EXPORT" ]]; then

  echo "ERROR: No export found."

  exit 1

fi

echo "Schema validating:"

echo "$LATEST_EXPORT"

grep '"status"' "$LATEST_EXPORT" >/dev/null

grep '"rendererAuthority"' "$LATEST_EXPORT" >/dev/null

grep '"executionAuthority"' "$LATEST_EXPORT" >/dev/null

grep '"semanticSubstrate"' "$LATEST_EXPORT" >/dev/null

grep '"artifactScoped"' "$LATEST_EXPORT" >/dev/null

grep '"rendererIndependent"' "$LATEST_EXPORT" >/dev/null

echo "Semantic export schema validation: PASS"

