#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="a060fe38f"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== ESTABLISHED PRODUCTION SEQUENCE ===\n'
echo "SEQUENCE=DELEGATION -> VALIDATION_RESULT -> ENVELOPE_GATE -> ENVELOPE"
echo "VALIDATION_ROUTE_MOUNTED=YES"
echo "ENVELOPE_GATE_ROUTE_MOUNTED=YES"
echo "ENVELOPE_ROUTE_MOUNTED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "NEW_AUTHORITY_AUTHORIZED=NO"

printf '\n=== LATEST HQ LINEAGE — READ ONLY ===\n'
sqlite3 -readonly db/main.db <<'SQL'
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
  d.delegation_id,
  d.package_id,
  d.package_version,
  d.authorization_state,
  CASE
    WHEN v.validation_result_id IS NULL THEN 'VALIDATION_RESULT'
    WHEN g.envelope_gate_id IS NULL THEN 'ENVELOPE_GATE'
    WHEN e.envelope_id IS NULL THEN 'ENVELOPE'
    ELSE 'PRE_ENVELOPE_LINEAGE_COMPLETE'
  END AS first_missing_stage,
  v.validation_result_id,
  v.validation_status,
  g.envelope_gate_id,
  g.gate_status,
  e.envelope_id,
  e.lifecycle_state
FROM latest d
LEFT JOIN governance_validation_results v
  ON v.delegation_id = d.delegation_id
 AND v.package_id = d.package_id
 AND v.package_version = d.package_version
LEFT JOIN governance_envelope_gates g
  ON g.delegation_id = d.delegation_id
 AND g.package_id = d.package_id
 AND g.package_version = d.package_version
 AND g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.delegation_id = d.delegation_id
 AND e.package_id = d.package_id
 AND e.package_version = d.package_version
 AND e.validation_result_id = v.validation_result_id
 AND e.envelope_gate_id = g.envelope_gate_id;
SQL

printf '\n=== VALIDATION AUTHORITY CONTRACT ===\n'
sed -n '1,240p' server/validation/production-validation-entry-point.ts
sed -n '1,220p' server/validation/production-validation-consumer.ts
sed -n '120,290p' server/routes/governance-validation-route.ts

printf '\n=== VALIDATION PERSISTENCE CONTRACT ===\n'
sed -n '838,957p' db/governance-runtime.ts

printf '\n=== GOVERNANCE AUTHORITY REFERENCES ===\n'
grep -RniE \
  'validation_authorized|VALIDATION_AUTHORIZED|validation.*authority|authority.*validation|delegation.*validation|validation.*delegation|AUTHORIZED.*validation' \
  docs server db \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -500 || true

printf '\n=== EXISTING PRODUCTION COMPOSITION ===\n'
grep -RniE \
  'consumeProductionValidationEntryPoint|invokeProductionValidationEntryPoint|createGovernanceValidationResult' \
  server \
  --exclude='*.test.ts' \
  2>/dev/null || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
echo "Q1=Is VALIDATION_RESULT definitively the first absent artifact?"
echo "Q2=What explicit authority does production Validation require?"
echo "Q3=Does AUTHORIZED Delegation satisfy that authority contract?"
echo "Q4=Does Validation verify exact package/version/delegation lineage?"
echo "Q5=Does any existing production path automatically invoke Validation after Delegation?"
echo "Q6=Would Delegation-to-Validation wiring consume existing authority or synthesize authority?"
echo "Q7=If separate authorization is required, where is that authorization expected to originate?"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nDELEGATION_TO_VALIDATION_AUTHORITY_CLASSIFICATION=COMPLETE\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
