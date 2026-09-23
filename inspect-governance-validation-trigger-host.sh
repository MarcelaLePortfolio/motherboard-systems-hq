#!/usr/bin/env bash
set -euo pipefail

printf '\n=== CURRENT CLASSIFICATION ===\n'
echo "LEGACY_OPERATOR_ADAPTER=DISCONNECTED_NOT_DELETED"
echo "PRODUCTION_VALIDATION_ROUTE=MOUNTED"
echo "CURRENT_OPERATOR_TRIGGER=NOT_ESTABLISHED"
echo "RESTORE_LEGACY_DATABASE_RUNTIME=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== APPROVALS / EXECUTIVE ACTION SURFACES ===\n'
find client/src -type f \
  \( -path '*approvals*' -o -path '*executive*' -o -path '*mission-control*' \) \
  -print | sort

printf '\n=== DELEGATION ACTION IMPLEMENTATION ===\n'
grep -RniE \
  'delegate|delegation|awaiting_delegation|AUTHORIZED|authorization_state' \
  client/src/approvals client/src \
  --exclude='*.test.ts' \
  2>/dev/null | head -700 || true

printf '\n=== BUTTON / ACTION PATTERNS NEAR DELEGATION ===\n'
grep -RniE \
  '<button|onClick|action|Delegate|Request Changes|Approve' \
  client/src/approvals \
  --exclude='*.test.ts' \
  2>/dev/null | head -700 || true

printf '\n=== CURRENT CLIENT API MODULES ===\n'
find client/src -type f \
  \( -iname '*Api.ts' -o -iname '*api.ts' \) \
  -print | sort

printf '\n=== GOVERNANCE VALIDATION CLIENT REFERENCES ===\n'
grep -RniE \
  '/api/governance/validation|governance.?validation|validation_result_id|validation_status' \
  client/src \
  2>/dev/null || true

printf '\n=== VALIDATION ELIGIBILITY IMPLEMENTATION ===\n'
sed -n '1,240p' db/governance-lifecycle-enforcement.ts

printf '\n=== VALIDATION ROUTE ===\n'
sed -n '1,320p' server/routes/governance-validation-route.ts

printf '\n=== VALIDATION PERSISTENCE ===\n'
sed -n '838,940p' db/governance-runtime.ts

printf '\n=== ELIGIBILITY CALLERS ===\n'
grep -RniE \
  'assertValidationEligible' \
  server db \
  --exclude='*.test.ts' \
  2>/dev/null || true

printf '\n=== APPROVALS / DELEGATION TEST PATTERNS ===\n'
find client/src -type f \
  \( -path '*approvals*test*' -o -path '*delegat*test*' \) \
  -print | sort | while read -r f
do
  printf '\n----- %s -----\n' "$f"
  grep -n -C 4 -E \
    'Delegate|delegation|button|onClick|awaiting_delegation|AUTHORIZED' \
    "$f" 2>/dev/null || true
done

printf '\n=== LIVE HQ STATE — READ ONLY ===\n'
sqlite3 -readonly db/main.db <<'SQL' 2>/dev/null || true
.headers on
.mode column

WITH latest AS (
  SELECT *
  FROM governance_delegations
  WHERE project_id = 'hq'
  ORDER BY created_at DESC
  LIMIT 1
)
SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  delegated_by,
  created_at
FROM latest;

SELECT
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  created_at
FROM governance_validation_results
WHERE delegation_id = (
  SELECT delegation_id
  FROM governance_delegations
  WHERE project_id = 'hq'
  ORDER BY created_at DESC
  LIMIT 1
);
SQL

printf '\n=== DECISION QUESTIONS ===\n'
echo "Q1=Which existing Executive/Approvals component owns the post-Delegation user interaction?"
echo "Q2=Is there already a natural explicit operator action slot after successful Delegation?"
echo "Q3=Can that action call the existing /api/governance/validation route without creating new lifecycle authority?"
echo "Q4=Does the current route enforce that the referenced Delegation is AUTHORIZED?"
echo "Q5=If not, must eligibility enforcement be added before any UI trigger is safe?"
echo "Q6=Can the current canonical validation schema represent the operator-triggered action without reviving validation_actor?"
echo "Q7=What is the smallest bounded implementation surface?"
echo "Q8=What tests would prove no automatic advancement to Envelope, Assignment, Routing, or Execution?"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nGOVERNANCE_VALIDATION_TRIGGER_HOST_INSPECTION=COMPLETE\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
