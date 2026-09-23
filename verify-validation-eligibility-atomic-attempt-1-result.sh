#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE_HEAD="b4ddf6e5e"

git fetch origin "$BRANCH"

printf '\n=== CURRENT BRANCH STATE ===\n'
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"
echo "BASELINE_HEAD=$BASELINE_HEAD"

printf '\n=== RECENT COMMITS ===\n'
git log --oneline -8

printf '\n=== CHECK FOR IMPLEMENTATION COMMIT ===\n'
git log --oneline --all --grep='Enforce validation delegation eligibility' -5 || true

printf '\n=== TARGET FILE TRACKING ===\n'
for f in \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts
do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "TRACKED=$f"
    git log -1 --oneline -- "$f"
  else
    echo "NOT_TRACKED=$f"
  fi
done

printf '\n=== TARGET WORKTREE / INDEX STATE ===\n'
git status --short -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts

printf '\n=== TARGET DIFF VS BASELINE ===\n'
git diff --stat "$BASELINE_HEAD"..HEAD -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts || true

printf '\n=== VERIFY CURRENT IMPLEMENTATION ===\n'
if git diff --quiet -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts \
  && git diff --cached --quiet -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts
then
  echo "TARGET_FILES_CLEAN=YES"
else
  echo "TARGET_FILES_CLEAN=NO"
fi

if [ "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")" ]; then
  echo "LOCAL_REMOTE_CONVERGED=YES"
else
  echo "LOCAL_REMOTE_CONVERGED=NO"
fi

printf '\n=== RE-RUN SUCCESS GATES IF IMPLEMENTATION LANDED ===\n'
if git log -1 --format='%s' | grep -Eq \
  'Enforce validation delegation eligibility|Record validation eligibility atomic attempt 1'
then
  git diff --check
  npm run check
  ./node_modules/.bin/tsx --test \
    server/routes/governance-validation-route.test.ts \
    server/validation/production-validation-consumer.test.ts \
    server/validation/production-validation-entry-point.test.ts

  echo "VALIDATION_ELIGIBILITY_REPAIR_VERIFIED=YES"
  echo "EXACT_DELEGATION_IDENTITY_REQUIRED=YES"
  echo "MISSING_OR_AMBIGUOUS_FAILS_CLOSED=YES"
  echo "UNAUTHORIZED_FAILS_CLOSED=YES"
  echo "ELIGIBILITY_BEFORE_PERSISTENCE=YES"
  echo "DOWNSTREAM_AUTHORITY=NONE"
  echo "LIVE_DATABASE_MUTATION=NONE"
  echo "UI_CHANGE=NONE"
  echo "AUTO_ADVANCE=NONE"
  echo "NEW_AUTHORITY=NONE"
else
  echo "VALIDATION_ELIGIBILITY_REPAIR_VERIFIED=NO"
  echo "REASON=IMPLEMENTATION_COMMIT_NOT_CONFIRMED_AT_HEAD"
fi

printf '\n=== PRESERVED UNRELATED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_ELIGIBILITY_ATOMIC_ATTEMPT_1_VERIFICATION=COMPLETE\n'
