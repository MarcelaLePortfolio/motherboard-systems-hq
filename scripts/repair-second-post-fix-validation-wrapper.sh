#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="scripts/run-second-post-fix-validation.sh"

cat > "$TARGET" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="scripts/.run-dashboard-second-post-fix-validation.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_SECOND_POST_FIX_VALIDATION_RESULT.txt"

cp "$SOURCE" "$TMP"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/.run-dashboard-second-post-fix-validation.ts")
text = path.read_text()

if "const UNSEEDED_RUNS = 10;" not in text:
    raise SystemExit("UNSEEDED_RUNS_ANCHOR_NOT_FOUND")
if "const CONTROLLED_RUNS = 10;" not in text:
    raise SystemExit("CONTROLLED_RUNS_ANCHOR_NOT_FOUND")

text = text.replace("const UNSEEDED_RUNS = 10;", "const UNSEEDED_RUNS = 1;", 1)
text = text.replace("const CONTROLLED_RUNS = 10;", "const CONTROLLED_RUNS = 0;", 1)
path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'VALIDATION_ATTEMPT=2' \
  'SECOND_POST_FIX_VALIDATION_AUTHORIZED=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'RETRY_COUNT_WITHIN_WORKFLOW=0' \
  'DATABASE_WRITE=NO' \
  'ADDITIONAL_PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'TIMEOUT_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO'

set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

rm -f "$TMP"

printf '\n=== SECOND POST-FIX VALIDATION RESULT ===\n'
tail -120 "$RESULT"

printf '\n=== FAILURE CONTAINMENT ===\n'
printf '%s\n' \
  "RUN_STATUS=$RUN_STATUS" \
  'VALIDATION_ATTEMPT=2' \
  'AUTHORIZED_INVOCATIONS_USED=1_OF_1' \
  'THIRD_INVOCATION_STARTED=NO' \
  'THIRD_INVOCATION_AUTHORIZED=NO' \
  'ISSUE_RESOLVED=NO' \
  'NEXT_ACTION=CLASSIFY_SECOND_POST_FIX_VALIDATION_RESULT_BEFORE_ANY_FURTHER_ACTION'

exit "$RUN_STATUS"
SCRIPT

chmod +x "$TARGET"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=aec61616' \
  'ACTION=REPAIR_ZERO_BYTE_SECOND_VALIDATION_WRAPPER' \
  'ROOT_CAUSE=AUTHORIZED_VALIDATION_WRAPPER_WAS_ZERO_BYTES' \
  'SECOND_VALIDATION_INVOCATION_PREVIOUSLY_STARTED=NO' \
  'AUTHORIZATION_REMAINS_UNCONSUMED=YES' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== WRAPPER VERIFICATION ===\n'
wc -c "$TARGET"
head -20 "$TARGET"

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'VALIDATION_RUN_STARTED=NO' \
  'VALIDATOR_CHANGE=NO' \
  'TIMEOUT_CHANGE=NO' \
  'NEXT_ACTION=RUN_REPAIRED_WRAPPER_UNDER_EXISTING_SECOND_VALIDATION_AUTHORIZATION'

git status --short
git add -- scripts/run-second-post-fix-validation.sh scripts/repair-second-post-fix-validation-wrapper.sh
git commit -m "Repair second post fix validation wrapper"
git push
