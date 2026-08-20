#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="scripts/.run-dashboard-post-fix-single-validation.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt"

cp "$SOURCE" "$TMP"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/.run-dashboard-post-fix-single-validation.ts")
text = path.read_text()
text = text.replace("const UNSEEDED_RUNS = 10;", "const UNSEEDED_RUNS = 1;", 1)
text = text.replace("const CONTROLLED_RUNS = 10;", "const CONTROLLED_RUNS = 0;", 1)
path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=cca421f1' \
  'ISSUE_RESOLVED=NO' \
  'POST_FIX_VALIDATION_AUTHORIZED=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'RETRY_COUNT=0' \
  'DATABASE_WRITE=NO' \
  'ADDITIONAL_PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO'

set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

rm -f "$TMP"

printf '\n=== POST-FIX VALIDATION RESULT ===\n'
grep -n -A50 -B8 \
  '"accepted"\|"failureClass"\|"errorMessage"\|"parsedSupportReferences"' \
  "$RESULT" || true

printf '\n=== RAW PATH SUFFIX CHECK ===\n'
python3 - << 'PY'
from pathlib import Path
import json
import re

path = Path("docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt")
text = path.read_text()

match = re.search(
    r'\{\n\s*"arm": "UNSEEDED".*?\n\}',
    text,
    re.S,
)
if not match:
    print("RUN_RECORD_PARSE=NOT_FOUND")
    raise SystemExit(0)

record = json.loads(match.group(0))
refs = record.get("parsedSupportReferences") or []

project_refs = [
    ref for ref in refs
    if ref.get("type") == "project_context_excerpt"
]

bad = [
    ref for ref in project_refs
    if re.search(r":\d+$", str(ref.get("relativePath", "")))
]

print(f"PROJECT_CONTEXT_REFERENCE_COUNT={len(project_refs)}")
print(f"RELATIVE_PATH_WITH_COLON_LINE_SUFFIX_COUNT={len(bad)}")
print(
    "RAW_RELATIVE_PATH_PRESENTATION="
    + ("PASS" if not bad else "FAIL")
)
PY

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  "RUN_STATUS=$RUN_STATUS" \
  'AUTHORIZED_INVOCATIONS_USED=1_OF_1' \
  'ADDITIONAL_OLLAMA_INVOCATIONS_AUTHORIZED=NO' \
  'ISSUE_RESOLUTION_NOT_YET_DECLARED=YES' \
  'NEXT_ACTION=CLASSIFY_POST_FIX_VALIDATION_RESULT_BEFORE_ANY_VISIBLE_DASHBOARD_TEST'

git status --short
