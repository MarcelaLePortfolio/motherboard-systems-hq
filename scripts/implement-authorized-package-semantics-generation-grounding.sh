#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d9d059909"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== AUTHORIZED IMPLEMENTATION ==="
echo "AUTHORIZATION_RECEIVED=YES"
echo "SCOPE=NARROW_PACKAGE_SEMANTICS_GENERATION_GROUNDING"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

needle = (
    '"When Package Semantics are required, packageSemantics must be non-null and '
    'expectedOutcome must be a non-empty request-specific outcome.",'
)

replacement = (
    needle
    + '\n'
    + '            "For a concrete operation, expectedOutcome must preserve the current user request\'s operation and direction; never invert removal/hiding into restoration/showing, or addition/showing into removal/hiding.",\n'
    + '            "Treat requested preservation boundaries as constraints on the operation, not as substitutes for or reversals of the requested outcome. For example, removing a UI tab while preserving its underlying runtime functionality means the outcome is removal of the UI tab with runtime functionality preserved, not restoration of package visibility.",'
)

if replacement in text:
    raise SystemExit(
        "Grounding instructions already present; refusing duplicate mutation."
    )

if needle not in text:
    raise SystemExit(
        "Expected Package Semantics prompt anchor not found; refusing speculative mutation."
    )

text = text.replace(needle, replacement, 1)
path.write_text(text)
PY

cat > "$TEST" << 'TESTEOF'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import path from "node:path";

const sourcePath = path.resolve("scripts/utils/ollamaChat.ts");

test("Package Semantics generation prompt preserves concrete operation direction", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /expectedOutcome must preserve the current user request's operation and direction/,
  );

  assert.match(
    source,
    /never invert removal\/hiding into restoration\/showing/,
  );
});

test("Package Semantics generation prompt distinguishes preservation constraints from outcome direction", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(
    source,
    /Treat requested preservation boundaries as constraints on the operation/,
  );

  assert.match(
    source,
    /removing a UI tab while preserving its underlying runtime functionality means the outcome is removal of the UI tab with runtime functionality preserved/,
  );

  assert.match(
    source,
    /not restoration of package visibility/,
  );
});
TESTEOF

echo
echo "=== SCOPE DIFF ==="
git diff -- "$TARGET" "$TEST"

echo
echo "=== TARGETED TESTS ==="
node --test \
  scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts \
  scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts

echo
echo "=== EXISTING OLLAMA CHAT TESTS ==="
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
echo "=== GOVERNANCE BOUNDARY CHECK ==="
git diff -- "$TARGET" \
  | grep -q "expectedOutcome must preserve the current user request's operation and direction"

git diff -- "$TARGET" \
  | grep -q "Treat requested preservation boundaries as constraints on the operation"

if git diff -- "$TARGET" \
  | grep -E '^[+-].*(operationSemanticTerms|preservesOperation|preservesSubject|MatildaPackageSemanticsArtifact)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "Unexpected fidelity/schema mutation detected."
  exit 1
fi

echo "FIDELITY_GUARD_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"
echo "DOGFOOD_RETRY_PERFORMED=NO"

echo
echo "=== AUTHORIZED PATHS ONLY ==="
git status --short -- "$TARGET" "$TEST"

git add -- "$TARGET" "$TEST"

git diff --cached --name-only | grep -qx "$TARGET"
git diff --cached --name-only | grep -qx "$TEST"
test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "2"

git commit -m "Ground package semantics outcome direction"
git push origin "$BRANCH"
