#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="5a97371ee"
ORIGINAL_BASE="5cf1edec5"
PROCEDURE_COMMIT="03f88cf11"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 7 — ORIGINAL EXIT BOUNDARY\n'
printf '============================================================\n'
echo "MODE=READ_ONLY_PRODUCT_INVESTIGATION"
echo "IMPLEMENTATION_RETRY=NO"

printf '\n=== A. VERIFY ORIGINAL SCRIPT BASE ===\n'
SCRIPT_EXPECTED_HEAD="$(
  sed -n 's/^EXPECTED_HEAD="\([^"]*\)"/\1/p' \
    implement-canonical-package-visibility-restoration.sh
)"

PROCEDURE_PARENT="$(
  git rev-parse --short=9 "${PROCEDURE_COMMIT}^"
)"

echo "SCRIPT_EXPECTED_HEAD=$SCRIPT_EXPECTED_HEAD"
echo "PROCEDURE_PARENT=$PROCEDURE_PARENT"
echo "EXPECTED_ORIGINAL_BASE=$ORIGINAL_BASE"

test "$SCRIPT_EXPECTED_HEAD" = "$ORIGINAL_BASE"
test "$PROCEDURE_PARENT" = "$ORIGINAL_BASE"

echo "SCRIPT_WAS_AUTHORED_FOR_PROCEDURE_PARENT=YES"

printf '\n=== B. IDENTIFY FIRST FAIL-CLOSED GUARDS ===\n'
nl -ba implement-canonical-package-visibility-restoration.sh \
  | sed -n '1,30p'

printf '\n=== C. CURRENT WORKTREE CLASSIFICATION ===\n'
TRACKED_DIRTY_COUNT="$(
  git status --porcelain \
    | awk 'substr($0,1,2) != "??" {count++} END {print count+0}'
)"

UNTRACKED_COUNT="$(
  git status --porcelain \
    | awk 'substr($0,1,2) == "??" {count++} END {print count+0}'
)"

echo "TRACKED_DIRTY_COUNT=$TRACKED_DIRTY_COUNT"
echo "UNTRACKED_COUNT=$UNTRACKED_COUNT"

git status --short

if test -z "$(git status --porcelain)"; then
  echo "CURRENT_WORKTREE_CLEAN=YES"
else
  echo "CURRENT_WORKTREE_CLEAN=NO"
fi

printf '\n=== D. TEST ORIGINAL CLEAN-WORKTREE GUARD NON-DESTRUCTIVELY ===\n'
if test -z "$(git status --porcelain)"; then
  echo "ORIGINAL_CLEAN_WORKTREE_GUARD_WOULD_PASS_NOW=YES"
else
  echo "ORIGINAL_CLEAN_WORKTREE_GUARD_WOULD_PASS_NOW=NO"
fi

printf '\n=== E. VERIFY AUTHORIZED PRODUCT FILES STILL ABSENT ===\n'
for file in \
  db/canonical-package-read-repository.ts \
  routes/api-canonical-package-read.ts \
  client/src/approvals/canonicalPackageReadApi.ts \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md
do
  if test -e "$file"; then
    echo "UNEXPECTED_PRESENT=$file"
    exit 1
  else
    echo "ABSENT=$file"
  fi
done

printf '\n=== F. VERIFY NO PRODUCT DIFF FROM FAILED ATTEMPT ===\n'
if git diff --quiet -- \
  db/canonical-package-read-repository.ts \
  routes/api-canonical-package-read.ts \
  client/src/approvals/canonicalPackageReadApi.ts \
  server/index.ts \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md
then
  echo "AUTHORIZED_PRODUCT_DIFF_PRESENT=NO"
else
  echo "AUTHORIZED_PRODUCT_DIFF_PRESENT=YES"
  git diff -- \
    db/canonical-package-read-repository.ts \
    routes/api-canonical-package-read.ts \
    client/src/approvals/canonicalPackageReadApi.ts \
    server/index.ts \
    docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md
fi

printf '\n=== G. CLASSIFY ORIGINAL FAILURE POSSIBILITY ===\n'
echo "HEAD_GUARD_AFTER_PROCEDURE_COMMIT=KNOWN_FAILURE"
echo "CLEAN_WORKTREE_GUARD_CURRENTLY_FAILS=YES"

echo
echo "IMPORTANT=DO_NOT_ASSUME_WHICH_GUARD_STOPPED_THE_ORIGINAL_INVOCATION_WITHOUT_EVIDENCE"
echo "SAFE_RETRY_REQUIRES=PRESERVE_UNRELATED_WORKTREE_AND_REBASE_ONE_TIME_SCRIPT_WITH_BOUNDED_PATH_VALIDATION"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 7 — STOP HERE\n'
printf '============================================================\n'
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_RETRY_PERFORMED=NO"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=DESIGN_BOUNDED_REBASED_EXECUTION_THAT_DOES_NOT_REQUIRE_OR_DISTURB_UNRELATED_WORKTREE"
echo "CLEAR_STOPPING_POINT=YES"
