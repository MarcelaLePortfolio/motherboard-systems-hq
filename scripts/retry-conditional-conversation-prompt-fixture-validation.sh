#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0231a2e50"
TARGET="scripts/utils/ollamaChat.ts"
TEST="scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "=== CONDITIONAL PROMPT — FIXTURE VALIDATION RETRY ==="

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts")
source = path.read_text()

old = "durableInterpretation: null,"
new = 'durableInterpretation: "The user requested bounded support provenance.",'

count = source.count(old)

if count == 2:
    source = source.replace(old, new)
    path.write_text(source)
    print("FIXTURE_CORRECTIONS_APPLIED=2")
elif count == 0 and source.count(new) == 2:
    print("FIXTURE_CORRECTIONS_ALREADY_PRESENT=YES")
else:
    raise SystemExit(
        f"UNEXPECTED_DURABLE_FIXTURE_STATE=null_count={count},valid_count={source.count(new)}"
    )
PY

echo
echo "=== VERIFY AUTHORIZED IMPLEMENTATION ==="
git diff --check -- "$TARGET" "$TEST"
git diff -- "$TARGET" "$TEST"

echo
echo "=== TARGETED + REGRESSION VALIDATION ==="
npx tsx --test \
  "$TEST" \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.current-user-evidence-boundary.test.ts \
  scripts/utils/ollamaChat.positional-production-contract.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== CLASSIFICATION ==="
echo "TEST_FIXTURE_CORRECTED=YES"
echo "TARGETED_AND_REGRESSION_TESTS=PASSED"
echo "TYPECHECK=PASSED"
echo "BUILD=PASSED"
echo "PROMPT_HYPOTHESIS_VALIDATED=YES"
echo "EMPTY_HISTORY_POSITIVE_CONVERSATION_INSTRUCTION=OMITTED"
echo "EMPTY_HISTORY_NEGATIVE_SAFEGUARDS=PRESERVED"
echo "NONEMPTY_HISTORY_POSITIVE_INSTRUCTION=PRESERVED"
echo "SCHEMA_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "VALIDATOR_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"

echo
echo "=== CERTIFIED SCOPE ==="
git status --short -- "$TARGET" "$TEST"

test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

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

git commit -m "Condition conversation support prompt on history"
git push origin "$BRANCH"
