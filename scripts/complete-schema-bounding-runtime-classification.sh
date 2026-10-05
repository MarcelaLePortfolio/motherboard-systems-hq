#!/bin/bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
FAILED_COMMIT="00d16769f"
STABLE_RUNTIME="c8b4cf51d"

echo "=== SCHEMA BOUNDING — COMPLETE ACTIVE-RUNTIME CLASSIFICATION ==="

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test -z "$(git diff --cached --name-only)"

echo "CURRENT_HEAD=$(git rev-parse HEAD)"
echo

echo "=== 1. CURRENT RUNTIME VS FAILED COMMIT ==="
set +e
git diff --quiet "$FAILED_COMMIT" HEAD -- scripts/utils/ollamaChat.ts
FAILED_MATCH_EXIT=$?
set -e

echo "FAILED_MATCH_EXIT=$FAILED_MATCH_EXIT"

if [ "$FAILED_MATCH_EXIT" -eq 0 ]; then
  echo "CURRENT_RUNTIME_EQUALS_FAILED_COMMIT=YES"
else
  echo "CURRENT_RUNTIME_EQUALS_FAILED_COMMIT=NO"
  git diff "$FAILED_COMMIT" HEAD -- scripts/utils/ollamaChat.ts || true
fi
echo

echo "=== 2. FAILED IMPLEMENTATION MARKERS ==="
MARKERS_PRESENT=0
for PATTERN in \
  'BASE_OLLAMA_CHAT_OUTPUT_SCHEMA' \
  'buildOllamaChatOutputSchema' \
  'format: buildOllamaChatOutputSchema'
do
  if git show HEAD:scripts/utils/ollamaChat.ts | grep -q "$PATTERN"; then
    echo "PRESENT=$PATTERN"
    MARKERS_PRESENT=1
  else
    echo "ABSENT=$PATTERN"
  fi
done
echo

echo "=== 3. OLLAMACHAT LINEAGE SINCE STABLE RUNTIME ==="
git log --oneline "$STABLE_RUNTIME"..HEAD -- scripts/utils/ollamaChat.ts
echo

echo "=== 4. DEFINITIVE CLASSIFICATION ==="
if [ "$FAILED_MATCH_EXIT" -eq 0 ] && [ "$MARKERS_PRESENT" -eq 1 ]; then
  echo "RECOVERY_STATUS=FAILED_RUNTIME_STILL_ACTIVE"
  echo "FAILED_RUNTIME_ACTIVE=YES"
  echo "FAILED_ATTEMPTS_CURRENT_HYPOTHESIS=2"
  echo "NEXT_ACTION=REVERT_FAILED_RUNTIME_EFFECT_BEFORE_ANY_NEW_IMPLEMENTATION"
else
  echo "RECOVERY_STATUS=REQUIRES_INTERVENING_CHANGE_CLASSIFICATION"
  echo "FAILED_RUNTIME_ACTIVE=UNDETERMINED"
  echo "FAILED_ATTEMPTS_CURRENT_HYPOTHESIS=2"
  echo "NEXT_ACTION=INSPECT_INTERVENING_OLLAMACHAT_CHANGE"
fi

echo
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
