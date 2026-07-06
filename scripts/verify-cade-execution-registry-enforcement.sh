
#!/usr/bin/env bash

set -euo pipefail

echo "=== Cade Execution Registry Enforcement Layer ==="

REGISTRY="docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.md"

echo ""

echo "1. Extracting allowed execution authority files from registry..."

ALLOWED_FILES=$(grep -A 50 "Primary Execution Switch Authority" "$REGISTRY" \

  | grep "-" \

  | sed 's/- //g' \

  | sed '/^$/d' || true)

echo "$ALLOWED_FILES"

echo ""

echo "2. Scanning all execution_authorized mutations..."

VIOLATIONS=0

while IFS= read -r line; do

  FILE=$(echo "$line" | cut -d: -f1)

  MATCH=0

  while IFS= read -r allowed; do

    echo "$FILE" | grep -q "$allowed" && MATCH=1

  done <<< "$ALLOWED_FILES"

  if [ "$MATCH" -eq 0 ]; then

    echo "❌ VIOLATION: $FILE modifies execution state but is not in registry"

    VIOLATIONS=1

  fi

done < <(grep -Rni "execution_authorized" server db || true)

echo ""

echo "3. Final result..."

if [ "$VIOLATIONS" -ne 0 ]; then

  echo "❌ Registry enforcement FAILED"

  exit 1

fi

echo "✅ Registry enforcement PASSED"

