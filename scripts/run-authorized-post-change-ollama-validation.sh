#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="scripts/.run-dashboard-post-change-single-validation.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_POST_CHANGE_OLLAMA_VALIDATION_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_GATE_COMMIT=d973fd71' \
  'ACTION=RUN_EXACT_POST_CHANGE_OLLAMA_VALIDATION' \
  'VALIDATION_AUTHORIZED=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'DASHBOARD_VISIBLE_SMOKE_TEST_AUTHORIZED=NO' \
  'ADDITIONAL_OLLAMA_INVOCATIONS_AUTHORIZED=NO'

if [[ ! -f "$SOURCE" ]]; then
  echo "VALIDATION_SOURCE_NOT_FOUND=$SOURCE"
  exit 1
fi

cp "$SOURCE" "$TMP"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/.run-dashboard-post-change-single-validation.ts")
text = path.read_text()

unseeded = text.count("const UNSEEDED_RUNS = 10;")
controlled = text.count("const CONTROLLED_RUNS = 10;")

if unseeded != 1 or controlled != 1:
    raise SystemExit(
        f"EXPECTED_RUN_COUNT_DECLARATIONS_NOT_FOUND:"
        f"UNSEEDED={unseeded}:CONTROLLED={controlled}"
    )

text = text.replace(
    "const UNSEEDED_RUNS = 10;",
    "const UNSEEDED_RUNS = 1;",
    1,
)
text = text.replace(
    "const CONTROLLED_RUNS = 10;",
    "const CONTROLLED_RUNS = 0;",
    1,
)

path.write_text(text)
PY

set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

rm -f "$TMP"

printf '\n=== POST-CHANGE VALIDATION RESULT ===\n'
grep -n -A50 -B8 \
  '"accepted"\|"failureClass"\|"errorMessage"\|"parsedSupportReferences"' \
  "$RESULT" || true

printf '\n=== SUPPORT REFERENCE SERIALIZATION CHECK ===\n'
python3 - << 'PY'
from pathlib import Path
import json
import re

path = Path(
    "docs/checkpoints/MATILDA_UI_503_POST_CHANGE_OLLAMA_VALIDATION_RESULT.txt"
)
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
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'PROMPT_CHANGED_DURING_VALIDATION=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO' \
  'ISSUE_RESOLUTION_NOT_YET_DECLARED=YES' \
  'NEXT_ACTION=CLASSIFY_POST_CHANGE_VALIDATION_RESULT'
