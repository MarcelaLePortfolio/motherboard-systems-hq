#!/usr/bin/env bash
set -euo pipefail

echo "=== CHECK POST-PROMOTION PRODUCTION BEHAVIORAL UNSEEDED SAMPLE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor cb17e327 HEAD

active="$(ps aux | grep 'run-bounded-unseeded-experimental-presentation-validation.ts' | grep -v grep || true)"
latest="$(ls -t artifacts/post-promotion-production-behavioral-unseeded-*.log 2>/dev/null | head -1 || true)"

if [[ -n "$active" ]]; then
  echo "VALIDATION_RUNNER_ACTIVE=YES"
  printf '%s\n' "$active"
else
  echo "VALIDATION_RUNNER_ACTIVE=NO"
fi

if [[ -z "$latest" ]]; then
  echo "RESULT_ARTIFACT=NONE"
  echo "VALIDATION_RESULT_COMPLETE=NO"
  exit 0
fi

echo "RESULT_ARTIFACT=$latest"
echo "RESULT_BYTES=$(wc -c < "$latest" | tr -d ' ')"

if grep -q '^RUN_COUNT=10$' "$latest"; then
  echo "VALIDATION_RESULT_COMPLETE=YES"
  grep -E '^(RUN_COUNT|SEMANTIC_PASSES|UNSUPPLIED_SUPPORT_FAILURES|FAIL_CLOSED_OR_RUNTIME_REJECTIONS|UNIQUE_EXACT_OUTPUT_FINGERPRINTS|GENERATION_SEED|PRODUCTION_CHANGE)=' "$latest"
  echo "NEXT_ACTION=CLASSIFY_POST_PROMOTION_PRODUCTION_BEHAVIORAL_RESULTS"
else
  echo "VALIDATION_RESULT_COMPLETE=NO"
  echo "NEXT_ACTION=WAIT_FOR_EXISTING_RUNNER_TO_COMPLETE_WITHOUT_STARTING_DUPLICATE"
fi
