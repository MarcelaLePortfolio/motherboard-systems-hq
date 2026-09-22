#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " SECOND CANONICAL PACKAGE ITEM — DELEGATION RECONCILIATION"
echo "============================================================"
echo "MODE=READ_ONLY"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== A. AUTHORITATIVE APPROVAL / DELEGATION SPECIFICATIONS ==="
for FILE in \
  docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md \
  docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md \
  docs/governance/MATILDA_CANONICAL_PACKAGE_APPROVAL_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_CANONICAL_PACKAGE_APPROVAL_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_PACKAGE_DELEGATION_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_PACKAGE_DELEGATION_VALIDATED_2026-07-05.md
do
  if test -f "$FILE"; then
    echo
    echo "----- $FILE -----"
    cat "$FILE"
  fi
done

echo
echo "=== B. CURRENT PRODUCTION DELEGATION CONTRACT ==="
for FILE in \
  server/delegation/production-delegation-entry-point.ts \
  server/delegation/production-delegation-consumer.ts \
  server/routes/governance-delegation-route.ts \
  server/routes/matilda-delegation-route.ts \
  db/matilda-delegation-runtime.ts \
  db/governance-delegation-persistence.ts \
  db/canonical-package-mission-projection.ts \
  db/mission-read-model-assembler.ts
do
  if test -f "$FILE"; then
    echo
    echo "----- $FILE -----"
    sed -n '1,520p' "$FILE"
  fi
done

echo
echo "=== C. HISTORICAL SECOND-ITEM / EXECUTIVE-INBOX PRESENTATION ==="
grep -RniE \
  'Awaiting Delegation|awaiting delegation|Confirm Delegation|confirm delegation|Delegate Package|delegate package|Delegate.*Canonical|Canonical.*Delegate|delegation confirmation|delegation.*approval|approval.*delegation|second.*approval|second.*item' \
  docs client/src public scripts \
  --include='*.md' \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.js' \
  --include='*.sh' \
  2>/dev/null | head -1800 || true

echo
echo "=== D. DELEGATION WORKSPACE RECONCILIATION HISTORY ==="
for FILE in \
  docs/checkpoints/DELEGATION_WORKSPACE_CORRIDOR_1_IMPLEMENTATION_READY.md \
  scripts/reconcile-executive-inbox-delegation-workspace-target.sh \
  scripts/finalize-delegation-workspace-corridor-map.sh \
  scripts/classify-delegation-workspace-phase-corridor-map.sh
do
  if test -f "$FILE"; then
    echo
    echo "----- $FILE -----"
    sed -n '1,700p' "$FILE"
  fi
done

echo
echo "=== E. CURRENT APPROVALS WORKSPACE DECISION SURFACE ==="
grep -n -C 12 -E \
  'available_decisions|approve_canonical_package|request_changes|delegat|canonicalPackage|canonical_package' \
  client/src/approvals/ApprovalRequestProvider.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/canonicalPackageReadApi.ts \
  2>/dev/null || true

echo
echo "=== F. CURRENT ROUTE MOUNTING ==="
grep -RniE \
  'governance-delegation|matilda-delegation|canonical-package|approval-request|request-changes' \
  server/index.ts routes server/routes \
  --include='*.ts' \
  --include='*.mjs' \
  2>/dev/null | head -1000 || true

echo
echo "=== G. DELEGATION PERSISTENCE — SCHEMA AND CURRENT ROWS ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT name, sql
FROM sqlite_master
WHERE type='table'
  AND (
    name LIKE '%delegat%'
    OR name LIKE '%canonical%'
  )
ORDER BY name;

SELECT 'governance_delegations' AS table_name, COUNT(*) AS row_count
FROM governance_delegations
WHERE EXISTS (
  SELECT 1
  FROM sqlite_master
  WHERE type='table'
    AND name='governance_delegations'
);

SELECT 'matilda_delegations' AS table_name, COUNT(*) AS row_count
FROM matilda_delegations
WHERE EXISTS (
  SELECT 1
  FROM sqlite_master
  WHERE type='table'
    AND name='matilda_delegations'
);
SQL

echo
echo "=== H. HISTORICAL COMMITS MOST LIKELY TO DEFINE SECOND ITEM ==="
git log \
  --all \
  --date=iso \
  --pretty=format:'%h %ad %s' \
  --regexp-ignore-case \
  --grep='delegation workspace' \
  --grep='delegation control' \
  --grep='package delegation' \
  --grep='canonical delegation' \
  --grep='executive inbox' \
  --grep='awaiting delegation' \
  -n 400

echo
echo
echo "============================================================"
echo " RECONCILIATION STOP — NO IMPLEMENTATION"
echo "============================================================"
echo "ESTABLISHED_INVARIANT=CANONICAL_APPROVAL_DOES_NOT_AUTHORIZE_DELEGATION"
echo "ESTABLISHED_INVARIANT=APPROVED_CANONICAL_PACKAGE_REMAINS_UNDELEGATED"
echo "QUESTION_1=WHAT_EXACT_SECOND_ITEM_PRESENTED_THE_DELEGATION_DECISION"
echo "QUESTION_2=WHAT_EXACT_USER_ACTION_CONFIRMED_DELEGATION"
echo "QUESTION_3=WHICH_PRODUCTION_ROUTE_PERSISTS_THAT_AUTHORIZATION"
echo "QUESTION_4=IS_THAT_ROUTE_CURRENTLY_MOUNTED_AND_REACHABLE"
echo "QUESTION_5=SHOULD_APPROVED_CANONICAL_PACKAGES_SURFACE_AS_AWAITING_DELEGATION_IN_APPROVALS"
echo "QUESTION_6=DID_RECENT_VISIBILITY_RESTORATION_RESTORE_READ_VISIBILITY_WITHOUT_RESTORING_DELEGATION_ACTIONS"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_SECOND_CANONICAL_PACKAGE_DELEGATION_ITEM"
echo "CLEAR_STOPPING_POINT=YES"
