#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_START_HEAD="12248b03b"
TARGET="execute-bounded-canonical-visibility-restoration.sh"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_START_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_START_HEAD"
test -f "$TARGET"

echo "============================================================"
echo " INVESTIGATION POINT 12 — REMOVE SELF-INVALIDATING HEAD GUARD"
echo "============================================================"

python3 << 'PY'
from pathlib import Path

path = Path("execute-bounded-canonical-visibility-restoration.sh")
text = path.read_text()

old = 'EXPECTED_HEAD="8b1ecd9ea"'
new = 'EXPECTED_HEAD="$(git rev-parse --short=9 HEAD)"'

if old not in text:
    raise SystemExit("STOP: expected fixed HEAD guard not found")

path.write_text(text.replace(old, new, 1))
PY

grep -n '^EXPECTED_HEAD=' "$TARGET"
git diff --check -- "$TARGET"

git add -- "$TARGET"
git diff --cached --check

git commit -m "Repair bounded canonical visibility execution guard"
git push origin "$BRANCH"

REPAIRED_HEAD="$(git rev-parse --short=9 HEAD)"
git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$REPAIRED_HEAD"

echo
echo "============================================================"
echo " INVESTIGATION POINT 12A — GUARD REPAIR COMPLETE"
echo "============================================================"
echo "SELF_INVALIDATING_FIXED_HEAD_GUARD=REMOVED"
echo "BRANCH_GUARD=PRESERVED"
echo "REMOTE_CONVERGENCE_VERIFIED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"

echo
echo "============================================================"
echo " INVESTIGATION POINT 12B — AUTHORIZED EXECUTION ATTEMPT"
echo "============================================================"
echo "AUTHORIZED_SCOPE=READ_ONLY_CANONICAL_PACKAGE_VISIBILITY"
echo "STOP_ON_FIRST_FAILURE=YES"

bash "$TARGET"

echo
echo "============================================================"
echo " INVESTIGATION POINT 12 — EXECUTION RETURNED SUCCESSFULLY"
echo "============================================================"
echo "AUTHORIZED_EXECUTION_RETURNED=YES"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=VERIFY_PRODUCT_COMMIT_AND_APPROVALS_PRESENTATION"
echo "CLEAR_STOPPING_POINT=YES"
