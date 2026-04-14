#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step17_ui_expansion_candidates.txt"

{
  echo "PHASE 486 — STEP 17"
  echo "UI CONSUMPTION EXPANSION CANDIDATES"
  echo
  echo "OBJECTIVE"
  echo
  echo "Identify next safe UI-only consumption surfaces for expansion"
  echo "without violating backend freeze or introducing logic."
  echo
  echo "CURRENT VERIFIED SURFACE"
  echo
  echo "• Governance Trace panel (PASS)"
  echo
  echo "AVAILABLE PANELS (FROM EXISTING UI STRUCTURE)"
  echo
  echo "1. Admission Panel"
  echo "   • report.admissionDecision"
  echo "   • report.denialReasons"
  echo "   • governanceExplanation"
  echo
  echo "2. Execution Panel"
  echo "   • report.generatedRequest.tasks"
  echo "   • report.traversalOrder (unused in UI)"
  echo
  echo "3. Outcome Panel"
  echo "   • report.taskOutcomes"
  echo "   • report.finalDemoResult"
  echo
  echo "4. Request Panel"
  echo "   • report.requestId"
  echo "   • report.requestSummary"
  echo
  echo "EXPANSION RULES (RE-ASSERTED)"
  echo
  echo "Allowed:"
  echo "• Re-surface unused existing fields"
  echo "• Improve structural clarity"
  echo "• Add passive display blocks"
  echo
  echo "Forbidden:"
  echo "• Deriving new meaning"
  echo "• Recomputing values"
  echo "• Adding logic branches"
  echo "• Introducing async behavior"
  echo
  echo "LOWEST-RISK NEXT TARGET"
  echo
  echo "Execution Panel Expansion"
  echo
  echo "Reason:"
  echo "• traversalOrder exists but is not rendered"
  echo "• purely additive visibility"
  echo "• zero governance or approval risk"
  echo "• no interpretation required"
  echo
  echo "NEXT STEP"
  echo
  echo "Phase 486 Step 18 — define passive render spec for traversalOrder in Execution panel"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"
