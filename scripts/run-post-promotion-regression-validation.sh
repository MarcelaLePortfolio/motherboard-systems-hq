#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN POST-PROMOTION REGRESSION VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor eba6fe40 HEAD
test -z "$(git status --porcelain)"

echo "=== VERIFY PROMOTED DEFAULT ==="
grep -q 'context.validationPromptPresentationVariant === undefined ||' scripts/utils/ollamaChat.ts
grep -q '"explicit_parent_child_separation"' scripts/utils/ollamaChat.ts

echo "=== TARGETED TYPESCRIPT VALIDATION ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  scripts/utils/ollamaChat.ts
echo "TARGETED_TYPESCRIPT_VALIDATION=PASS"

echo "=== DISCOVER EXISTING NODE TEST SURFACE ==="
test_files=()
while IFS= read -r file; do
  test_files+=("$file")
done < <(
  find . \
    \( -path './node_modules' -o -path './.git' \) -prune -o \
    -type f \
    \( -name '*.test.ts' -o -name '*.spec.ts' \) \
    -print |
  grep -E 'ollama|conversation|investigation|interpretation|context|evidence|workflow' |
  sort
)

if [[ "${#test_files[@]}" -eq 0 ]]; then
  echo "STOP: no existing relevant deterministic tests discovered."
  exit 2
fi

printf 'REGRESSION_TEST_FILE=%s\n' "${test_files[@]}"

echo "=== RUN EXISTING DETERMINISTIC NODE TEST SUITE VIA TSX ==="
./node_modules/.bin/tsx --test "${test_files[@]}"

echo "DETERMINISTIC_EXISTING_REGRESSION_SUITE=PASS"
echo "TEST_RUNNER=NODE_TEST_VIA_EXISTING_TSX"
echo "NEW_DEPENDENCY_INSTALL=NONE"
echo "FAIL_CLOSED_CONTRACT=PRESERVED_BY_REGRESSION_SUITE"
echo "PROMPT_PRESENTATION_DEFAULT=PROMOTED"
echo "PRODUCTION_BEHAVIORAL_UNSEEDED_SAMPLE=STILL_REQUIRED"
echo "PRODUCTION_CHANGE=PROMPT_PRESENTATION_DEFAULT_PROMOTED"
echo "NEXT_ACTION=RUN_POST_PROMOTION_PRODUCTION_BEHAVIORAL_UNSEEDED_SAMPLE"
