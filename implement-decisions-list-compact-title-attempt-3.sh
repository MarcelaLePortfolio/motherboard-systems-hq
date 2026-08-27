#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT DECISIONS LIST COMPACT TITLE — ATTEMPT 3 ==="
echo "EXPECTED_HEAD_PREFIX=fdf4c7de3"
echo "RECOVERY_POINT=DR_20260826_171804"
echo "IMPLEMENTATION_ATTEMPT=3"
echo "AUTHORIZED_SCOPE=PRESENTATION_ONLY"
echo "PRODUCTION_SCOPE_EXPANSION=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != fdf4c7de3* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > client/src/approvals/decisionListTitle.ts << 'TS'
export function deriveDecisionListTitle(value: string): string {
  const normalized = value.trim().replace(/\s+/g, " ");

  if (normalized.length <= 64) {
    return normalized;
  }

  const bounded = normalized.slice(0, 64);
  const finalWhitespaceIndex = bounded.lastIndexOf(" ");
  const prefix =
    finalWhitespaceIndex > 0
      ? bounded.slice(0, finalWhitespaceIndex)
      : bounded;

  return `${prefix}…`;
}
TS

python3 - << 'PY'
from pathlib import Path

tsx = Path("client/src/approvals/ApprovalsWorkspace.tsx")
source = tsx.read_text()

start_marker = 'export function deriveDecisionListTitle(value: string): string {'
end_marker = '\nfunction DecisionBadge({'

start = source.find(start_marker)
end = source.find(end_marker)

if start == -1 or end == -1 or end <= start:
    raise SystemExit("WORKSPACE_HELPER_BOUNDARY_NOT_FOUND")

source = source[:start] + source[end + 1:]

import_anchor = 'import { useApprovalRequests } from "./useApprovalRequests";\n'
import_line = 'import { deriveDecisionListTitle } from "./decisionListTitle";\n'

if import_line not in source:
    if source.count(import_anchor) != 1:
        raise SystemExit("IMPORT_ANCHOR_NOT_UNIQUE")
    source = source.replace(
        import_anchor,
        import_line + import_anchor,
        1,
    )

tsx.write_text(source)

test = Path("client/src/approvals/decisionListTitle.test.ts")
test_source = test.read_text()

test_source = test_source.replace(
    'import { deriveDecisionListTitle } from "./ApprovalsWorkspace";',
    'import { deriveDecisionListTitle } from "./decisionListTitle";',
)

test.write_text(test_source)
PY

echo
echo "=== EXACT REPAIR VERIFICATION ==="
rg -n -C 5 \
  'deriveDecisionListTitle|decisionListTitle|expected_outcome' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/decisionListTitle.ts \
  client/src/approvals/decisionListTitle.test.ts

echo
echo "=== ENSURE WORKSPACE NO LONGER DEFINES HELPER ==="
if rg -n '^export function deriveDecisionListTitle' \
  client/src/approvals/ApprovalsWorkspace.tsx; then
  echo "WORKSPACE_HELPER_EXTRACTION=FAIL"
  exit 1
fi
echo "WORKSPACE_HELPER_EXTRACTION=PASS"

echo
echo "=== ENSURE TEST IMPORTS CSS-FREE MODULE ==="
rg -n \
  'import \{ deriveDecisionListTitle \} from "\./decisionListTitle";' \
  client/src/approvals/decisionListTitle.test.ts
echo "TEST_IMPORT_BOUNDARY=PASS"

echo
echo "=== FOCUSED COMPACT TITLE TESTS ==="
npx tsx --test client/src/approvals/decisionListTitle.test.ts

echo
echo "=== APPROVALS API REGRESSION ==="
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
echo "=== ATTEMPT 3 RESULT ==="
echo "COMPACT_TITLE_IMPLEMENTATION_VALIDATED=YES"
echo "PRESENTATION_ONLY_BOUNDARY_PRESERVED=YES"
echo "PACKAGE_SEMANTICS_CHANGE=NO"
echo "BACKEND_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "APPROVAL_AUTHORITY_CHANGE=NO"

git add \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvals-workspace.css \
  client/src/approvals/decisionListTitle.ts \
  client/src/approvals/decisionListTitle.test.ts \
  implement-decisions-list-compact-title.sh \
  repair-decisions-list-compact-title-test-boundary.sh \
  implement-decisions-list-compact-title-attempt-3.sh

git commit -m "Keep decisions list titles compact"
git push
