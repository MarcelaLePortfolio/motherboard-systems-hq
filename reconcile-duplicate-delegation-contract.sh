#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ac40bb298"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "============================================================"
echo " DUPLICATE DELEGATION CONTRACT — READ-ONLY RECONCILIATION"
echo "============================================================"
echo "MODE=READ_ONLY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

echo
echo "=== A. AUTHORITATIVE DELEGATION PERSISTENCE ==="
grep -n -A180 -B40 -E \
  'createGovernanceDelegation|governance_delegations|INSERT INTO governance_delegations|SELECT.*governance_delegations|delegation_id|package_version' \
  db/governance-runtime.ts \
  db/governance-delegation-persistence.ts \
  2>/dev/null || true

echo
echo "=== B. DELEGATION PERSISTENCE TESTS ==="
sed -n '1,320p' db/governance-delegation-persistence.test.ts

echo
echo "=== C. SEARCH DUPLICATE / IDEMPOTENCY CONTRACT ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='*.bak' \
  -E 'duplicate delegation|already delegated|already.*delegat|existing delegation|idempotent.*delegat|delegat.*idempotent|UNIQUE.*package_id|unique.*package.*version|same.*package.*version|second.*delegat|replay.*delegat' \
  db server routes docs scripts \
  2>/dev/null | head -1400 || true

echo
echo "=== D. LIVE SCHEMA INDEXES / CONSTRAINTS — READ ONLY ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT sql
FROM sqlite_master
WHERE type='table'
  AND name='governance_delegations';

PRAGMA index_list('governance_delegations');

SELECT
  name,
  sql
FROM sqlite_master
WHERE type='index'
  AND tbl_name='governance_delegations'
ORDER BY name;
SQL

echo
echo "=== E. CURRENT LIVE DELEGATION CARDINALITY — READ ONLY ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column

SELECT
  project_id,
  package_id,
  package_version,
  COUNT(*) AS delegation_count
FROM governance_delegations
GROUP BY
  project_id,
  package_id,
  package_version
ORDER BY delegation_count DESC;

SELECT COUNT(*) AS total_delegations
FROM governance_delegations;
SQL

echo
echo "=== F. HISTORICAL CONTRACT / MIGRATION EVIDENCE ==="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'governance_delegations|delegation.*package_version|package_version.*delegation|UNIQUE|idempotent|duplicate' \
  docs/governance \
  docs/checkpoints \
  drizzle \
  scripts \
  2>/dev/null | head -1600 || true

echo
echo "=== G. EXECUTION READ MODEL EXPECTATIONS ==="
grep -n -A180 -B40 -E \
  'governance_delegations|authorization_state|delegation_id|package_version' \
  db/governance-execution-read-repository.ts \
  db/mission-read-repository.ts \
  2>/dev/null || true

echo
echo "============================================================"
echo " RECONCILIATION STOP — NO IMPLEMENTATION"
echo "============================================================"
echo "QUESTION_1=CAN_MULTIPLE_DELEGATION_IDS_EXIST_FOR_ONE_EXACT_PROJECT_PACKAGE_VERSION"
echo "QUESTION_2=DOES_PERSISTENCE_REJECT_OR_IDEMPOTENTLY_RETURN_EXISTING_DELEGATION"
echo "QUESTION_3=IS_PACKAGE_VERSION_LEVEL_UNIQUENESS_ENFORCED_BY_SCHEMA_OR_APPLICATION_LOGIC"
echo "QUESTION_4=DO_DOWNSTREAM_READERS_ASSUME_EXACTLY_ONE_DELEGATION_PER_PACKAGE_VERSION"
echo "QUESTION_5=IS_A_FAIL_CLOSED_DUPLICATE_GUARD_REQUIRED_BEFORE_UI_IMPLEMENTATION"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_DUPLICATE_DELEGATION_BEHAVIOR"
echo "CLEAR_STOPPING_POINT=YES"
