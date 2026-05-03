#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="app/demo-runtime/page.tsx"
OUT="docs/phase486_step11_report_field_inventory.txt"

{
  echo "PHASE 486 — STEP 11"
  echo "REPORT FIELD INVENTORY FOR PASSIVE GOVERNANCE TRACE RENDER"
  echo
  echo "OBJECTIVE"
  echo
  echo "Inspect the remainder of the selected UI host and identify the exact"
  echo "report fields already available for passive governance trace rendering."
  echo
  echo "TARGET FILE"
  echo "$TARGET"
  echo
  echo "REPORT TYPE DEFINITION"
  sed -n '5,29p' "$TARGET"
  echo
  echo "RUNTIME RESULT SECTION (FULL REMAINDER)"
  sed -n '221,345p' "$TARGET"
  echo
  echo "REPORT FIELD REFERENCES IN FILE"
  grep -nE 'report\.[A-Za-z0-9_]+' "$TARGET" | sort -u || true
  echo
  echo "GENERATED REQUEST FIELD REFERENCES"
  grep -nE 'generatedRequest\.[A-Za-z0-9_]+' "$TARGET" | sort -u || true
  echo
  echo "DENIAL / ADMISSION / TRAVERSAL FIELD REFERENCES"
  grep -nE 'admissionDecision|denialReasons|traversalOrder|traversalState|finalDemoResult|taskOutcomes|requestSummary|requestId' "$TARGET" | sort -u || true
  echo
  echo "AVAILABLE GOVERNANCE-ADJACENT FIELDS (EXACT)"
  echo "• report.admissionDecision"
  echo "• report.denialReasons"
  echo "• report.generatedRequest.approved"
  echo "• report.generatedRequest.governanceEvaluated"
  echo "• report.generatedRequest.authorityOrderingValid"
  echo
  echo "TRACE SHAPE CHECK"
  echo
  if grep -qE 'ruleId|evaluationResult|rules\[' "$TARGET"; then
    echo "TRACE-FIELD-SIGNALS: PRESENT"
  else
    echo "TRACE-FIELD-SIGNALS: ABSENT"
  fi
  echo
  echo "INTERPRETATION RULE"
  echo
  echo "If rule-level trace fields are absent from the existing report object,"
  echo "the governance trace panel must render only exact available governance-adjacent"
  echo "fields and explicit NO DATA for rule-level trace details."
  echo
  echo "NO FABRICATION RULE"
  echo
  echo "Do not invent:"
  echo "• rules[]"
  echo "• ruleId"
  echo "• evaluationResult"
  echo "• per-rule reasoning entries"
  echo
  echo "NEXT STEP"
  echo
  echo "Define exact passive panel contents from existing report fields only."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
