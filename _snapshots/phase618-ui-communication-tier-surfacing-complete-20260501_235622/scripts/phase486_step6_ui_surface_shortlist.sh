#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

INVENTORY="docs/phase486_step5_ui_surface_inventory.txt"
OUT="docs/phase486_step6_ui_surface_shortlist.txt"

{
  echo "PHASE 486 — STEP 6"
  echo "UI SURFACE SHORTLIST"
  echo
  echo "OBJECTIVE"
  echo
  echo "Reduce Step 5 inventory to a minimal shortlist of likely governance-trace"
  echo "render surfaces for consumption-only implementation."
  echo
  echo "INPUT"
  echo "$INVENTORY"
  echo

  echo "SHORTLIST METHOD"
  echo
  echo "Priority signals:"
  echo "• app/ src/ components/ surfaces"
  echo "• governance / trace / approval / reporting references"
  echo "• page/layout/component files"
  echo "• likely dashboard/operator console surfaces"
  echo

  echo "TOP MATCHES — DASHBOARD / OPERATOR / GOVERNANCE / TRACE"
  grep -E '(^\./|^app/|^src/|^components/).*([Gg]overnance|[Tt]race|[Aa]pproval|[Rr]eport|[Ii]ntake|[Dd]ashboard|[Oo]perator)' "$INVENTORY" | sort -u || true
  echo

  echo "TOP MATCHES — PAGE / LAYOUT / ROUTE SURFACES"
  grep -E '(^\./|^app/|^src/|^components/).*(page\.tsx|layout\.tsx|route\.ts)$' "$INVENTORY" | sort -u || true
  echo

  echo "TOP MATCHES — CONTRACT / RULE SHAPE REFERENCES"
  grep -E '(^\./|^app/|^src/|^components/).*(ruleId|evaluationResult|MATCH|NO_MATCH)' "$INVENTORY" | sort -u || true
  echo

  echo "DISTILLED CANDIDATE FILES"
  grep -Eo '(\./)?(app|src|components)/[^ :"]+\.(tsx|ts|jsx|js)' "$INVENTORY" | sort -u | \
    grep -Ei '(governance|trace|approval|report|intake|dashboard|operator|console|workspace|panel|contract|rule)' || true
  echo

  echo "MANUAL REVIEW TARGET"
  echo
  echo "Choose one UI file from the candidate list above that:"
  echo "• already renders dashboard/operator information"
  echo "• is nearest to existing visibility surfaces"
  echo "• requires no backend changes"
  echo "• can host a passive governance trace panel"
} > "$OUT"

echo "Wrote $OUT"

echo
echo "Preview:"
echo "----------------------------------------"
sed -n '1,220p' "$OUT"
