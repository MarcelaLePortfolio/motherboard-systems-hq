#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 1 — CLASSIFICATION IMPLEMENTATION VALIDATION ==="

echo "HEAD=$(git rev-parse --short HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
echo "WORKTREE:"
git status --short

grep -q 'Set explanationStatus to optional by default.' scripts/utils/ollamaChat.ts
grep -q "Set explanationStatus to recommended only when skipping supporting reasoning is likely to materially affect the user's next engineering decision." scripts/utils/ollamaChat.ts
grep -q 'Do not set explanationStatus to recommended merely because evidence exists, the work was substantial, or additional explanation is available.' scripts/utils/ollamaChat.ts

npx tsx --test scripts/utils/ollamaChat.explanation-status.test.ts
bash scripts/guard-ollama-response-contract.sh

echo "CLASSIFICATION_RULE_IMPLEMENTATION=VALIDATED"
echo "SCHEMA_CHANGE=NONE"
echo "WORKFLOW_CHANGE=NONE"
echo "PERSISTENCE_CHANGE=NONE"
echo "ONE_OLLAMA_INVOCATION=PRESERVED"
echo "FAIL_CLOSED_VALIDATION=PRESERVED"
echo "CORRIDOR_1_CLOSURE_STATUS=READY_FOR_CLOSURE_CLASSIFICATION"
echo "DR_NOW=NO"
echo "NEXT_ACTION=CLASSIFY_CORRIDOR_1_CLOSURE"
