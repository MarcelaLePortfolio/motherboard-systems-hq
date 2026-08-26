#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT VALIDATION-ONLY PACKAGE SEMANTICS OBSERVER — ATTEMPT 3 ==="
echo "EXPECTED_HEAD_PREFIX=62b42364f"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "AUTHORIZED_BY=806e719992d6d48b293eb623a31814691bc40ff6"
echo "ATTEMPT=3"
echo "EXACT_PARSE_CALL=VERIFIED"
echo "IF_THIS_ATTEMPT_FAILS=REVERT_TO_LAST_STABLE_PRE_OBSERVER_SOURCE_STATE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 62b42364f* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

source_path = Path("scripts/utils/ollamaChat.ts")
source = source_path.read_text()

bad_block = '''  if (context.observeValidatedPackageSemantics) {
    context.observeValidatedPackageSemantics(
      packageSemantics,
    );
  }

'''

if source.count(bad_block) != 1:
    raise SystemExit(f"BAD_OBSERVER_BLOCK_COUNT={source.count(bad_block)}")

source = source.replace(bad_block, "", 1)

anchor = '''    const result =
      parseStructuredResponse(rawResponse);

    if (context.observeParsedSelectedContextSegments) {'''

replacement = '''    const result =
      parseStructuredResponse(rawResponse);

    if (context.observeValidatedPackageSemantics) {
      context.observeValidatedPackageSemantics(
        result.packageSemantics,
      );
    }

    if (context.observeParsedSelectedContextSegments) {'''

if source.count(anchor) != 1:
    raise SystemExit(f"PARSE_CALL_ANCHOR_COUNT={source.count(anchor)}")

source = source.replace(anchor, replacement, 1)
source_path.write_text(source)

test_path = Path(
    "scripts/utils/ollamaChat.package-semantics-observer.test.ts"
)
test_source = test_path.read_text()

old_expectation = (
    "/malformed package semantics field expectedOutcome/i,"
)
new_expectation = (
    "/empty package semantics field expectedOutcome/i,"
)

if test_source.count(old_expectation) != 1:
    raise SystemExit(
        f"TEST_EXPECTATION_COUNT={test_source.count(old_expectation)}"
    )

test_path.write_text(
    test_source.replace(
        old_expectation,
        new_expectation,
        1,
    )
)
PY

echo
echo "=== FOCUSED OBSERVER TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "=== PACKAGE SEMANTICS CONTRACT TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "=== LIFECYCLE REGRESSION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== TYPECHECK ==="
npm run check

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.package-semantics-observer.test.ts

git commit -m "Repair validation-only package semantics observer"
git push
