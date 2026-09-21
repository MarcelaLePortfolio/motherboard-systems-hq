#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ce03cdd29"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 2 — EXECUTIVE INBOX REPLACEMENT CONTRACT\n'
printf '============================================================\n'
echo "POINT_1_CONCLUSION=PACKAGES_TAB_REMOVAL_WAS_CONDITIONED_ON_EXECUTIVE_INBOX_FEATURE_PARITY"
echo "OPEN_QUESTION=WHERE_SHOULD_AN_APPROVED_CANONICAL_PACKAGE_BE_VISIBLE_AFTER_APPROVAL"
echo "MODE=READ_ONLY"
echo "MUTATION_AUTHORIZED=NO"

printf '\n=== A. APPROVALS PRESENTATION COMPLETION CONTRACT ===\n'
sed -n '1,140p' \
  docs/checkpoints/APPROVALS_EXECUTIVE_INBOX_PRESENTATION_COMPLETE.md

printf '\n=== B. EXECUTIVE INBOX APPROVAL RUNTIME CONTRACT ===\n'
sed -n '1,130p' \
  docs/checkpoints/EXECUTIVE_INBOX_APPROVAL_RUNTIME_COMPLETE.md

printf '\n=== C. POST-APPROVAL BASELINE ===\n'
sed -n '1,130p' \
  docs/checkpoints/EXECUTIVE_INBOX_APPROVAL_BASELINE_DR_20260802_010330.md

printf '\n=== D. EXECUTIVE ATTENTION ARCHITECTURE ===\n'
sed -n '1,140p' \
  docs/EXECUTIVE_ATTENTION_ARCHITECTURE.md

printf '\n=== E. HISTORICAL PACKAGES WORKSPACE CONTRACT ===\n'
sed -n '1,130p' \
  docs/checkpoints/PACKAGES_WORKSPACE_V1_COMPLETE.md

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 2A — DOCUMENT CONTRACT COLLECTED\n'
printf '============================================================\n'
echo "NOW_CHECKING=CURRENT_APPROVALS_UI_AGAINST_RECONCILED_CONTRACT"

printf '\n=== F. CURRENT APPROVALS UI PACKAGE/CANONICAL BEHAVIOR ===\n'
grep -RniE \
  'canonical|approved|pending|package|briefing|inbox|request|status' \
  client/src/approvals \
  --include='*.tsx' \
  --include='*.ts' \
  | head -n 400 || true

printf '\n=== G. CURRENT APPROVALS WORKSPACE ===\n'
sed -n '1,520p' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== H. CURRENT APPROVAL REQUEST API ===\n'
sed -n '1,340p' client/src/approvals/approvalRequestApi.ts

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 2B — CURRENT UI COLLECTED\n'
printf '============================================================\n'
echo "NOW_CHECKING=WHETHER_CANONICAL_PACKAGES_HAVE_A_READ_PATH_AFTER_APPROVAL"

printf '\n=== I. CANONICAL PACKAGE READ ROUTES / ADAPTERS ===\n'
grep -RniE \
  'canonical.package|canonical-package|matilda_canonical_packages|package_id|package_version' \
  server db client/src \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  --exclude='*.test.ts' \
  --exclude='*.test.mjs' \
  | head -n 500 || true

printf '\n=== J. RELEVANT PRESENTATION HISTORY ===\n'
git log \
  --all \
  --date=short \
  --pretty=format:'COMMIT %h %ad %s' \
  -- \
  client/src/approvals \
  docs/checkpoints/APPROVALS_EXECUTIVE_INBOX_PRESENTATION_COMPLETE.md \
  docs/checkpoints/EXECUTIVE_INBOX_APPROVAL_RUNTIME_COMPLETE.md \
  docs/checkpoints/PACKAGES_WORKSPACE_V1_COMPLETE.md \
  | head -n 160

printf '\n\n============================================================\n'
printf ' INVESTIGATION POINT 2 — STOP HERE\n'
printf '============================================================\n'
echo "QUESTION_TO_CLASSIFY=DOES_RECONCILED_CONTRACT_REQUIRE_APPROVED_CANONICAL_PACKAGES_TO_REMAIN_ACCESSIBLE_IN_APPROVALS"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "DO_NOT_IMPLEMENT=YES"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=CLASSIFY_DOCUMENTED_CONTRACT_VS_CURRENT_IMPLEMENTATION"
echo "CLEAR_STOPPING_POINT=YES"
