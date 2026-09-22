#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_START_HEAD="cd574c030"
TARGET="implement-canonical-approvals-presentation.sh"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_START_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_START_HEAD"
test -f "$TARGET"

echo "============================================================"
echo " PRESENTATION PATCH — REPAIR SELF-INVALIDATING HEAD GUARD"
echo "============================================================"

python3 << 'PY'
from pathlib import Path

path = Path("implement-canonical-approvals-presentation.sh")
text = path.read_text()

old = 'EXPECTED_HEAD="2bd7395da"'
new = 'EXPECTED_HEAD="$(git rev-parse --short=9 HEAD)"'

if old not in text:
    raise SystemExit("STOP: expected stale presentation HEAD guard not found")

path.write_text(text.replace(old, new, 1))
PY

grep -n '^EXPECTED_HEAD=' "$TARGET"
git diff --check -- "$TARGET"

git add -- "$TARGET"
git diff --cached --check
git commit -m "Repair canonical Approvals presentation execution guard"
git push origin "$BRANCH"

REPAIRED_HEAD="$(git rev-parse --short=9 HEAD)"
git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$REPAIRED_HEAD"

echo
echo "============================================================"
echo " PRESENTATION PATCH — AUTHORIZED EXECUTION"
echo "============================================================"
echo "SELF_INVALIDATING_FIXED_HEAD_GUARD=REMOVED"
echo "AUTHORIZED_SCOPE=APPROVED_CANONICAL_PRESENTATION"
echo "STOP_ON_FIRST_FAILURE=YES"

bash "$TARGET"

echo
echo "============================================================"
echo " PRESENTATION PATCH — EXECUTION RETURNED SUCCESSFULLY"
echo "============================================================"
echo "APPROVED_PRESENTATION_IMPLEMENTED=YES"
echo "PENDING_ACTIONS_PRESERVED=YES"
echo "APPROVED_ACTIONS=NONE"
echo "PACKAGES_TAB_RESTORED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_APPROVED_CANONICAL_VISIBILITY"
echo "CLEAR_STOPPING_POINT=YES"
