#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
BASELINE="$(git rev-parse --short=9 HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

echo "============================================================"
echo " INVESTIGATION POINT 4A — HISTORICAL PACKAGE READ SEMANTICS"
echo "============================================================"
echo "NOW_CHECKING=WHAT_THE_REMOVED_PACKAGES_SURFACE_ACTUALLY_EXPOSED"

echo
echo "=== A. HISTORICAL PACKAGE READ REPOSITORY ==="
git show 4b66fe9d9^:db/package-read-repository.ts || true

echo
echo "=== B. HISTORICAL PACKAGE READ MODEL ASSEMBLER ==="
git show 4b66fe9d9^:db/package-read-model-assembler.ts || true

echo
echo "=== C. HISTORICAL PACKAGE READ TYPES ==="
git show 4b66fe9d9^:db/package-read-model-types.ts || true

echo
echo "=== D. HISTORICAL PACKAGE READ API ==="
git show 4b66fe9d9^:routes/api-package-read.ts || true

echo
echo "=== E. HISTORICAL PACKAGES WORKSPACE DATA USAGE ==="
git show 4b66fe9d9^:client/src/packages/PackagesWorkspace.tsx | sed -n '1,340p' || true

echo
echo "============================================================"
echo " INVESTIGATION POINT 4B — CURRENT CANONICAL READ CAPABILITIES"
echo "============================================================"
echo "NOW_CHECKING=WHETHER_EXISTING_CURRENT_CODE_CAN_RESTORE_VISIBILITY_WITHOUT_RECREATING_OBSOLETE_PACKAGES_INFRASTRUCTURE"

echo
echo "=== F. CURRENT CANONICAL PACKAGE RUNTIME READ FUNCTIONS ==="
grep -n -E \
  'export (function|const)|SELECT|FROM matilda_canonical_packages|package_id|package_version|draft_revision_id|canonical_approved' \
  db/matilda-canonical-package-runtime.ts \
  | head -260 || true

echo
echo "=== G. CURRENT MISSION / CANONICAL PROJECTIONS ==="
sed -n '1,300p' db/canonical-package-mission-projection.ts 2>/dev/null || true
sed -n '1,260p' db/mission-read-repository.ts 2>/dev/null || true
sed -n '1,260p' db/mission-read-model-assembler.ts 2>/dev/null || true

echo
echo "=== H. CURRENT ROUTES THAT COULD EXPOSE APPROVED PACKAGE READS ==="
grep -RInE \
  'router\.get|app\.get|mission-read|canonical.*package|package.*read' \
  routes server/routes \
  --include='*.ts' \
  | head -320 || true

echo
echo "=== I. CURRENT APPROVALS PRESENTATION BOUNDARY ==="
sed -n '560,780p' client/src/approvals/ApprovalsWorkspace.tsx
sed -n '1,280p' client/src/approvals/approvalRequestApi.ts

echo
echo "============================================================"
echo " INVESTIGATION POINT 4 — STOP HERE"
echo "============================================================"
echo "QUESTION_TO_CLASSIFY=WHAT_MINIMAL_READ_ONLY_BRIDGE_RESTORES_CANONICAL_PACKAGE_VISIBILITY_AFTER_PACKAGES_TAB_REMOVAL"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "DO_NOT_IMPLEMENT=YES"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=CLASSIFY_HISTORICAL_READ_RESPONSIBILITY_VS_CURRENT_REUSABLE_READ_PATH"
echo "CLEAR_STOPPING_POINT=YES"
