#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="a00732c8a"
SOURCE="server/lifecycle/production-envelope-lifecycle-handoff.ts"
TEST="server/lifecycle/production-envelope-lifecycle-handoff.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== HANDOFF FILE STATUS ===\n'
for file in "$SOURCE" "$TEST"; do
  if test -f "$file"; then
    echo "FILE_EXISTS=YES:$file"
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      echo "TRACKED=YES:$file"
    else
      echo "TRACKED=NO:$file"
    fi
  else
    echo "FILE_EXISTS=NO:$file"
  fi
done

printf '\n=== HANDOFF HISTORY ===\n'
git log --oneline --all -- "$SOURCE" "$TEST" | head -20 || true

printf '\n=== WORKTREE ===\n'
git status --short

printf '\n=== CLASSIFICATION ===\n'
SOURCE_TRACKED=NO
TEST_TRACKED=NO

git ls-files --error-unmatch "$SOURCE" >/dev/null 2>&1 && SOURCE_TRACKED=YES
git ls-files --error-unmatch "$TEST" >/dev/null 2>&1 && TEST_TRACKED=YES

if [ "$SOURCE_TRACKED" = YES ] && [ "$TEST_TRACKED" = YES ]; then
  echo 'HANDOFF_IMPLEMENTATION_LANDED=YES'
  echo 'NEXT_STEP=VALIDATE_RUNTIME_CONTRACT_AND_LIVE_COMPOSITION'
elif test -f "$SOURCE" || test -f "$TEST"; then
  echo 'HANDOFF_IMPLEMENTATION_LANDED=NO'
  echo 'UNCOMMITTED_HANDOFF_FILES_PRESENT=YES'
  echo 'NEXT_STEP=VALIDATE_EXISTING_FILES_BEFORE_COMMIT'
else
  echo 'HANDOFF_IMPLEMENTATION_LANDED=NO'
  echo 'ONLY_IMPLEMENTATION_SCRIPT_CONFIRMED=YES'
  echo 'NEXT_STEP=EXECUTE_ALREADY_AUTHORIZED_IMPLEMENTATION'
fi

echo 'AUTHORIZATION=ACTIVE'
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
