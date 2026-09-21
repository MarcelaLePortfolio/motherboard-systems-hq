#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="24f12bde9"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 8 — BOUNDED RETRY CONTRACT\n'
printf '============================================================\n'
echo "MODE=READ_ONLY_RETRY_DESIGN"
echo "IMPLEMENTATION_RETRY=NO"
echo "AUTHORIZED_SCOPE=CANONICAL_PACKAGE_READ_ONLY_VISIBILITY"

printf '\n=== A. DEFINE AUTHORIZED PRODUCT PATHS ===\n'

AUTHORIZED_NEW_PATHS=(
  "db/canonical-package-read-repository.ts"
  "routes/api-canonical-package-read.ts"
  "client/src/approvals/canonicalPackageReadApi.ts"
  "docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md"
)

AUTHORIZED_EXISTING_PATHS=(
  "server/index.ts"
  "client/src/approvals/ApprovalsWorkspace.tsx"
)

for path in "${AUTHORIZED_NEW_PATHS[@]}"; do
  echo "AUTHORIZED_NEW_PATH=$path"
done

for path in "${AUTHORIZED_EXISTING_PATHS[@]}"; do
  echo "AUTHORIZED_EXISTING_PATH=$path"
done

printf '\n=== B. VERIFY NEW PRODUCT PATHS ARE ABSENT ===\n'

for path in "${AUTHORIZED_NEW_PATHS[@]}"; do
  if test -e "$path"; then
    echo "STOP=AUTHORIZED_NEW_PATH_ALREADY_EXISTS:$path"
    exit 1
  fi
  echo "ABSENT_AS_EXPECTED=$path"
done

printf '\n=== C. VERIFY EXISTING AUTHORIZED PATHS ARE NOT LOCALLY MODIFIED ===\n'

for path in "${AUTHORIZED_EXISTING_PATHS[@]}"; do
  if ! test -f "$path"; then
    echo "STOP=AUTHORIZED_EXISTING_PATH_MISSING:$path"
    exit 1
  fi

  if ! git diff --quiet -- "$path"; then
    echo "STOP=AUTHORIZED_EXISTING_PATH_HAS_UNCOMMITTED_TRACKED_DIFF:$path"
    git diff -- "$path"
    exit 1
  fi

  if ! git diff --cached --quiet -- "$path"; then
    echo "STOP=AUTHORIZED_EXISTING_PATH_HAS_STAGED_DIFF:$path"
    git diff --cached -- "$path"
    exit 1
  fi

  echo "AUTHORIZED_EXISTING_PATH_CLEAN=$path"
done

printf '\n=== D. VERIFY NO AUTHORIZED PATH IS UNTRACKED UNEXPECTEDLY ===\n'

for path in "${AUTHORIZED_EXISTING_PATHS[@]}"; do
  if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
    echo "TRACKED_AS_EXPECTED=$path"
  else
    echo "STOP=EXPECTED_TRACKED_PATH_NOT_TRACKED:$path"
    exit 1
  fi
done

printf '\n=== E. RECORD UNRELATED WORKTREE WITHOUT MUTATING IT ===\n'

UNRELATED_STATUS_FILE="$(mktemp)"
git status --porcelain > "$UNRELATED_STATUS_FILE"

echo "TOTAL_PREEXISTING_STATUS_ENTRIES=$(wc -l < "$UNRELATED_STATUS_FILE" | tr -d ' ')"
echo "UNRELATED_WORKTREE_WILL_BE_PRESERVED=YES"
echo "STASH_AUTHORIZED=NO"
echo "RESET_AUTHORIZED=NO"
echo "CLEAN_AUTHORIZED=NO"

printf '\n=== F. INSPECT ORIGINAL IMPLEMENTATION MUTATION SURFACE ===\n'

grep -n -E \
  'cat > |Path\(|read_text|write_text|git add --|git commit|git push|server/index|ApprovalsWorkspace|canonical-package-read|canonicalPackageReadApi' \
  implement-canonical-package-visibility-restoration.sh \
  | head -260 || true

printf '\n=== G. CLASSIFY SAFE EXECUTION CONTRACT ===\n'

echo "WHOLE_WORKTREE_CLEAN_REQUIRED=NO"
echo "AUTHORIZED_PATHS_MUST_BE_CLEAN_BEFORE_EXECUTION=YES"
echo "AUTHORIZED_NEW_PATHS_MUST_BE_ABSENT_BEFORE_EXECUTION=YES"
echo "UNRELATED_TRACKED_CHANGES_MAY_REMAIN=YES"
echo "UNRELATED_UNTRACKED_FILES_MAY_REMAIN=YES"
echo "STAGE_ONLY_EXPLICIT_AUTHORIZED_PATHS=YES"
echo "GIT_ADD_DOT_PROHIBITED=YES"
echo "STASH_PROHIBITED=YES"
echo "RESET_PROHIBITED=YES"
echo "CLEAN_PROHIBITED=YES"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"
echo "PACKAGES_TAB_RESTORATION_AUTHORIZED=NO"

printf '\n=== H. VERIFY RETRY CAN BE REBASED WITHOUT EXPANDING AUTHORIZATION ===\n'

if \
  test ! -e db/canonical-package-read-repository.ts && \
  test ! -e routes/api-canonical-package-read.ts && \
  test ! -e client/src/approvals/canonicalPackageReadApi.ts && \
  test ! -e docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md && \
  git diff --quiet -- server/index.ts && \
  git diff --cached --quiet -- server/index.ts && \
  git diff --quiet -- client/src/approvals/ApprovalsWorkspace.tsx && \
  git diff --cached --quiet -- client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "BOUNDED_REBASE_PRECONDITIONS=SATISFIED"
else
  echo "BOUNDED_REBASE_PRECONDITIONS=NOT_SATISFIED"
  exit 1
fi

rm -f "$UNRELATED_STATUS_FILE"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 8 — STOP HERE\n'
printf '============================================================\n'
echo "BOUNDED_RETRY_CONTRACT_DEFINED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_RETRY_PERFORMED=NO"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=CONSTRUCT_REBASED_ONE_TIME_IMPLEMENTATION_SCRIPT_USING_BOUNDED_PATH_GUARDS"
echo "CLEAR_STOPPING_POINT=YES"
