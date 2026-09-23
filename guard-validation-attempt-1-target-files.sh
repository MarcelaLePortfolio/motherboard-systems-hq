#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3e0904712"

TARGETS=(
  "db/governance-validation-read-repository.ts"
  "server/validation/production-validation-consumer.ts"
  "server/routes/governance-validation-route.ts"
  "server/validation/production-validation-consumer.test.ts"
  "server/routes/governance-validation-route.test.ts"
)

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== ATTEMPT 1 TARGET GUARD ===\n'
echo "HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "CURRENT_HYPOTHESIS=MINIMUM_EXACT_READ_ONLY_DELEGATION_READER"
echo "CURRENT_HYPOTHESIS_ATTEMPTS=0"
echo "UNRELATED_DIRTY_WORKTREE=PRESERVE"
echo "TARGET_FILE_DRIFT_ALLOWED=NO"

printf '\n=== TARGET TRACKING STATE ===\n'
for f in "${TARGETS[@]}"; do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "TRACKED=$f"
  else
    echo "UNTRACKED_EXPECTED_NEW=$f"
  fi
done

printf '\n=== TARGET WORKTREE DRIFT CHECK ===\n'
for f in \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts
do
  git diff --quiet -- "$f" || {
    echo "ABORT_TARGET_MODIFIED=$f"
    exit 2
  }

  git diff --cached --quiet -- "$f" || {
    echo "ABORT_TARGET_STAGED=$f"
    exit 2
  }

  echo "TARGET_CLEAN=$f"
done

if [ -e db/governance-validation-read-repository.ts ] && \
   ! git ls-files --error-unmatch db/governance-validation-read-repository.ts >/dev/null 2>&1
then
  echo "ABORT_NEW_READER_PATH_ALREADY_EXISTS=YES"
  exit 2
fi

printf '\n=== EXACT BASELINE BLOBS ===\n'
for f in \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts
do
  printf '%s=' "$f"
  git rev-parse "HEAD:$f"
done

printf '\n=== NEW READER CONTRACT ===\n'
echo "PATH=db/governance-validation-read-repository.ts"
echo "IDENTITY=delegation_id+package_id+package_version"
echo "QUERY_LIMIT=2"
echo "EXACTLY_ONE_REQUIRED=YES"
echo "RETURN_IDENTITY_AND_AUTHORIZATION_STATE=YES"
echo "DATABASE_MODE=READ_ONLY_FILE_MUST_EXIST"
echo "DEFAULT_DATABASE=db/main.db"
echo "DATABASE_WRITE=NO"

printf '\n=== ATOMIC ATTEMPT 1 BOUNDARY ===\n'
echo "TARGET_COUNT=5"
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_DATABASE_MUTATION=NO"
echo "UI_CHANGE=NO"
echo "AUTO_ADVANCE=NO"
echo "NEW_AUTHORITY=NO"
echo "ELIGIBILITY_BEFORE_PERSISTENCE=YES"
echo "AUTHORIZED_PATH_PERSISTENCE_CALLS=1"
echo "DOWNSTREAM_AUTHORITY=NONE"

printf '\n=== FAILURE CONTAINMENT ===\n'
echo "ON_ATTEMPT_FAILURE=RESTORE_FOUR_TRACKED_TARGETS_AND_REMOVE_ONLY_NEW_READER"
echo "UNRELATED_WORKTREE_FILES_MUST_NOT_BE_RESTORED_OR_STAGED=YES"
echo "COMMIT_ONLY_EXPLICIT_TARGET_PATHS=YES"
echo "GIT_ADD_DOT=PROHIBITED"

printf '\n=== VALIDATION GATES ===\n'
echo "GATE_1=git_diff_check"
echo "GATE_2=npm_run_check"
echo "GATE_3=repository_native_tsx_targeted_tests"
echo "ALL_GATES_REQUIRED_BEFORE_COMMIT=YES"

printf '\n=== PRESERVED UNRELATED WORKTREE COUNT ===\n'
git status --short | wc -l | tr -d ' '

printf '\nVALIDATION_ATTEMPT_1_TARGET_GUARD=PASS\n'
