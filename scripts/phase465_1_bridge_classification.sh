#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase465_1_bridge_classification.txt"
INPUT="docs/phase465_0_governance_execution_bridge_probe.txt"

mkdir -p docs

echo "PHASE 465.1 — BRIDGE CLASSIFICATION" > "$OUT"
echo "===================================" >> "$OUT"
echo >> "$OUT"

if [ ! -f "$INPUT" ]; then
  echo "ERROR: missing probe file: $INPUT" | tee -a "$OUT"
  exit 1
fi

echo "STEP 1 — Signal extraction" >> "$OUT"

GOV_COUNT=$(rg -c "governance|policy|decision|evaluate" "$INPUT" || echo 0)
EXEC_COUNT=$(rg -c "execute|run|dispatch|task|job" "$INPUT" || echo 0)
BRIDGE_COUNT=$(rg -c "governance.*execute|execute.*governance|policy.*run|run.*policy" "$INPUT" || echo 0)
INTAKE_COUNT=$(rg -c "intake|request|normalize|validate" "$INPUT" || echo 0)
PREP_COUNT=$(rg -c "prepare|ready|authorization|eligible" "$INPUT" || echo 0)

echo "Governance signals: $GOV_COUNT" >> "$OUT"
echo "Execution signals: $EXEC_COUNT" >> "$OUT"
echo "Bridge signals: $BRIDGE_COUNT" >> "$OUT"
echo "Intake signals: $INTAKE_COUNT" >> "$OUT"
echo "Preparation signals: $PREP_COUNT" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Classification logic" >> "$OUT"

if [ "$BRIDGE_COUNT" -eq 0 ] && [ "$EXEC_COUNT" -gt 0 ] && [ "$GOV_COUNT" -gt 0 ]; then
  CLASS="STRUCTURAL_GAP_CONFIRMED"
elif [ "$BRIDGE_COUNT" -gt 0 ] && [ "$PREP_COUNT" -eq 0 ]; then
  CLASS="FRAGMENTED_BRIDGE"
elif [ "$BRIDGE_COUNT" -gt 0 ] && [ "$PREP_COUNT" -gt 0 ]; then
  CLASS="PARTIAL_BRIDGE_WITH_PREP"
else
  CLASS="INSUFFICIENT_SIGNAL"
fi

echo "CLASSIFICATION: $CLASS" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Next action determination" >> "$OUT"

if [ "$CLASS" = "STRUCTURAL_GAP_CONFIRMED" ]; then
  NEXT="DEFINE EXPLICIT GOVERNANCE→EXECUTION BRIDGE STRUCTURE"
elif [ "$CLASS" = "FRAGMENTED_BRIDGE" ]; then
  NEXT="CONSOLIDATE FRAGMENTED PATHS INTO SINGLE STRUCTURE"
elif [ "$CLASS" = "PARTIAL_BRIDGE_WITH_PREP" ]; then
  NEXT="FORMALIZE BRIDGE CONTRACT (NO EXECUTION YET)"
else
  NEXT="MANUAL REVIEW REQUIRED"
fi

echo "NEXT ACTION: $NEXT" >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"
echo "CLASSIFICATION: $CLASS"

