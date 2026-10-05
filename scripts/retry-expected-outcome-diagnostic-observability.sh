#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="e2ba540c5"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== EXPECTEDOUTCOME DIAGNOSTIC OBSERVABILITY — CONTROLLED RETRY ==="

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

needle = '''    throw new Error(
      "Ollama response failed current-request Package Semantics fidelity for expectedOutcome.",
    );
'''

replacement = '''    console.error(
      "[Ollama expectedOutcome fidelity diagnostic]",
      {
        currentRequest: concreteOperationMessage,
        modelAuthoredExpectedOutcome: packageSemantics.expectedOutcome,
      },
    );
    throw new Error(
      "Ollama response failed current-request Package Semantics fidelity for expectedOutcome.",
    );
'''

if "[Ollama expectedOutcome fidelity diagnostic]" in text:
    raise SystemExit("Diagnostic observability already present; refusing duplicate edit.")

if needle not in text:
    raise SystemExit("Exact fidelity failure boundary absent; refusing speculative edit.")

path.write_text(text.replace(needle, replacement, 1))
PY

cat > "$TEST" <<'TESTEOF'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "expectedOutcome fidelity failure exposes bounded diagnostic values without relaxing validation",
  () => {
    assert.match(
      source,
      /\[Ollama expectedOutcome fidelity diagnostic\]/,
    );
    assert.match(
      source,
      /currentRequest:\s*concreteOperationMessage/,
    );
    assert.match(
      source,
      /modelAuthoredExpectedOutcome:\s*packageSemantics\.expectedOutcome/,
    );
    assert.match(
      source,
      /Ollama response failed current-request Package Semantics fidelity for expectedOutcome\./,
    );
  },
);
TESTEOF

echo
echo "=== VALIDATION ==="

git diff --check -- "$TARGET" "$TEST"

npx tsx --test \
  "$TEST" \
  scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.current-user-evidence-boundary.test.ts \
  scripts/utils/ollamaChat.positional-production-contract.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

npx tsc --noEmit
npm run build

echo
echo "=== AUTHORIZED DIFF ==="
git diff -- "$TARGET" "$TEST"

grep -qF '[Ollama expectedOutcome fidelity diagnostic]' "$TARGET"
test -f "$TEST"

echo
echo "=== CLASSIFICATION ==="
echo "DIAGNOSTIC_OBSERVABILITY_IMPLEMENTED=YES"
echo "REJECTED_EXPECTEDOUTCOME_VALUE_LOGGED=YES"
echo "CURRENT_REQUEST_VALUE_LOGGED=YES"
echo "FIDELITY_PREDICATE_CHANGED=NO"
echo "VALIDATOR_RELAXED=NO"
echo "PARSER_CHANGED=NO"
echo "OUTPUT_SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"
echo "DOGFOOD_RETRY_PERFORMED=NO"

git add -- "$TARGET" "$TEST"

ACTUAL="$(git diff --cached --name-only | sort)"
EXPECTED="$(printf '%s\n' "$TARGET" "$TEST" | sort)"

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "STAGED_SCOPE_MISMATCH — refusing commit"
  printf '%s\n' "$ACTUAL"
  git restore --staged -- "$TARGET" "$TEST"
  exit 1
fi

git diff --cached --check

git commit -m "Add expected outcome fidelity diagnostics"
git push origin "$BRANCH"
