
#!/bin/bash

echo "=== PHASE 734 VISUAL ARTIFACT GENERATOR INSPECTION ==="

echo ""

echo "--- searching visual artifact generation paths ---"

echo ""

grep -Rni "visual_artifact_generation" server scripts . 2>/dev/null || true

echo ""

echo "--- searching preview concept template strings ---"

echo ""

grep -Rni "Preview Concept" server scripts public . 2>/dev/null || true

echo ""

echo "--- searching Hero/Offer/CTA fallback template ---"

echo ""

grep -Rni "Brand story" server scripts public . 2>/dev/null || true

grep -Rni "Core promise" server scripts public . 2>/dev/null || true

grep -Rni "Reserve a box" server scripts public . 2>/dev/null || true

echo ""

echo "--- searching visual artifact helpers ---"

echo ""

grep -Rni "visual-artifact:start" server scripts public . 2>/dev/null || true

echo ""

echo "--- searching prompt augmentation paths ---"

echo ""

grep -Rni "prompt_augmentation" server scripts . 2>/dev/null || true

echo ""

echo "--- searching HTML synthesis helpers ---"

echo ""

grep -Rni "generate.*artifact" server scripts . 2>/dev/null || true

grep -Rni "artifact.*html" server scripts . 2>/dev/null || true

echo ""

echo "Inspection complete."

