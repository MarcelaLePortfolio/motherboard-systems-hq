#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN POST-PROMOTION PRODUCTION BEHAVIORAL UNSEEDED SAMPLE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor a0370518 HEAD
test -z "$(git status --porcelain)"

runner="scripts/run-bounded-unseeded-experimental-presentation-validation.ts"
test -f "$runner"

output="artifacts/post-promotion-production-behavioral-unseeded-$(date +%Y%m%d_%H%M%S).log"
mkdir -p artifacts

active="$(ps aux | grep 'run-bounded-unseeded-experimental-presentation-validation.ts' | grep -v grep || true)"
if [[ -n "$active" ]]; then
  echo "STOP: behavioral validation runner already active."
  printf '%s\n' "$active"
  exit 2
fi

echo "=== EXECUTE 10 SEQUENTIAL UNSEEDED RUNS AGAINST PROMOTED DEFAULT ==="
echo "OUTPUT=$output"

npx tsx "$runner" | tee "$output"

echo "=== VERIFY COMPLETE RESULT ==="
grep -q '^GENERATION_SEED=ABSENT$' "$output"
grep -q '^RUN_COUNT=10$' "$output"
grep -q '^PRODUCTION_CHANGE=NONE$' "$output"

echo "POST_PROMOTION_BEHAVIORAL_SAMPLE=COMPLETE"
echo "RESULT_CAPTURE=$output"
echo "NEXT_ACTION=CLASSIFY_POST_PROMOTION_PRODUCTION_BEHAVIORAL_RESULTS"

git add "$output"
git commit -m "Capture post-promotion behavioral validation"
git push origin feature/support-source-references-runtime
