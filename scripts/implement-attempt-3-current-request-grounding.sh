#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e84a6d49f"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.package-semantics-current-request-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

python3 << 'PY'
from pathlib import Path

target = Path("scripts/utils/ollamaChat.ts")
text = target.read_text()

old = '''            ...(context.requirePackageSemantics === true
              ? [
                  "The current request requires durable Package Semantics. Return a non-null packageSemantics object whose expectedOutcome is a concise non-empty string grounded in the current user request.",
                  "For a concrete operation, expectedOutcome must preserve the operation and direction established by the current user request. Do not invert removal or hiding into restoration or showing, and do not invert addition or showing into removal or hiding.",
'''

new = '''            ...(context.requirePackageSemantics === true
              ? [
                  "The current request requires durable Package Semantics. Return a non-null packageSemantics object whose expectedOutcome is a concise non-empty string grounded in the current user request.",
                  ...(context.concreteOperationMessage
                    ? [
                        "Authoritative current concrete operation for Package Semantics expectedOutcome:",
                        context.concreteOperationMessage,
                        "The expectedOutcome must describe this current concrete operation and its subject. Retrieved, historical, or supporting context may constrain or inform the operation but must not replace its operation, direction, or subject.",
                      ]
                    : []),
                  "For a concrete operation, expectedOutcome must preserve the operation and direction established by the current user request. Do not invert removal or hiding into restoration or showing, and do not invert addition or showing into removal or hiding.",
'''

if old not in text:
    raise SystemExit("FAIL_CLOSED: exact Package Semantics prompt insertion anchor not found")

if text.count(old) != 1:
    raise SystemExit(
        f"FAIL_CLOSED: expected exactly one insertion anchor, found {text.count(old)}"
    )

target.write_text(text.replace(old, new, 1))
PY

cat > "$TEST" << 'TESTEOF'
import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const SOURCE = new URL("./ollamaChat.ts", import.meta.url);

test("concrete operation is presented as authoritative expectedOutcome grounding before generation", async () => {
  const source = await readFile(SOURCE, "utf8");

  assert.match(
    source,
    /Authoritative current concrete operation for Package Semantics expectedOutcome:/,
  );

  assert.match(
    source,
    /context\.concreteOperationMessage/,
  );

  assert.match(
    source,
    /must not replace its operation, direction, or subject/,
  );
});

test("attempt 3 preserves the existing post-generation fidelity guard", async () => {
  const source = await readFile(SOURCE, "utf8");

  assert.match(
    source,
    /function enforceConcreteOperationPackageSemanticsFidelity\(/,
  );

  assert.match(
    source,
    /Ollama response failed current-request Package Semantics fidelity for expectedOutcome\./,
  );
});
TESTEOF

echo "=== AUTHORIZED DIFF ==="
git diff -- "$TARGET" "$TEST"

echo
echo "=== FOCUSED ATTEMPT 3 TEST ==="
npx tsx --test "$TEST"

echo
echo "=== EXISTING GENERATION GROUNDING TEST ==="
npx tsx --test scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "ATTEMPT_3_IMPLEMENTED=YES"
echo "ATTEMPT_3_STATIC_VALIDATION=PASS"
echo "FIDELITY_GUARD_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "OUTPUT_SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"

git add -- "$TARGET" "$TEST"
git commit -m "Ground package semantics in current concrete operation"
git push origin "$BRANCH"
