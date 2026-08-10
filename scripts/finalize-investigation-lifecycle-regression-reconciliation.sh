#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== FINALIZE INVESTIGATION LIFECYCLE REGRESSION RECONCILIATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if ! git merge-base --is-ancestor 5495d45c HEAD; then
  echo "STOP: expected implementation-unit checkpoint 5495d45c is not an ancestor."
  exit 2
fi

echo
echo "=== VERIFY CURRENT CHANGE SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/guard-ollama-response-contract\.sh$|^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$|^scripts/complete-investigation-lifecycle-regression-fixture-repair\.sh$|^scripts/finalize-investigation-lifecycle-regression-reconciliation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected files exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_IMPLEMENTATION_AND_TEST_SURFACE_CONFIRMED"

echo
echo "=== RECONCILE EXPLANATION STATUS STRUCTURED KEY EXPECTATION ==="
python3 <<'PY'
from pathlib import Path
import re

path = Path(
    "scripts/utils/ollamaChat.explanation-status.test.ts"
)
text = path.read_text()

if '"investigationLifecycle"' in text:
    print(
        "Explanation Status test already contains "
        "investigationLifecycle expectation."
    )
else:
    pattern = re.compile(
        r'('
        r'["\']evidence["\']\s*,'
        r'\s*)'
        r'(["\']durableInterpretation["\'])'
    )

    updated, count = pattern.subn(
        r'\1"investigationLifecycle",\n'
        r'      \2',
        text,
        count=1,
    )

    if count != 1:
        print("=== EXPLANATION STATUS TEST CONTEXT ===")
        for index, line in enumerate(
            text.splitlines(),
            start=1,
        ):
            if (
                "evidence" in line
                or "durableInterpretation" in line
                or "deepEqual" in line
                or "deepStrictEqual" in line
            ):
                print(f"{index}: {line}")

        raise SystemExit(
            "STOP: could not identify exactly one ordered "
            "evidence -> durableInterpretation expectation."
        )

    path.write_text(updated)
    print(
        "Added investigationLifecycle to structured-key "
        "expectation."
    )
PY

echo
echo "=== ENSURE REMAINING MOCKED RESPONSES CARRY NULL LIFECYCLE ==="
python3 <<'PY'
from pathlib import Path
import re

targets = [
    Path(
        "scripts/utils/"
        "ollamaChat.selected-context-observer.test.ts"
    ),
    Path(
        "scripts/utils/"
        "ollamaChat.validation-seed.test.ts"
    ),
]

total_added = 0

for path in targets:
    text = path.read_text()

    # Operate on JSON.stringify object literals used as mocked
    # Ollama responses. Add the required nullable lifecycle field
    # only when that individual object does not already contain it.
    cursor = 0
    pieces = []

    pattern = re.compile(
        r'JSON\.stringify\(\s*\{'
    )

    while True:
        match = pattern.search(text, cursor)

        if not match:
            pieces.append(text[cursor:])
            break

        pieces.append(
            text[cursor:match.end()]
        )

        object_start = match.end()
        scan = object_start
        depth = 1
        in_string = False
        quote = ""
        escaped = False

        while scan < len(text) and depth > 0:
            ch = text[scan]

            if in_string:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == quote:
                    in_string = False
            else:
                if ch in ("'", '"', "`"):
                    in_string = True
                    quote = ch
                elif ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1

            scan += 1

        if depth != 0:
            raise SystemExit(
                f"STOP: could not bound mocked response "
                f"object in {path}."
            )

        object_body = text[
            object_start:scan - 1
        ]

        if "investigationLifecycle" not in object_body:
            pieces.append(
                "\n"
                "          investigationLifecycle: null,"
            )
            total_added += 1

        pieces.append(object_body)
        pieces.append("}")
        cursor = scan

    path.write_text("".join(pieces))

print(
    f"ADDITIONAL_NULL_LIFECYCLE_FIXTURES={total_added}"
)
PY

echo
echo "=== VERIFY STRUCTURED KEY ORDER ==="
grep -n -A12 -B4 \
  'investigationLifecycle' \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  | head -n 40

echo
echo "=== VERIFY SELECTED-CONTEXT FIXTURES ==="
selected_count="$(
  grep -c \
    'investigationLifecycle: null' \
    scripts/utils/ollamaChat.selected-context-observer.test.ts \
    || true
)"
echo "SELECTED_CONTEXT_NULL_LIFECYCLE_COUNT=$selected_count"

if [[ "$selected_count" -lt 4 ]]; then
  echo "STOP: selected-context observer fixtures remain incomplete."
  exit 2
fi

echo
echo "=== VERIFY VALIDATION-SEED FIXTURES ==="
seed_count="$(
  grep -c \
    'investigationLifecycle: null' \
    scripts/utils/ollamaChat.validation-seed.test.ts \
    || true
)"
echo "VALIDATION_SEED_NULL_LIFECYCLE_COUNT=$seed_count"

if [[ "$seed_count" -lt 2 ]]; then
  echo "STOP: validation-seed fixtures remain incomplete."
  exit 2
fi

echo
echo "=== RERUN PREVIOUSLY FAILING TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== INVESTIGATION LIFECYCLE CONTRACT TEST ==="
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
if ! git diff --quiet -- \
  server/matilda-chat-workflow.ts
then
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
  grep -c 'fetch(' \
    scripts/utils/ollamaChat.ts \
    || true
)"

echo "OLLAMA_FETCH_INVOCATION_COUNT=$invocation_count"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY FINAL CHANGE SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/guard-ollama-response-contract\.sh$|^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$|^scripts/complete-investigation-lifecycle-regression-fixture-repair\.sh$|^scripts/finalize-investigation-lifecycle-regression-reconciliation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: files outside authorized implementation and test-reconciliation surface changed:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_FINAL_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
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
  scripts/finalize-investigation-lifecycle-regression-reconciliation.sh

git diff --cached --check

git commit -m "Implement bounded Investigation Lifecycle response contract"
git push
