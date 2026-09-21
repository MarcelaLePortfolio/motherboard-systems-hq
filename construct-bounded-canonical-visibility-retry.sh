#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="39cf09d2a"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "============================================================"
echo " BOUNDED RETRY — PRE-EXECUTION CONFIRMATION"
echo "============================================================"

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
  test ! -e "$path" || {
    echo "STOP=AUTHORIZED_NEW_PATH_ALREADY_EXISTS:$path"
    exit 1
  }
done

for path in "${AUTHORIZED_EXISTING_PATHS[@]}"; do
  test -f "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_MISSING:$path"
    exit 1
  }

  git diff --quiet -- "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_MODIFIED:$path"
    exit 1
  }

  git diff --cached --quiet -- "$path" || {
    echo "STOP=AUTHORIZED_EXISTING_PATH_STAGED:$path"
    exit 1
  }
done

echo "BOUNDED_RETRY_PRECONDITIONS=SATISFIED"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "IMPLEMENTATION_RETRY_PERFORMED=NO"
echo "NEXT_ACTION=RETURN_OUTPUT_BEFORE_PRODUCT_MUTATION"
echo "CLEAR_STOPPING_POINT=YES"
