#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REPAIR INVESTIGATION LIFECYCLE — REGRESSION FIXTURES ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY FAILED IMPLEMENTATION SURFACE ==="
allowed_existing='^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.investigation-lifecycle-contract\.test\.ts$|^scripts/guard-ollama-response-contract\.sh$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$'

unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE "$allowed_existing" |
  grep -vE '^scripts/utils/ollamaChat.*\.test\.ts$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected files exist before fixture repair:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_FAILED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== REPAIR MOCKED OLLAMA RESPONSE FIXTURES ==="
python3 <<'PY'
from pathlib import Path
import re

root = Path("scripts/utils")
files = sorted(root.glob("ollamaChat*.test.ts"))

pattern = re.compile(
    r'(response\s*:\s*JSON\.stringify\(\s*\{)(?!\s*investigationLifecycle\s*:)',
    re.MULTILINE,
)

changed_files = []
replacement_count = 0

for path in files:
    text = path.read_text()
    updated, count = pattern.subn(
        r'\1\n          investigationLifecycle: null,',
        text,
    )

    if count:
        path.write_text(updated)
        changed_files.append(str(path))
        replacement_count += count

print(f"REPAIRED_FIXTURE_COUNT={replacement_count}")

for name in changed_files:
    print(f"REPAIRED_FIXTURE_FILE={name}")

if replacement_count == 0:
    raise SystemExit(
        "STOP: no mocked Ollama JSON response fixtures were found for repair."
    )
PY

echo
echo "=== VERIFY REQUIRED NULL FIXTURES PRESENT ==="
fixture_count="$(
  grep -R \
    --include='ollamaChat*.test.ts' \
    -h \
    'investigationLifecycle: null' \
    scripts/utils |
  wc -l |
  tr -d ' '
)"

echo "INVESTIGATION_LIFECYCLE_NULL_FIXTURE_COUNT=$fixture_count"

if [[ "$fixture_count" -lt 1 ]]; then
  echo "STOP: repaired lifecycle fixtures were not found."
  exit 2
fi

echo
echo "=== TARGETED INVESTIGATION LIFECYCLE TEST ==="
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
echo "=== VERIFY ONE MODEL INVOCATION ==="
invocation_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation; found $invocation_count."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.investigation-lifecycle-contract\.test\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/guard-ollama-response-contract\.sh$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: files outside authorized implementation + fixture-repair surface changed:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_IMPLEMENTATION_AND_FIXTURE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_REGRESSION_FIXTURES_REPAIRED"
echo "INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_RESPONSE_CONTRACT_VALIDATED"
echo "PRODUCTION_WORKFLOW_UNCHANGED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "IEL_EXTENSION_NOT_ADDED"
echo "DATABASE_CHANGE_NOT_ADDED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_IMPLEMENTATION"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  scripts/guard-ollama-response-contract.sh \
  scripts/repair-investigation-lifecycle-regression-fixtures.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle response contract"
git push
