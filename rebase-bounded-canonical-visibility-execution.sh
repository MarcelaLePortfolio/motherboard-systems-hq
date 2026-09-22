#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8b1ecd9ea"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

test -f execute-bounded-canonical-visibility-restoration.sh

python3 << 'PY'
from pathlib import Path

path = Path("execute-bounded-canonical-visibility-restoration.sh")
text = path.read_text()

old = 'EXPECTED_HEAD="9782bc278"'
new = 'EXPECTED_HEAD="8b1ecd9ea"'

if old not in text:
    raise SystemExit("STOP: expected stale execution HEAD guard not found")

text = text.replace(old, new, 1)
path.write_text(text)
PY

grep -n '^EXPECTED_HEAD=' execute-bounded-canonical-visibility-restoration.sh
git diff --check

echo "============================================================"
echo " INVESTIGATION POINT 11 — EXECUTION SCRIPT REBASED"
echo "============================================================"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_RETRY_PERFORMED=NO"
echo "EXECUTION_SCRIPT_REBASED_TO_CURRENT_HEAD=YES"
echo "NEXT_ACTION=RUN_REBASED_EXECUTION_SCRIPT_ONCE"
echo "CLEAR_STOPPING_POINT=YES"

git add -- execute-bounded-canonical-visibility-restoration.sh rebase-bounded-canonical-visibility-execution.sh
git commit -m "Rebase bounded canonical visibility execution guard"
git push origin feature/support-source-references-runtime
