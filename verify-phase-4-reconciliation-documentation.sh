#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
DOC="docs/checkpoints/PHASE_4_LIVE_STATE_RECONCILIATION_20260922.md"

echo "============================================================"
echo " PHASE 4 RECONCILIATION DOCUMENTATION — VERIFY PERSISTENCE"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"

echo
echo "=== A. FILE EXISTENCE ==="
if test -f "$DOC"; then
  echo "DOCUMENT_EXISTS=YES"
else
  echo "DOCUMENT_EXISTS=NO"
fi

echo
echo "=== B. TRACKING STATUS ==="
if git ls-files --error-unmatch "$DOC" >/dev/null 2>&1; then
  echo "DOCUMENT_TRACKED=YES"
else
  echo "DOCUMENT_TRACKED=NO"
fi

echo
echo "=== C. HEAD CONTAINS DOCUMENT ==="
if git cat-file -e "HEAD:$DOC" 2>/dev/null; then
  echo "DOCUMENT_PRESENT_IN_HEAD=YES"
  git log -1 --oneline -- "$DOC"
else
  echo "DOCUMENT_PRESENT_IN_HEAD=NO"
fi

echo
echo "=== D. REMOTE BRANCH CONTAINS DOCUMENT ==="
if git cat-file -e "origin/$BRANCH:$DOC" 2>/dev/null; then
  echo "DOCUMENT_PRESENT_ON_REMOTE=YES"
else
  echo "DOCUMENT_PRESENT_ON_REMOTE=NO"
fi

echo
echo "=== E. VERIFY REQUIRED RECONCILIATION MARKERS IF PRESENT ==="
if test -f "$DOC"; then
  grep -n -E \
    'PHASE_4_STATUS=CLOSED|CORRIDOR_2_GOVERNED_EXECUTION_HANDOFF_STATUS=CLOSED|SCHEDULER_RUNTIME_TO_GOVERNED_EXECUTION_HANDOFF=IMPLEMENTED|NEXT_ACTION=READ_ONLY_PARENT_SEQUENCE_SUCCESSOR_RECONCILIATION|NEW_IMPLEMENTATION_AUTHORIZED=NO' \
    "$DOC" || true
fi

echo
echo "============================================================"
echo " VERIFICATION COMPLETE — STOP HERE"
echo "============================================================"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "NEXT_ACTION=CLASSIFY_WHETHER_RECONCILIATION_DOCUMENT_REQUIRES_CREATION_OR_IS_ALREADY_DURABLE"
echo "CLEAR_STOPPING_POINT=YES"
