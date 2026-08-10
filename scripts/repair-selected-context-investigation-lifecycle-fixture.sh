#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REPAIR SELECTED-CONTEXT INVESTIGATION LIFECYCLE FIXTURE ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if ! git merge-base --is-ancestor f21b49b7 HEAD; then
  echo "STOP: expected topology checkpoint f21b49b7 is not an ancestor."
  exit 2
fi

echo
echo "=== REPAIR EXACT SHARED FIXTURE ==="
python3 <<'PY'
from pathlib import Path

path = Path(
    "scripts/utils/ollamaChat.selected-context-observer.test.ts"
)
text = path.read_text()

old_outer = '''      JSON.stringify({
          investigationLifecycle: null,
        response: JSON.stringify(structuredResponse),
      }),'''

new_outer = '''      JSON.stringify({
        response: JSON.stringify(structuredResponse),
      }),'''

if old_outer not in text:
    raise SystemExit(
        "STOP: expected misplaced outer lifecycle field not found."
    )

text = text.replace(old_outer, new_outer, 1)

old_inner = '''    supportSourceReferences,
    evidence: null,
    durableInterpretation:
      "The relevant implementation behavior is supported.",'''

new_inner = '''    supportSourceReferences,
    evidence: null,
    investigationLifecycle: null,
    durableInterpretation:
      "The relevant implementation behavior is supported.",'''

if old_inner not in text:
    raise SystemExit(
        "STOP: expected baseResponse insertion seam not found."
    )

text = text.replace(old_inner, new_inner, 1)
path.write_text(text)

print("SELECTED_CONTEXT_SHARED_FIXTURE_REPAIRED")
PY

echo
echo "=== VERIFY EXACT FIXTURE TOPOLOGY ==="
sed -n '9,50p' \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

if grep -n -A3 \
  'JSON.stringify({' \
  scripts/utils/ollamaChat.selected-context-observer.test.ts |
  head -n 5 |
  grep -q 'investigationLifecycle'
then
  echo "STOP: lifecycle remains in outer Ollama envelope."
  exit 2
fi

if ! sed -n '30,50p' \
  scripts/utils/ollamaChat.selected-context-observer.test.ts |
  grep -q 'investigationLifecycle: null'
then
  echo "STOP: lifecycle missing from baseResponse."
  exit 2
fi

echo "LIFECYCLE_FIELD_AT_CORRECT_STRUCTURED_RESPONSE_LAYER"

echo
echo "=== SELECTED-CONTEXT TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

echo
echo "=== PREVIOUSLY FAILING TEST GROUP ==="
npx tsx --test \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== INVESTIGATION LIFECYCLE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION WORKFLOW UNCHANGED ==="
if ! git diff --quiet -- server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow changed."
  git diff -- server/matilda-chat-workflow.ts
  exit 2
fi
echo "PRODUCTION_WORKFLOW_UNCHANGED"

echo
echo "=== VERIFY GENERATION POLICY UNCHANGED ==="
if git diff -- scripts/utils/ollamaChat.ts |
  grep -E '^\+.*\b(seed|temperature|top_p|top_k)\b'
then
  echo "STOP: unauthorized generation-policy change detected."
  exit 2
fi
echo "GENERATION_POLICY_UNCHANGED"

echo
echo "=== VERIFY ONE MODEL INVOCATION ==="
invocation_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts || true
)"
echo "OLLAMA_FETCH_INVOCATION_COUNT=$invocation_count"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation."
  exit 2
fi
echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_SELECTED_CONTEXT_FIXTURE_REPAIRED"
echo "INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_RESPONSE_CONTRACT_VALIDATED"
echo "FULL_OLLAMA_REGRESSION_SUITE_PASSED"
echo "PRODUCTION_WORKFLOW_UNCHANGED"
echo "GENERATION_POLICY_UNCHANGED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "IEL_EXTENSION_NOT_ADDED"
echo "DATABASE_CHANGE_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_IMPLEMENTATION"

git add \
  scripts/guard-ollama-response-contract.sh \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  scripts/repair-investigation-lifecycle-regression-fixtures.sh \
  scripts/complete-investigation-lifecycle-regression-fixture-repair.sh \
  scripts/finalize-investigation-lifecycle-regression-reconciliation.sh \
  scripts/repair-selected-context-investigation-lifecycle-fixture.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle response contract"
git push
