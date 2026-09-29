#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="89d3bc194"
SOURCE="server/lifecycle/production-envelope-lifecycle-handoff.ts"
TEST="server/lifecycle/production-envelope-lifecycle-handoff.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== TARGET FILE PRESENCE ===\n'
for f in "$SOURCE" "$TEST"; do
  if test -f "$f"; then
    echo "FILE_EXISTS=YES:$f"
  else
    echo "FILE_EXISTS=NO:$f"
  fi

  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "TRACKED=YES:$f"
  else
    echo "TRACKED=NO:$f"
  fi
done

printf '\n=== TARGET FILE HISTORY ===\n'
git log --oneline --all -- "$SOURCE" "$TEST" | head -20 || true

printf '\n=== TARGET FILE CONTENT ===\n'
test -f "$SOURCE" && sed -n '1,260p' "$SOURCE" || true
test -f "$TEST" && sed -n '1,360p' "$TEST" || true

printf '\n=== CLASSIFICATION ===\n'
SOURCE_TRACKED=NO
TEST_TRACKED=NO

git ls-files --error-unmatch "$SOURCE" >/dev/null 2>&1 && SOURCE_TRACKED=YES
git ls-files --error-unmatch "$TEST" >/dev/null 2>&1 && TEST_TRACKED=YES

if [ "$SOURCE_TRACKED" = YES ] && [ "$TEST_TRACKED" = YES ]; then
  echo 'HANDOFF_IMPLEMENTATION_LANDED=YES'
  echo 'NEXT_STEP=VALIDATE_TARGETED_TESTS_AND_RUNTIME_COMPOSITION'
elif test -f "$SOURCE" || test -f "$TEST"; then
  echo 'HANDOFF_IMPLEMENTATION_LANDED=NO'
  echo 'UNCOMMITTED_TARGET_FILES_PRESENT=YES'
  echo 'NEXT_STEP=VALIDATE_EXISTING_TARGET_FILES_BEFORE_ANY_COMMIT'
else
  echo 'HANDOFF_IMPLEMENTATION_LANDED=NO'
  echo 'TARGET_FILES_ABSENT=YES'
  echo 'NEXT_STEP=REPAIR_IMPLEMENTATION_SCRIPT_EXECUTION_PATH'
fi

echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED_BY_THIS_CHECK=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
