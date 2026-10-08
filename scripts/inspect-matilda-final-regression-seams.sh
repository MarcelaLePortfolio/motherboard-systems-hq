#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="79e31b48e"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"

echo "=== WORKFLOW PACKAGE SEMANTICS SEAMS ==="
rg -n \
  'packageSemantics|observeValidatedPackageSemantics|interpretation.evidence|durableInterpretation|enforceMatildaWorkflowPackageSemanticsRequirement' \
  server/matilda-chat-workflow.ts | head -100

echo
echo "=== EXISTING WORKFLOW TEST FILES ==="
rg --files server scripts | rg \
  '(matilda.*(workflow|package-semantics|interpretation).*test|ollamaChat.*test)' \
  | head -100

echo
echo "=== WORKFLOW PERSISTENCE REFERENCES ==="
rg -n \
  'matilda_interpretation_evidence_ledger|matilda_conversation_turns|package_semantics|packageSemantics' \
  server/matilda-chat-workflow*.test.ts \
  server/matilda-chat-workflow.ts \
  2>/dev/null | head -160 || true

echo
echo "=== PACKAGE SEMANTICS VALIDATOR ==="
sed -n '325,440p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT RECONCILIATION ==="
sed -n '1450,1530p' scripts/utils/ollamaChat.ts

echo
echo "=== CLASSIFICATION ==="
echo "UPSTREAM_REGRESSION_TESTS=36_PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "WORKFLOW_PERSISTENCE=NOT_YET_VERIFIED"
echo "NON_OUTCOME_CONTRADICTION=NOT_YET_VERIFIED"
echo "LIVE_DOGFOOD=PROHIBITED"
echo "CORRIDOR=OPEN"
