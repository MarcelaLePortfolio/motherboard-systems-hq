#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RESET PARTIAL PACKAGE SEMANTICS IMPLEMENTATION ==="
echo "AUTHORIZED_BASELINE=ee2d2495"
echo "FAILED_IMPLEMENTATION_ATTEMPT=1"
echo "FAILURE_CLASS=EDIT_SCRIPT_PATTERN_MISMATCH"
echo "ACTION=RESTORE_ONLY_PARTIALLY_EDITED_AUTHORIZED_SOURCE_FILES"

git restore -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-draft-synthesis-runtime.ts

echo
echo "=== VERIFY RESET ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-draft-synthesis-runtime.ts
then
  echo "AUTHORIZED_SOURCE_RESET=FAIL"
  exit 1
fi

echo "AUTHORIZED_SOURCE_RESET=PASS"
echo "IMPLEMENTATION_AUTHORIZATION_REMAINS_ACTIVE=YES"
echo "NEXT_ACTION=REIMPLEMENT_FROM_CLEAN_SOURCE_USING_EXACT_CURRENT_BOUNDARIES"
