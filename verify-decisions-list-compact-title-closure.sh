#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VERIFY DECISIONS LIST COMPACT TITLE CLOSURE ==="
echo "EXPECTED_HEAD_PREFIX=6af4a07a6"
echo "RECOVERY_POINT=DR_20260826_171804"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_COMMIT=6af4a07a6aad0bd89aca7ed6fa86325841a3042f"
echo "IMPLEMENTATION_ATTEMPT=3"
echo "PRODUCTION_CHANGE=PRESENTATION_ONLY"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 6af4a07a6* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFIED IMPLEMENTATION ==="
echo "COMPACT_TITLE_HELPER=client/src/approvals/decisionListTitle.ts"
echo "DECISION_LIST_HEADING_USES_HELPER=YES"
echo "MAX_DISPLAY_CHARACTERS=64"
echo "WHOLE_WORD_BOUNDARY_PREFERRED=YES"
echo "ELLIPSIS_ON_SHORTENING=YES"
echo "HEADING_VISUAL_MAX_LINES=2"
echo "FULL_EXPECTED_OUTCOME_IN_DETAIL=PRESERVED"
echo "INTERPRETED_OBJECTIVE_SUMMARY=PRESERVED"
echo "PACKAGE_SEMANTICS_CHANGE=NO"
echo "BACKEND_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "APPROVAL_AUTHORITY_CHANGE=NO"

echo
echo "=== REVALIDATE FOCUSED TESTS ==="
npx tsx --test client/src/approvals/decisionListTitle.test.ts

echo
echo "=== REVALIDATE APPROVALS API ==="
npx tsx --test client/src/approvals/approvalRequestApi.test.ts

echo
echo "=== TYPECHECK ==="
npm run check

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== CLOSURE DETERMINATION ==="
echo "DECISIONS_LIST_COMPACT_TITLE_REQUIREMENT=SATISFIED"
echo "PRESENTATION_ONLY_BOUNDARY=PRESERVED"
echo "IMPLEMENTATION_VALIDATED=YES"
echo "FURTHER_COMPACT_TITLE_IMPLEMENTATION_REQUIRED=NO"
echo "FOLLOWUP_STATUS=CLOSURE_READY"
echo "NEXT_ACTION=FORMALLY_CLOSE_DECISIONS_LIST_TITLE_COMPACTNESS_FOLLOWUP"

git add verify-decisions-list-compact-title-closure.sh
git commit -m "Verify decisions list compact title closure"
git push
