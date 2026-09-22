#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="22898dbd6"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " GOVERNANCE DELEGATION CONTRACT — READ-ONLY VERIFICATION"
echo "============================================================"
echo "MODE=READ_ONLY"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== A. GOVERNANCE DELEGATION ROUTE ==="
sed -n '1,420p' server/routes/governance-delegation-route.ts

echo
echo "=== B. PRODUCTION DELEGATION CONSUMER ==="
sed -n '1,420p' server/delegation/production-delegation-consumer.ts

echo
echo "=== C. PRODUCTION DELEGATION ENTRY POINT ==="
sed -n '1,520p' server/delegation/production-delegation-entry-point.ts

echo
echo "=== D. DELEGATION PERSISTENCE ==="
if test -f db/governance-delegation-persistence.ts; then
  sed -n '1,520p' db/governance-delegation-persistence.ts
else
  grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -E 'INSERT INTO governance_delegations|createGovernanceDelegation|GovernanceDelegationPersistence' \
    db server \
    2>/dev/null | head -500 || true
fi

echo
echo "=== E. ROUTE / ENTRY-POINT TEST CONTRACT ==="
sed -n '1,520p' server/routes/governance-delegation-route.test.ts
sed -n '1,520p' server/delegation/production-delegation-entry-point.test.ts
sed -n '1,520p' server/delegation/production-delegation-consumer.test.ts

echo
echo "=== F. CURRENT PERSISTENCE SCHEMA — READ ONLY ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT sql
FROM sqlite_master
WHERE type='table'
  AND name='governance_delegations';

SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at DESC
LIMIT 20;
SQL

echo
echo "=== G. CURRENT CANONICAL PACKAGES AWAITING DELEGATION — READ ONLY ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.status,
  c.approval_actor,
  c.approval_timestamp,
  CASE
    WHEN d.delegation_id IS NULL THEN 'AWAITING_DELEGATION'
    ELSE d.authorization_state
  END AS delegation_state,
  d.delegation_id,
  d.delegated_by,
  d.authorization_timestamp
FROM matilda_canonical_packages c
LEFT JOIN governance_delegations d
  ON d.project_id = c.project_id
 AND d.package_id = c.package_id
 AND d.package_version = c.package_version
WHERE c.status = 'canonical_approved'
ORDER BY c.created_at DESC;
SQL

echo
echo "=== H. CLIENT REFRESH / DATA SOURCES ==="
sed -n '1,220p' client/src/approvals/ApprovalRequestProvider.tsx
sed -n '1,260p' client/src/approvals/canonicalPackageReadApi.ts

grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'fetchCanonicalPackages|refresh\(\)|governance/delegation|delegation_state|AWAITING_DELEGATION' \
  client/src \
  2>/dev/null | head -600 || true

echo
echo "=== I. FAIL-CLOSED / DUPLICATE BEHAVIOR ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'already delegated|duplicate|existing delegation|authorization_state|AUTHORIZED|fail.*closed|project.*mismatch|package.*mismatch|version.*mismatch' \
  server/delegation \
  server/routes/governance-delegation-route.test.ts \
  db \
  2>/dev/null | head -900 || true

echo
echo "============================================================"
echo " VERIFICATION STOP — NO IMPLEMENTATION"
echo "============================================================"
echo "QUESTION_1=WHAT_FIELDS_MUST_THE_CLIENT_SEND"
echo "QUESTION_2=WHICH_FIELDS_MUST_BE_SERVER_DERIVED_OR_VALIDATED"
echo "QUESTION_3=WHAT_AUTHORIZATION_STATE_VALUE_IS_CANONICAL"
echo "QUESTION_4=HOW_ARE_DUPLICATE_OR_ALREADY_DELEGATED_REQUESTS_HANDLED"
echo "QUESTION_5=WHAT_PERSISTED_ROW_PROVES_SUCCESS"
echo "QUESTION_6=WHAT_CLIENT_REFRESH_PATH_WILL_REFLECT_SUCCESS"
echo "QUESTION_7=WHAT_IS_THE_SMALLEST_UI_ADAPTER_NEEDED"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_MINIMAL_EXECUTIVE_DELEGATION_IMPLEMENTATION_UNIT"
echo "CLEAR_STOPPING_POINT=YES"
