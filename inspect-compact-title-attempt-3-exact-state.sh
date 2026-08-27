#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT COMPACT TITLE ATTEMPT 3 EXACT STATE ==="
echo "EXPECTED_HEAD_PREFIX=22d60b70c"
echo "RECOVERY_POINT=DR_20260826_171804"
echo "MODE=COLLABORATION"
echo "ATTEMPT_1=FAILED_CSS_IMPORT_TEST_BOUNDARY"
echo "ATTEMPT_2=FAILED_HELPER_EXACT_PATTERN_MATCH"
echo "ATTEMPT_3_STARTED=NO"
echo "PRODUCTION_CHANGE_COMMITTED=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 22d60b70c* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== EXACT WORKSPACE HELPER REGION ==="
sed -n '40,125p' client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== EXACT EXTRACTED HELPER MODULE ==="
if [[ -f client/src/approvals/decisionListTitle.ts ]]; then
  cat client/src/approvals/decisionListTitle.ts
else
  echo "decisionListTitle.ts=ABSENT"
fi

echo
echo "=== EXACT TEST IMPORT AND CONTENT ==="
if [[ -f client/src/approvals/decisionListTitle.test.ts ]]; then
  sed -n '1,240p' client/src/approvals/decisionListTitle.test.ts
else
  echo "decisionListTitle.test.ts=ABSENT"
fi

echo
echo "=== EXACT CSS DIFF ==="
git diff -- client/src/approvals/approvals-workspace.css

echo
echo "=== EXACT SOURCE DIFF ==="
git diff -- client/src/approvals/ApprovalsWorkspace.tsx

echo
echo "=== REGEX REPRESENTATION CHECK ==="
python3 - << 'PY'
from pathlib import Path

for filename in [
    "client/src/approvals/ApprovalsWorkspace.tsx",
    "client/src/approvals/decisionListTitle.ts",
]:
    path = Path(filename)
    if not path.exists():
        print(f"{filename}=ABSENT")
        continue

    source = path.read_text()
    for line in source.splitlines():
        if "replace(" in line and "s+" in line:
            print(f"{filename}: {line!r}")
PY

echo
echo "=== ATTEMPT 3 BOUNDARY ==="
echo "CURRENT_PARTIAL_SOURCE_MUST_NOT_BE_COMMITTED_AS_IS=YES"
echo "THIRD_ATTEMPT_ALLOWED_ONLY_IF_HELPER_EXTRACTION_IMPORT_AND_REGEX_STATE_ARE_UNAMBIGUOUS=YES"
echo "IF_ATTEMPT_3_FAILS=RESET_AUTHORIZED_PARTIAL_FILES_TO_HEAD_22d60b70c"
echo "NEXT_ACTION=AUTHOR_ONE_FINAL_EXACT_STATE_REPAIR_OR_RESET"
echo "IMPLEMENTATION_STARTED_THIS_STEP=NO"

git diff --check

git add inspect-compact-title-attempt-3-exact-state.sh
git commit -m "Inspect compact title attempt three exact state"
git push
