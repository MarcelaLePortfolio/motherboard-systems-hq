#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6cb97166d"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 3 — RECONCILED PACKAGE VISIBILITY INTENT\n'
printf '============================================================\n'
echo "CURRENT_FINDING=CANONICAL_PACKAGE_EXISTS_BUT_CURRENT_APPROVALS_API_ONLY_READS_PENDING_REQUESTS"
echo "IMPORTANT=THIS_DOES_NOT_YET_PROVE_APPROVED_PACKAGES_WERE_INTENDED_TO_DISAPPEAR_FROM_EXECUTIVE_INBOX"
echo "NOW_CHECKING=HISTORICAL_RECONCILIATION_AND_PACKAGES_TO_APPROVALS_MIGRATION"
echo "MODE=READ_ONLY"
echo "MUTATION_AUTHORIZED=NO"

printf '\n=== A. COMMIT THAT ADOPTED PACKAGES INTERACTION MODEL ===\n'
git show --stat --summary b4463714e
git show --format=fuller --find-renames b4463714e -- \
  client/src/approvals \
  docs \
  | sed -n '1,700p'

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 3A — ORIGINAL MIGRATION CHANGE COLLECTED\n'
printf '============================================================\n'
echo "NOW_CHECKING=DOCUMENTED_LANGUAGE_ABOUT_PACKAGE_VISIBILITY_AFTER_APPROVAL"

printf '\n=== B. SEARCH RECONCILIATION / REPLACEMENT LANGUAGE ===\n'
grep -RniE \
  'Packages tab|Packages workspace|Executive Inbox|Approvals|canonical package|canonical packages|approved package|approved packages|package visibility|remain visible|remains visible|history|historical|resolved|completed|artifact switching|interaction model|replace|replacement|parity' \
  docs \
  --include='*.md' \
  | head -n 800 || true

printf '\n=== C. KEY HISTORICAL CHECKPOINTS ===\n'
for file in \
  docs/checkpoints/PACKAGES_WORKSPACE_V1_COMPLETE.md \
  docs/checkpoints/APPROVALS_EXECUTIVE_INBOX_PRESENTATION_COMPLETE.md \
  docs/checkpoints/EXECUTIVE_INBOX_APPROVAL_RUNTIME_COMPLETE.md \
  docs/checkpoints/EXECUTIVE_INBOX_APPROVAL_BASELINE_DR_20260802_010330.md \
  docs/EXECUTIVE_ATTENTION_ARCHITECTURE.md
do
  if test -f "$file"; then
    printf '\n----- %s -----\n' "$file"
    cat "$file"
  fi
done

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 3B — DOCUMENTED CONTRACT COLLECTED\n'
printf '============================================================\n'
echo "NOW_CHECKING=WHAT_PACKAGES_UI_COULD_READ_BEFORE_APPROVALS_REPLACED_IT"

printf '\n=== D. HISTORICAL PACKAGES CLIENT FILES BEFORE MIGRATION ===\n'
git ls-tree -r --name-only 4b66fe9d9^ \
  | grep -Ei 'package|packages' \
  | head -n 250 || true

printf '\n=== E. HISTORICAL PACKAGE READ MODEL / ROUTES ===\n'
git grep -n -Ei \
  'fetch.*package|package.*fetch|/api/.*package|canonical.*package|package.*canonical|package.*status' \
  4b66fe9d9^ -- \
  'client/**' 'server/**' 'routes/**' 'db/**' \
  | head -n 600 || true

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 3C — HISTORICAL READ PATH COLLECTED\n'
printf '============================================================\n'
echo "NOW_CHECKING=WHETHER_CURRENT_APPROVALS_IMPLEMENTATION_PRESERVED_THAT_CAPABILITY"

printf '\n=== F. CURRENT APPROVAL REQUEST REPOSITORY FILTER ===\n'
sed -n '1,180p' db/approval-request-repository.ts

printf '\n=== G. CURRENT APPROVALS DATA SOURCES ===\n'
grep -RniE \
  'fetchApprovalRequests|fetch.*Package|canonical|requests|selectedRequest|setRequests' \
  client/src/approvals \
  --include='*.ts' \
  --include='*.tsx' \
  | head -n 400 || true

printf '\n=== H. CURRENT SERVER READ ROUTES FOR CANONICAL PACKAGES ===\n'
grep -RniE \
  'router\.(get|post).*canonical|app\.(get|post).*canonical|matilda_canonical_packages' \
  server routes db \
  --include='*.ts' \
  --include='*.mjs' \
  | head -n 500 || true

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 3 — STOP HERE\n'
printf '============================================================\n'
echo "KNOWN_FACT_1=APPROVED_PACKAGE_IS_DURABLY_CANONICAL"
echo "KNOWN_FACT_2=PENDING_APPROVAL_QUERY_EXCLUDES_DRAFTS_ONCE_CANONICAL_EXISTS"
echo "KNOWN_FACT_3=CURRENT_APPROVALS_CLIENT_READ_MODEL_ONLY_REPRESENTS_PENDING_APPROVAL_REQUESTS"
echo "OPEN_CLASSIFICATION=WHETHER_THIS_IS_INTENDED_LIFECYCLE_OR_LOST_EXECUTIVE_INBOX_PACKAGE_VISIBILITY"
echo "DO_NOT_IMPLEMENT=YES"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_RECONCILED_INTENT_FROM_POINT_3_EVIDENCE"
echo "CLEAR_STOPPING_POINT=YES"
