#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="f153e5c40"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4A — HISTORICAL PACKAGE READ CONTRACT\n'
printf '============================================================\n'
echo "MODE=READ_ONLY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"

printf '\n=== A1. HISTORICAL REPOSITORY INTERFACE + SQL ===\n'
git show 4b66fe9d9^:db/package-read-repository.ts \
  | grep -n -E \
    'interface |listLivingDraftPackagesByProject|getLivingDraftPackageById|SELECT|FROM |WHERE |ORDER BY |status|project_id|conversation_id' \
  | head -n 220 || true

printf '\n=== A2. HISTORICAL READ MODEL TYPE ===\n'
git show 4b66fe9d9^:db/package-read-model-types.ts \
  | sed -n '1,220p' || true

printf '\n=== A3. HISTORICAL MODEL ASSEMBLER OUTPUT ===\n'
git show 4b66fe9d9^:db/package-read-model-assembler.ts \
  | grep -n -E \
    'return \{|status:|source_status|summary|requested|proposed|scope|constraints|evidence|draft_package_id|lineage_id|project_id|conversation_id' \
  | head -n 260 || true

printf '\n=== A4. HISTORICAL API ROUTES ===\n'
git show 4b66fe9d9^:routes/api-package-read.ts \
  | grep -n -E \
    'router\.get|project_id|draftPackageId|packages|package|status\(' \
  | head -n 220 || true

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4A COMPLETE\n'
printf '============================================================\n'
echo "NOW_CHECKING=WHETHER_HISTORICAL_SURFACE_WAS_DRAFT_ONLY_OR_INCLUDED_CANONICAL_PACKAGES"

printf '\n=== B1. HISTORICAL PACKAGE STATUS DOMAIN ===\n'
git show 4b66fe9d9^:db/package-read-model-types.ts \
  | grep -n -E \
    'ExecutivePackageStatus|needs_review|canonical|approved|status' \
  || true

printf '\n=== B2. HISTORICAL REPOSITORY SOURCE TABLES ===\n'
git show 4b66fe9d9^:db/package-read-repository.ts \
  | grep -n -E \
    'matilda_living_draft_packages|matilda_canonical_packages|JOIN|FROM' \
  || true

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4B COMPLETE\n'
printf '============================================================\n'
echo "NOW_CHECKING=CURRENT_CANONICAL_PACKAGE_READ_CAPABILITIES"

printf '\n=== C1. CURRENT CANONICAL PACKAGE SELECTS ===\n'
grep -n -B 8 -A 28 \
  -E 'FROM matilda_canonical_packages|SELECT .*package_id|canonical_approved' \
  db/matilda-canonical-package-runtime.ts \
  | head -n 360 || true

printf '\n=== C2. CURRENT EXPORTED CANONICAL FUNCTIONS ===\n'
grep -n -E \
  '^export (function|const|class|type|interface)' \
  db/matilda-canonical-package-runtime.ts \
  || true

printf '\n=== C3. CURRENT CANONICAL / MISSION READ HELPERS ===\n'
for file in \
  db/canonical-package-mission-projection.ts \
  db/mission-read-repository.ts \
  db/mission-read-model-assembler.ts \
  db/operational-package-authority.ts
do
  if test -f "$file"; then
    echo
    echo "----- $file -----"
    grep -n -E \
      'export |SELECT|FROM matilda_canonical_packages|package_id|package_version|canonical_approved|return ' \
      "$file" \
      | head -n 260 || true
  fi
done

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4C COMPLETE\n'
printf '============================================================\n'
echo "NOW_CHECKING=CURRENT_EXECUTIVE_FACING_GET_ROUTES"

printf '\n=== D1. CURRENT GET ROUTES ===\n'
grep -RniE \
  'router\.get\(' \
  routes server/routes \
  --include='*.ts' \
  | grep -Ei \
    'package|mission|approval|canonical' \
  | head -n 300 || true

printf '\n=== D2. CURRENT APPROVALS CLIENT DATA SOURCES ===\n'
grep -RniE \
  'fetchApprovalRequests|fetch.*Package|/api/|collection\?\.requests|requests\.map|selectedRequest' \
  client/src/approvals \
  --include='*.ts' \
  --include='*.tsx' \
  | head -n 320 || true

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4D COMPLETE\n'
printf '============================================================\n'
echo "NOW_CHECKING=WHETHER_OLD_PACKAGE_READ_INFRASTRUCTURE_STILL_EXISTS"

printf '\n=== E. CURRENT PACKAGE READ ARTIFACT PRESENCE ===\n'
for file in \
  db/package-read-repository.ts \
  db/package-read-model-assembler.ts \
  db/package-read-model-types.ts \
  routes/api-package-read.ts \
  client/src/packages/packageReadApi.ts \
  client/src/packages/PackageReadProvider.tsx \
  client/src/packages/usePackages.ts \
  client/src/packages/PackagesWorkspace.tsx
do
  if test -f "$file"; then
    echo "PRESENT=$file"
  else
    echo "ABSENT=$file"
  fi
done

printf '\n============================================================\n'
printf ' INVESTIGATION POINT 4 — COMPLETE / STOP HERE\n'
printf '============================================================\n'
echo "POINT_4=EVIDENCE_COLLECTED"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "NEXT_ACTION=CLASSIFY_MINIMAL_READ_ONLY_CANONICAL_PACKAGE_RESTORATION_BOUNDARY"
echo "CLEAR_STOPPING_POINT=YES"
