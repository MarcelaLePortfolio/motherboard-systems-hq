
#!/usr/bin/env bash

set -euo pipefail

echo "=== Cade Execution Source-of-Truth Compliance Check ==="

echo ""

echo "1. Checking for unauthorized execution_authorized mutations outside registry-approved files..."

ALLOWED="

matilda-execution-authorization-route.ts

matilda-execution-authorization-runtime.ts

matilda-execution-switch-evaluator.ts

matilda-execution-planning-route.ts

matilda-execution-planning-runtime.ts

matilda-preview-route.ts

matilda-preview-confirmation-route.ts

matilda-preview-runtime.ts

matilda-preview-confirmation-runtime.ts

execution-approval-gate.mjs

"

while IFS= read -r line; do

  echo "$line" | grep -q "execution_authorized" || continue

  FILE=$(echo "$line" | cut -d: -f1)

  ALLOWED_MATCH=0

  for a in $ALLOWED; do

    echo "$FILE" | grep -q "$a" && ALLOWED_MATCH=1

  done

  if [ "$ALLOWED_MATCH" -eq 0 ]; then

    echo "❌ NON-COMPLIANT EXECUTION MUTATION FOUND: $FILE"

  fi

done < <(grep -Rni "execution_authorized" server db | grep -v node_modules || true)

echo ""

echo "2. Checking for EXECUTABLE state derivation outside switch evaluator..."

grep -Rni "EXECUTABLE" server db docs | grep -v "matilda-execution-switch-evaluator" || true

echo ""

echo "3. Checking registry existence..."

test -f docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.md && echo "OK: registry present" || echo "MISSING: registry"

echo ""

echo "=== Compliance Check Complete ==="

