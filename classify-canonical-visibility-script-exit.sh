#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="03f88cf11"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 6 — SCRIPT EXIT CLASSIFICATION\n'
printf '============================================================\n'

printf '\n=== A. VERIFY PRODUCT IMPLEMENTATION COMMIT ABSENT ===\n'
if git log --all --format='%h %s' \
  | grep -F 'Add canonical package read visibility bridge'; then
  echo "PRODUCT_IMPLEMENTATION_COMMIT_PRESENT=YES"
else
  echo "PRODUCT_IMPLEMENTATION_COMMIT_PRESENT=NO"
fi

printf '\n=== B. VERIFY PRODUCT FILES / WORKTREE ===\n'
git status --short

for file in \
  db/canonical-package-read-repository.ts \
  routes/api-canonical-package-read.ts \
  client/src/approvals/canonicalPackageReadApi.ts \
  docs/checkpoints/CANONICAL_PACKAGE_VISIBILITY_RESTORATION_IMPLEMENTATION.md
do
  if test -f "$file"; then
    echo "PRESENT=$file"
  else
    echo "ABSENT=$file"
  fi
done

printf '\n=== C. CHECK WHETHER SERVER INDEX WAS MODIFIED ===\n'
grep -n -E \
  'createCanonicalPackageReadRouter|api-canonical-package-read' \
  server/index.ts || true

printf '\n=== D. LOCATE ALL FAIL-CLOSED SCRIPT BOUNDARIES ===\n'
nl -ba implement-canonical-package-visibility-restoration.sh \
  | grep -E \
    'EXPECTED_HEAD|git fetch|test |raise SystemExit|git diff --check|npm run build|npm --prefix client run build|git add|git commit|git push'

printf '\n=== E. VERIFY SCRIPT BASELINE ASSUMPTION ===\n'
grep -n '^EXPECTED_HEAD=' \
  implement-canonical-package-visibility-restoration.sh

CURRENT_HEAD="$(git rev-parse --short=9 HEAD)"
SCRIPT_EXPECTED_HEAD="$(
  sed -n 's/^EXPECTED_HEAD="\([^"]*\)"/\1/p' \
    implement-canonical-package-visibility-restoration.sh
)"

echo "CURRENT_HEAD=$CURRENT_HEAD"
echo "SCRIPT_EXPECTED_HEAD=$SCRIPT_EXPECTED_HEAD"

if test "$CURRENT_HEAD" = "$SCRIPT_EXPECTED_HEAD"; then
  echo "SCRIPT_BASELINE_MATCHES_CURRENT_HEAD=YES"
else
  echo "SCRIPT_BASELINE_MATCHES_CURRENT_HEAD=NO"
  echo "CLASSIFICATION=PROCEDURE_SCRIPT_IS_SINGLE_USE_AND_NOW_FAILS_AT_EXPECTED_HEAD_GUARD"
fi

printf '\n=== F. VERIFY ORIGINAL PROCEDURE COMMIT PARENT ===\n'
git show --no-patch \
  --format='PROCEDURE_COMMIT=%h%nPROCEDURE_PARENT=%p%nSUBJECT=%s' \
  03f88cf11

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 6 — STOP HERE\n'
printf '============================================================\n'
echo "PRODUCT_MUTATION_PERFORMED_BY_THIS_INVESTIGATION=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_RETRY_PERFORMED=NO"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=CLASSIFY_WHETHER_SAFE_EXECUTION_REQUIRES_REBASED_ONE_TIME_IMPLEMENTATION_SCRIPT"
echo "CLEAR_STOPPING_POINT=YES"
