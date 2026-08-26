#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT PACKAGE SEMANTICS UNKNOWN-FIELD VALIDATOR GAP ==="
echo "EXPECTED_HEAD_PREFIX=06920c14a"
echo "DECISION_COMMIT=06920c14a59e8be9412163dee59eb0529f2946c5"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 06920c14a* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== PACKAGE SEMANTICS VALIDATOR ==="
VALIDATOR_LINE="$(rg -n '^export function validateMatildaPackageSemanticsArtifact' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
if [[ -z "${VALIDATOR_LINE}" ]]; then
  echo "PACKAGE_SEMANTICS_VALIDATOR_NOT_FOUND"
  exit 1
fi
START=$((VALIDATOR_LINE > 8 ? VALIDATOR_LINE - 8 : 1))
END=$((VALIDATOR_LINE + 105))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== OUTPUT SCHEMA PACKAGE SEMANTICS ==="
rg -n -C 30 \
  'packageSemantics|additionalProperties' \
  scripts/utils/ollamaChat.ts \
  | sed -n '1,260p'

echo
echo "=== PACKAGE SEMANTICS VALIDATOR CALL SITES ==="
rg -n -C 12 -F 'validateMatildaPackageSemanticsArtifact' \
  scripts/utils/ollamaChat.ts \
  server \
  db \
  scripts \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' || true

echo
echo "=== CURRENT PACKAGE SEMANTICS CONTRACT TESTS ==="
sed -n '1,260p' scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "=== UNKNOWN-FIELD TEST COVERAGE SEARCH ==="
rg -n -i \
  'unknown.*package semantics|package semantics.*unknown|additionalProperties|unexpectedField|extra field|unknown field' \
  scripts server db \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' || true

echo
echo "=== IEL RECONSTRUCTION PATH ==="
rg -n -C 20 \
  'package_semantics_json|packageSemantics|validateMatildaPackageSemanticsArtifact' \
  db server \
  --glob '!node_modules/**' || true

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=DOES_RUNTIME_VALIDATOR_REJECT_KEYS_OUTSIDE_THE_SEVEN_FIELD_PACKAGE_SEMANTICS_CONTRACT"
echo "QUESTION_2=DOES_SCHEMA_additionalProperties_false_HAVE_AN_EQUIVALENT_RUNTIME_CHECK"
echo "QUESTION_3=DOES_IEL_RECONSTRUCTION_REUSE_THE_SAME_VALIDATOR"
echo "QUESTION_4=DO_CURRENT_TESTS_ASSERT_UNKNOWN_FIELD_FAIL_CLOSED"
echo "QUESTION_5=WOULD_A_FIX_BE_LIMITED_TO_SHARED_VALIDATOR_AND_FOCUSED_TESTS"
echo "NEXT_ACTION=CLASSIFY_FROM_EVIDENCE_ONLY"
echo "SOURCE_EDIT=NONE"

git diff --check

git add inspect-package-semantics-unknown-field-validator-gap.sh
git commit -m "Inspect package semantics unknown-field validator gap"
git push
