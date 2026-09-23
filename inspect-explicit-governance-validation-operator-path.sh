#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cfcd2c644"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== ESTABLISHED CLASSIFICATION ===\n'
echo "LIVE_FIRST_MISSING_STAGE=VALIDATION_RESULT"
echo "DELEGATION_IS_VALIDATION_PREREQUISITE=YES"
echo "DELEGATION_ITSELF_AUTHORIZES_VALIDATION=NO"
echo "VALIDATION_PERSISTENCE_EXISTS=YES"
echo "VALIDATION_PERSISTENCE_SEMANTIC_ELIGIBILITY_ENFORCEMENT=NOT_ESTABLISHED"
echo "NEXT_BOUNDARY=EXPLICIT_OPERATOR_GOVERNANCE_VALIDATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "NEW_AUTHORITY_AUTHORIZED=NO"

printf '\n=== CANONICAL GOVERNANCE VALIDATION SPECIFICATION ===\n'
for f in \
  docs/governance/GOVERNANCE_VALIDATION_SPECIFICATION.md \
  docs/governance/MATILDA_GOVERNANCE_VALIDATION_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_GOVERNANCE_VALIDATION_VALIDATED_2026-07-05.md \
  docs/governance-validation-eligibility-authorization-assessment.md \
  docs/governance-validation-eligibility-implementation-readiness-assessment.md \
  docs/governance-validation-eligibility-implementation-authorization.md \
  docs/governance-lifecycle-authority-expansion-assessment.md \
  docs/governance-lifecycle-authority-expansion-assessment-continuation.md
do
  if [ -f "$f" ]; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,360p' "$f"
  fi
done

printf '\n=== VALIDATION ELIGIBILITY ENFORCEMENT ===\n'
sed -n '1,300p' db/governance-lifecycle-enforcement.ts 2>/dev/null || true

printf '\n=== EXECUTION READ REPOSITORY VALIDATION CHECK ===\n'
sed -n '90,230p' db/governance-execution-read-repository.ts 2>/dev/null || true

printf '\n=== MATILDA DELEGATION RUNTIME ===\n'
sed -n '1,240p' db/matilda-delegation-runtime.ts 2>/dev/null || true

printf '\n=== VALIDATION ROUTE AND SERVER MOUNT ===\n'
sed -n '1,340p' server/routes/governance-validation-route.ts 2>/dev/null || true
grep -RniE \
  'createGovernanceValidationRouter|governance-validation-route|/api/governance/validation' \
  server client \
  --exclude='*.test.ts' \
  2>/dev/null | head -300 || true

printf '\n=== CLIENT / OPERATOR VALIDATION SURFACE SEARCH ===\n'
grep -RniE \
  'Governance Validation|governance validation|VALIDATION_PASSED|VALIDATION_FAILED|validation_status|validation_result_id|/api/governance/validation|authorized_for_governance_validation|PENDING_GOVERNANCE_VALIDATION' \
  client/src server \
  --exclude='*.test.ts' \
  2>/dev/null | head -600 || true

printf '\n=== EXPLICIT OPERATOR / USER AUTHORITY REFERENCES ===\n'
grep -RniE \
  'explicit operator.*validation|operator.*Governance Validation|operator.*governance validation|user.*validation|validation.*operator|validation.*user|authorize.*validation|validation.*authoriz|complete governance review' \
  docs server db client/src \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -700 || true

printf '\n=== HISTORICAL VALIDATED IMPLEMENTATION REFERENCES ===\n'
git log --all \
  --date=iso \
  --pretty=format:'%h %ad %s' \
  --grep='governance validation\|validation eligibility\|validation authority' -i \
  -n 100 || true

printf '\n=== HISTORICAL VALIDATION FILE HISTORY ===\n'
git log --all --follow --oneline -- \
  server/routes/governance-validation-route.ts \
  2>/dev/null | head -100 || true

printf '\n=== LIVE HQ DELEGATION — READ ONLY ===\n'
sqlite3 -readonly db/main.db <<'SQL' 2>/dev/null || true
.headers on
.mode column

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
WHERE project_id = 'hq'
ORDER BY created_at DESC
LIMIT 5;

SELECT
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  validation_timestamp,
  created_at
FROM governance_validation_results
WHERE delegation_id IN (
  SELECT delegation_id
  FROM governance_delegations
  WHERE project_id = 'hq'
)
ORDER BY created_at DESC
LIMIT 20;
SQL

printf '\n=== DECISION QUESTIONS ===\n'
echo "Q1=What actor owns the explicit decision to begin or complete Governance Validation?"
echo "Q2=What persisted or request-level evidence represents that operator authority?"
echo "Q3=Does an existing UI or API caller already invoke POST /api/governance/validation?"
echo "Q4=Was such a caller previously validated and later disconnected?"
echo "Q5=Where is assertValidationEligible currently invoked in the production path?"
echo "Q6=Does the current Validation route enforce AUTHORIZED Delegation before persistence?"
echo "Q7=If the route does not enforce it, is that an already-documented defect or deliberate separation?"
echo "Q8=Is the live workflow missing only an existing operator trigger/presentation?"
echo "Q9=Would adding an automatic Delegation-to-Validation call violate the explicit-operator boundary?"
echo "Q10=What is the smallest next action that preserves Delegation != Validation != Envelope != Execution?"

printf '\n=== WORKTREE — PRESERVE ===\n'
git status --short

printf '\nEXPLICIT_GOVERNANCE_VALIDATION_OPERATOR_PATH_INSPECTION=COMPLETE\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
