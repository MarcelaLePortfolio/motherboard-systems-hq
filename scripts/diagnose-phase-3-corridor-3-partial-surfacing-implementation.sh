#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — PARTIAL IMPLEMENTATION DIAGNOSIS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 86f1189e HEAD

echo "HEAD=$(git rev-parse --short HEAD)"
echo "WORKTREE:"
git status --short

if grep -Fq 'Use explanationStatus to govern the amount of supporting reasoning in reply without exposing explanationStatus itself as a user-visible label.' scripts/utils/ollamaChat.ts; then
  echo "PROMPT_SURFACING_CHANGE_PRESENT=YES"
else
  echo "PROMPT_SURFACING_CHANGE_PRESENT=NO"
fi

if grep -Fq 'When explanationStatus is optional, keep reply concise and include only the supporting reasoning needed for the immediate interaction.' scripts/utils/ollamaChat.ts; then
  echo "OPTIONAL_SURFACING_RULE_PRESENT=YES"
else
  echo "OPTIONAL_SURFACING_RULE_PRESENT=NO"
fi

if grep -Fq "When explanationStatus is recommended, keep the concise answer first, then include enough supporting reasoning to preserve any material architectural boundary, implementation boundary, uncertainty, tradeoff, or evidence interpretation that could change the user's next engineering decision." scripts/utils/ollamaChat.ts; then
  echo "RECOMMENDED_SURFACING_RULE_PRESENT=YES"
else
  echo "RECOMMENDED_SURFACING_RULE_PRESENT=NO"
fi

if grep -Fq 'Do not add a visible Reasoning Status, Optional, or Recommended label merely because explanationStatus is present.' scripts/utils/ollamaChat.ts; then
  echo "NO_VISIBLE_STATUS_LABEL_RULE_PRESENT=YES"
else
  echo "NO_VISIBLE_STATUS_LABEL_RULE_PRESENT=NO"
fi

if [[ -f scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts ]]; then
  echo "TARGETED_TEST_FILE_PRESENT=YES"
  npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
else
  echo "TARGETED_TEST_FILE_PRESENT=NO"
fi

bash scripts/guard-ollama-response-contract.sh
git diff --check

echo "DIAGNOSIS=AUTHORIZED_IMPLEMENTATION_WAS_PARTIALLY_APPLIED_BEFORE_IDEMPOTENCY_STOP"
echo "PRODUCTION_COMMIT_CREATED=NO"
echo "DR_NOW=NO"
echo "NEXT_ACTION=VALIDATE_AND_COMMIT_EXISTING_AUTHORIZED_SURFACING_CHANGES_IF_WORKTREE_CONTAINS_ONLY_CLASSIFIED_SURFACE"
