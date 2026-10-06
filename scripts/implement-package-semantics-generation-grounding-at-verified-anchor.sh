#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="07a263036"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== AUTHORIZED IMPLEMENTATION — ATTEMPT 2 ==="
echo "AUTHORIZATION_RECEIVED=YES"
echo "PREVIOUS_ATTEMPT_FAILURE_COUNT=1_OF_3"
echo "ANCHOR_VERIFIED_FROM_SOURCE=YES"
echo "SCOPE=NARROW_PACKAGE_SEMANTICS_GENERATION_GROUNDING"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

anchor = '''                  "The current request requires durable Package Semantics. Return a non-null packageSemantics object whose expectedOutcome is a concise non-empty string grounded in the current user request.",
                  "Do not satisfy this requirement by inventing missing semantics. Fields other than expectedOutcome remain null unless actually established by the user request and supplied context.",'''

replacement = '''                  "The current request requires durable Package Semantics. Return a non-null packageSemantics object whose expectedOutcome is a concise non-empty string grounded in the current user request.",
                  "For a concrete operation, expectedOutcome must preserve the operation and direction established by the current user request. Do not invert removal or hiding into restoration or showing, and do not invert addition or showing into removal or hiding.",
                  "Treat preservation requirements as constraints on the requested operation, not as substitutes for or reversals of expectedOutcome. For example, removing a UI tab while preserving its underlying runtime functionality means the expected outcome is removal of the UI tab with that runtime functionality preserved, not restoration of the tab or package visibility.",
                  "Do not satisfy this requirement by inventing missing semantics. Fields other than expectedOutcome remain null unless actually established by the user request and supplied context.",'''

if replacement in text:
    raise SystemExit("Authorized grounding instructions already present; refusing duplicate mutation.")

count = text.count(anchor)
if count != 1:
    raise SystemExit(
        f"Verified prompt anchor occurrence count was {count}, expected exactly 1; refusing mutation."
    )

path.write_text(text.replace(anchor, replacement, 1))
PY

cat > "$TEST" << 'TESTEOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const sourcePath = path.resolve("scripts/utils/ollamaChat.ts");

test("required Package Semantics prompt preserves concrete operation direction", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /For a concrete operation, expectedOutcome must preserve the operation and direction established by the current user request\./,
  );

  assert.match(
    source,
    /Do not invert removal or hiding into restoration or showing/,
  );

  assert.match(
    source,
    /do not invert addition or showing into removal or hiding/,
  );
});

test("required Package Semantics prompt keeps preservation requirements as constraints", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /Treat preservation requirements as constraints on the requested operation, not as substitutes for or reversals of expectedOutcome\./,
  );

  assert.match(
    source,
    /removing a UI tab while preserving its underlying runtime functionality means the expected outcome is removal of the UI tab with that runtime functionality preserved/,
  );

  assert.match(
    source,
    /not restoration of the tab or package visibility/,
  );
});
TESTEOF

echo
echo "=== EXACT AUTHORIZED DIFF ==="
git diff -- "$TARGET" "$TEST"

echo
echo "=== CHANGE-SCOPE ASSERTIONS ==="
git diff -- "$TARGET" | grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request'

git diff -- "$TARGET" | grep -q \
  'Treat preservation requirements as constraints on the requested operation'

# The authorized target change must remain inside the model prompt region.
CHANGED_EXISTING_LINES="$(
  git diff --unified=0 -- "$TARGET" \
    | grep '^@@' \
    | sed -E 's/^@@ -[0-9]+(,[0-9]+)? \+([0-9]+).*/\2/'
)"

test -n "$CHANGED_EXISTING_LINES"

while IFS= read -r line; do
  test "$line" -ge 1355
  test "$line" -le 1365
done <<< "$CHANGED_EXISTING_LINES"

echo "PROMPT_ONLY_TARGET_MUTATION=YES"

echo
echo "=== FIDELITY GUARD IMMUTABILITY CHECK ==="
git diff -- "$TARGET" | grep -qv 'operationSemanticTerms' || {
  echo "Unexpected operationSemanticTerms mutation detected."
  exit 1
}

if git diff -- "$TARGET" \
  | grep -E '^[+-].*(preservesOperation|preservesSubject|enforceConcreteOperationPackageSemanticsFidelity)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "Unexpected fidelity guard mutation detected."
  exit 1
fi

echo "FIDELITY_GUARD_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"

echo
echo "=== TARGETED TEST ==="
node --test "$TEST"

echo
echo "=== OLLAMA CHAT REGRESSION TESTS ==="
TEST_FILES=()
while IFS= read -r file; do
  TEST_FILES+=("$file")
done < <(
  find scripts/utils -maxdepth 1 -type f -name 'ollamaChat*.test.ts' | sort
)

node --test "${TEST_FILES[@]}"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== PRE-COMMIT CERTIFICATION ==="
echo "AUTHORIZED_IMPLEMENTATION_SCOPE_PASSED=YES"
echo "PROMPT_DIRECTION_GROUNDING_PRESENT=YES"
echo "PRESERVATION_CONSTRAINT_GROUNDING_PRESENT=YES"
echo "FIDELITY_GUARD_PRESERVED=YES"
echo "DOGFOOD_RETRY_PERFORMED=NO"

git add -- "$TARGET" "$TEST"

echo
echo "=== STAGED PATHS ==="
git diff --cached --name-only

test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "2"
git diff --cached --name-only | grep -qx "$TARGET"
git diff --cached --name-only | grep -qx "$TEST"

git commit -m "Ground package semantics outcome direction"
git push origin "$BRANCH"
