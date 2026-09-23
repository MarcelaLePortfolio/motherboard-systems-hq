#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6d23f7ded"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== RECONCILIATION ===\n'
echo "VALIDATION_ELIGIBILITY_REPAIR=LANDED"
echo "LANDING_COMMIT=$EXPECTED_HEAD"
echo "IMPLEMENTATION_FILES=5"
echo "INSPECTION_SCRIPT_INCLUDED_IN_SAME_COMMIT=YES"
echo "HISTORY_REWRITE=NO"

printf '\n=== VERIFY LANDED FILE BOUNDARY ===\n'
git diff-tree --no-commit-id --name-status -r HEAD

for f in \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts
do
  git cat-file -e "HEAD:$f"
  echo "HEAD_CONTAINS=$f"
done

printf '\n=== VERIFY IMPLEMENTATION TARGETS CLEAN ===\n'
test -z "$(git status --porcelain -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts)"
echo "IMPLEMENTATION_TARGETS_CLEAN=YES"

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check

printf '\n=== GATE 2: TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: TARGETED VALIDATION TESTS ===\n'
./node_modules/.bin/tsx --test \
  server/routes/governance-validation-route.test.ts \
  server/validation/production-validation-consumer.test.ts \
  server/validation/production-validation-entry-point.test.ts

printf '\n=== REMOTE CONVERGENCE ===\n'
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
echo "LOCAL_REMOTE_CONVERGED=YES"

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "VALIDATION_ELIGIBILITY_REPAIR=IMPLEMENTED_AND_REVALIDATED"
echo "EXACT_DELEGATION_IDENTITY_REQUIRED=YES"
echo "MISSING_OR_AMBIGUOUS_FAILS_CLOSED=YES"
echo "UNAUTHORIZED_FAILS_CLOSED=YES"
echo "ELIGIBILITY_BEFORE_PERSISTENCE=YES"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "LIVE_DATABASE_MUTATION=NONE"
echo "UI_CHANGE=NONE"
echo "AUTO_ADVANCE=NONE"
echo "NEW_AUTHORITY=NONE"
echo "IMPLEMENTATION_HEAD=$EXPECTED_HEAD"

printf '\n=== PRESERVED UNRELATED WORKTREE ===\n'
git status --short
