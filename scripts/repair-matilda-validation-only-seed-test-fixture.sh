#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REPAIR MATILDA VALIDATION-ONLY SEED TEST FIXTURE ==="

if [[ "$(git rev-parse --short HEAD)" != "7262ab18" ]]; then
  echo "STOP: HEAD no longer matches validation-only generation-control checkpoint 7262ab18."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/utils/ollamaChat\.ts$|^\?\? scripts/utils/ollamaChat\.validation-seed\.test\.ts$|^\?\? scripts/implement-matilda-validation-only-seed-control\.sh$|^\?\? scripts/repair-matilda-validation-only-seed-test-fixture\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VALIDATION-SEED CONTRACT TESTS ==="
npx tsx --test scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== OLLAMA REGRESSION SUITE ==="
npx tsx --test \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.support-validation-observer.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION WORKFLOW SEED ABSENT ==="
if grep -n 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validation-only generation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== VERIFY CONTROL REMAINS SEED-ONLY ==="
diff_text="$(git diff -- scripts/utils/ollamaChat.ts)"

if printf '%s\n' "$diff_text" | grep -E '^\+.*\b(temperature|top_p|top_k)\b'; then
  echo "STOP: unauthorized sampling parameter introduced."
  exit 2
fi
echo "SEED_ONLY_CONTROL_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "MATILDA_VALIDATION_ONLY_SEED_CONTROL_VALIDATED"
echo "PRODUCTION_GENERATION_POLICY_UNCHANGED"
echo "NEXT_UNIT=VALIDATE_ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts \
  scripts/implement-matilda-validation-only-seed-control.sh \
  scripts/repair-matilda-validation-only-seed-test-fixture.sh

git commit -m "Add validation-only Matilda generation seed"
git push
