#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase465_2_bridge_contract_extraction.txt"
mkdir -p docs

echo "PHASE 465.2 — BRIDGE CONTRACT EXTRACTION" > "$OUT"
echo "=========================================" >> "$OUT"
echo >> "$OUT"

echo "OBJECTIVE:" >> "$OUT"
echo "- Extract exact structural touchpoints forming the partial bridge" >> "$OUT"
echo "- NO mutation — evidence only" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Governance → Preparation adjacency" >> "$OUT"
rg -n -C 5 "governance.*prepare|prepare.*governance|policy.*ready|ready.*policy" src server 2>/dev/null >> "$OUT" || echo "no direct governance→prep adjacency found" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Preparation → Execution adjacency" >> "$OUT"
rg -n -C 5 "prepare.*execute|execute.*prepare|ready.*run|run.*ready|eligible.*execute" src server 2>/dev/null >> "$OUT" || echo "no direct prep→execution adjacency found" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Intake → Governance linkage" >> "$OUT"
rg -n -C 5 "intake.*governance|request.*policy|normalize.*evaluate|validate.*policy" src server 2>/dev/null >> "$OUT" || echo "no intake→governance linkage found" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Extract candidate bridge chain (multi-hop)" >> "$OUT"
rg -n -C 3 "intake|request|governance|policy|prepare|ready|execute|run" src server 2>/dev/null | head -n 200 >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — Detect missing link (gap analysis)" >> "$OUT"

HAS_GOV_PREP=$(rg -q "governance.*prepare|prepare.*governance" src server && echo 1 || echo 0)
HAS_PREP_EXEC=$(rg -q "prepare.*execute|execute.*prepare" src server && echo 1 || echo 0)

if [ "$HAS_GOV_PREP" -eq 1 ] && [ "$HAS_PREP_EXEC" -eq 1 ]; then
  GAP="NO_DIRECT_GAP_VISIBLE (CHAIN EXISTS)"
elif [ "$HAS_GOV_PREP" -eq 1 ] && [ "$HAS_PREP_EXEC" -eq 0 ]; then
  GAP="MISSING_PREP→EXECUTION_LINK"
elif [ "$HAS_GOV_PREP" -eq 0 ] && [ "$HAS_PREP_EXEC" -eq 1 ]; then
  GAP="MISSING_GOVERNANCE→PREP_LINK"
else
  GAP="FULL_CHAIN_DISCONNECTED"
fi

echo "GAP ANALYSIS: $GAP" >> "$OUT"
echo >> "$OUT"

echo "DECISION TARGET:" >> "$OUT"
echo "- Identify exact structural chain segments" >> "$OUT"
echo "- Confirm where bridge stops (prep boundary)" >> "$OUT"
echo "- Next: formalize contract WITHOUT enabling execution" >> "$OUT"
echo >> "$OUT"

echo "Wrote $OUT"
echo "GAP ANALYSIS: $GAP"

