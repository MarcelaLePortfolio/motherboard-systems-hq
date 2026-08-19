#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET='scripts/utils/ollamaChat.ts'
BASELINE='09342faa'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=cbf64203' \
  'ISSUE_RESOLVED=NO' \
  'MODE=BOUNDED_RUNTIME_REVERT' \
  'REVERT_SCOPE=ONE_FILE' \
  'REVERT_SOURCE_COMMIT=09342faa' \
  'TARGET_FILE=scripts/utils/ollamaChat.ts' \
  'FULL_BRANCH_RESET=NO'

git show "${BASELINE}:${TARGET}" > /tmp/ollamaChat.pre-fix.ts

cat > "$TARGET" << 'TARGET_EOF'
__OLLAMACHAT_BASELINE_PLACEHOLDER__
TARGET_EOF

python3 - << 'PY'
from pathlib import Path

target = Path("scripts/utils/ollamaChat.ts")
baseline = Path("/tmp/ollamaChat.pre-fix.ts").read_text()

if "__OLLAMACHAT_BASELINE_PLACEHOLDER__" not in target.read_text():
    raise SystemExit("REVERT_PLACEHOLDER_NOT_FOUND")

target.write_text(baseline)
PY

printf '\n=== VERIFY EXACT BASELINE MATCH ===\n'
if cmp -s "$TARGET" /tmp/ollamaChat.pre-fix.ts; then
  echo 'OLLAMACHAT_MATCHES_09342FAA=YES'
else
  echo 'OLLAMACHAT_MATCHES_09342FAA=NO'
  exit 1
fi

printf '\n=== REVERT DIFF ===\n'
git diff -- "$TARGET"

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'VALIDATOR_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'RETRY_CHANGE=NO' \
  'TIMEOUT_CHANGE=NO' \
  'PERSISTENCE_CHANGE=NO' \
  'DIAGNOSTIC_HISTORY_RETAINED=YES' \
  'NEXT_ACTION=RESTART_BACKEND_AND_REVALIDATE_STABLE_PRE_FIX_RUNTIME'

printf '\n=== WORKTREE ===\n'
git status --short
