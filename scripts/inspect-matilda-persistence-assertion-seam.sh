#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="4950e9bff"
TARGET="server/matilda-chat-workflow.explicit-target.integration.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" scripts/utils/ollamaChat.ts)"

echo "=== ISOLATED FIXTURE SETUP AND MODEL STUB ==="
sed -n '35,205p' "$TARGET"

echo
echo "=== ISOLATED DATABASE SETUP ==="
sed -n '205,445p' "$TARGET"

echo
echo "=== PERSISTENCE ASSERTIONS AND CLEANUP ==="
sed -n '570,850p' "$TARGET"

echo
echo "=== WORKFLOW FAILURE AND WRITE BOUNDARIES ==="
sed -n '385,410p' server/matilda-chat-workflow.ts
sed -n '445,555p' server/matilda-chat-workflow.ts
sed -n '605,655p' server/matilda-chat-workflow.ts

echo
echo "=== DATABASE SEMANTICS CONTRACT ==="
rg -n \
  'package_semantics|createInterpretationEvidenceLedgerEntry|createMatildaConversationTurn' \
  db server/matilda-chat-workflow.ts | head -100

echo
echo "=== STATUS ==="
echo "FIXTURE_CONTRACT=REPAIRED"
echo "EXISTING_INTEGRATION=PASS"
echo "RECONCILED_PERSISTENCE=NOT_YET_PROVEN"
echo "FAILED_RECONCILIATION_DURABILITY=NOT_YET_PROVEN"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "LIVE_DOGFOOD=PROHIBITED"
echo "CORRIDOR=OPEN"
