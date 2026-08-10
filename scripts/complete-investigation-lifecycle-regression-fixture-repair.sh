#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== COMPLETE INVESTIGATION LIFECYCLE REGRESSION FIXTURE REPAIR ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY KNOWN FAILED IMPLEMENTATION SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/guard-ollama-response-contract\.sh$|^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$|^scripts/complete-investigation-lifecycle-regression-fixture-repair\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected files exist before repair:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_FAILED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== PATCH REMAINING MOCK RESPONSES AND STRUCTURED KEY EXPECTATION ==="
python3 <<'PY'
from pathlib import Path
import re

targets = [
    Path("scripts/utils/ollamaChat.selected-context-observer.test.ts"),
    Path("scripts/utils/ollamaChat.validation-seed.test.ts"),
]

inserted = 0

for path in targets:
    text = path.read_text()

    # Catch remaining JSON.stringify response objects regardless of whitespace
    # or whether the object is introduced indirectly inside a Response body.
    starts = list(re.finditer(r'JSON\.stringify\(\s*\{', text))
    offset = 0

    for match in starts:
        start = match.end() + offset
        current = text

        # Inspect a bounded portion of this response object. If lifecycle is
        # already present, leave it untouched.
        window = current[start:start + 1200]
        if "investigationLifecycle" in window:
            continue

        current = (
            current[:start]
            + "\n          investigationLifecycle: null,"
            + current[start:]
        )
        text = current
        offset += len("\n          investigationLifecycle: null,")
        inserted += 1

    path.write_text(text)

status_path = Path(
    "scripts/utils/ollamaChat.explanation-status.test.ts"
)
text = status_path.read_text()

old = """      "evidence",
      "durableInterpretation","""
new = """      "evidence",
      "investigationLifecycle",
      "durableInterpretation","""

if old in text:
    text = text.replace(old, new, 1)
elif '"investigationLifecycle"' not in text:
    raise SystemExit(
        "STOP: could not safely locate Explanation Status structured-key expectation."
    )

status_path.write_text(text)

print(f"REMAINING_FIXTURE_INSERTIONS={inserted}")
PY

echo
echo "=== VERIFY SELECTED-CONTEXT FIXTURES NOW CARRY NULL LIFECYCLE ==="
selected_count="$(
  grep -c 'investigationLifecycle: null' \
    scripts/utils/ollamaChat.selected-context-observer.test.ts ||
  true
)"
echo "SELECTED_CONTEXT_LIFECYCLE_FIXTURE_COUNT=$selected_count"

if [[ "$selected_count" -lt 4 ]]; then
  echo "STOP: expected at least four selected-context lifecycle fixtures."
  exit 2
fi

echo
echo "=== VERIFY VALIDATION-SEED FIXTURES NOW CARRY NULL LIFECYCLE ==="
seed_count="$(
  grep -c 'investigationLifecycle: null' \
    scripts/utils/ollamaChat.validation-seed.test.ts ||
  true
)"
echo "VALIDATION_SEED_LIFECYCLE_FIXTURE_COUNT=$seed_count"

if [[ "$seed_count" -lt 2 ]]; then
  echo "STOP: expected at least two validation-seed lifecycle fixtures."
  exit 2
fi

echo
echo "=== VERIFY STRUCTURED KEY EXPECTATION INCLUDES LIFECYCLE ==="
grep -n -A8 -B2 \
  '"explanationStatus"' \
  scripts/utils/ollamaChat.explanation-status.test.ts |
  head -n 30 || true

if ! grep -q '"investigationLifecycle"' \
  scripts/utils/ollamaChat.explanation-status.test.ts
then
  echo "STOP: structured key expectation still lacks investigationLifecycle."
  exit 2
fi

echo "STRUCTURED_KEY_EXPECTATION_RECONCILED"

echo
echo "=== TARGET PREVIOUSLY FAILING TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== TARGETED INVESTIGATION LIFECYCLE CONTRACT ==="
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
echo "=== VERIFY NO GENERATION POLICY CHANGE ==="
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
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"
echo "OLLAMA_FETCH_INVOCATION_COUNT=$invocation_count"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation."
  exit 2
fi
echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/guard-ollama-response-contract\.sh$|^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$|^scripts/complete-investigation-lifecycle-regression-fixture-repair\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: files outside authorized implementation + regression-fixture surface changed:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_REGRESSION_FIXTURE_REPAIR_COMPLETE"
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
  scripts/complete-investigation-lifecycle-regression-fixture-repair.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle response contract"
git push
