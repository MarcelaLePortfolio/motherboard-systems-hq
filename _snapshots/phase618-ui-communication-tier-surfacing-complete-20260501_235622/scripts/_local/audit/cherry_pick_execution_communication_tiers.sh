#!/bin/bash
set -euo pipefail

OUT="PHASE617_EXECUTION_COMMUNICATION_TIER_CHERRYPICK.txt"

cat > "$OUT" << 'REPORT'
PHASE 617 — EXECUTION COMMUNICATION TIER CHERRY-PICK

Scope:
Cherry-pick only the files directly related to execution communication tiers:
- Tier 1 → outcome
- Tier 2 → explanation
- Tier 3 → systemTrace

Do not use broad governance docs.
Do not invent CommunicationResult.
Do not patch UI yet.

────────────────────────────────

REPORT

append_file () {
  local file="$1"
  local start="$2"
  local end="$3"

  if [ -f "$file" ]; then
    {
      echo ""
      echo "===== $file ($start-$end) ====="
      sed -n "${start},${end}p" "$file"
    } >> "$OUT"
  fi
}

append_file "PHASE604_COMMUNICATION_CONTRACT_DEFINITION.txt" 1 90
append_file "PHASE605_RESPONSE_COMPILER_DESIGN_PLAN.txt" 1 90
append_file "PHASE605_RESPONSE_COMPILER_MODULE_ADDED.txt" 1 80
append_file "PHASE607_RESPONSE_COMPILER_STABLE.txt" 1 80
append_file "PHASE607_RESPONSE_COMPILER_ISOLATED_TEST.txt" 1 90
append_file "PHASE608_RESPONSE_COMPILER_PASSIVE_VERIFY.txt" 1 90
append_file "PHASE608_RESPONSE_COMPILER_PASSIVE_ACTIVE.txt" 1 80
append_file "PHASE609_PRESENTATION_AUTHORITY_PLAN.txt" 1 90
append_file "PHASE610_UI_SURFACE_INSPECTION_PLAN.txt" 1 90
append_file "PHASE613_UI_SURFACE_MAPPING_SUMMARY.txt" 1 80
append_file "PHASE614_TRIGGER_URL_FIX_VERIFICATION.txt" 1 80

{
  echo ""
  echo "────────────────────────────────"
  echo ""
  echo "FOCUSED IMPLEMENTATION SEARCH"
  echo ""
  grep -RIn "outcome_preview\|explanation_preview\|systemTrace\|outcome:\|explanation:" server app src public/js \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=.next \
    2>/dev/null || true
} >> "$OUT"

echo "✅ Wrote focused tier cherry-pick report to $OUT"
