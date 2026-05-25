
#!/bin/bash

set -e

echo "🔍 Phase 739 Sandbox Governance Verification"

echo

REQUIRED_FILES=(

  "PHASE_739_DETERMINISTIC_SANDBOX_PREVIEW_PAYLOAD_GENERATION.md"

  "SANDBOX_PREVIEW_PAYLOAD_SCHEMA_DRAFT.md"

  "SEMANTIC_COMPONENT_MAPPING_REGISTRY_DRAFT.md"

  "INTERACTION_ANNOTATION_SPECIFICATION_DRAFT.md"

  "INSPECTED_INTENT_OVERLAY_SPECIFICATION_DRAFT.md"

  "SANDBOX_PAYLOAD_VALIDATION_SPECIFICATION.md"

  "PHASE_739_SANDBOX_PREVIEW_PAYLOAD_MANIFEST.md"

)

FAILED=0

for FILE in "${REQUIRED_FILES[@]}"

do

  if [ -f "$FILE" ]; then

    echo "✅ VERIFIED: $FILE"

  else

    echo "❌ MISSING: $FILE"

    FAILED=1

  fi

done

echo

if [ "$FAILED" -eq 0 ]; then

  echo "✅ Phase 739 governance verification PASSED"

  exit 0

else

  echo "❌ Phase 739 governance verification FAILED"

  exit 1

fi

