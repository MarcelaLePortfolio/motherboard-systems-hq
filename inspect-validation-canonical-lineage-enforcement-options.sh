#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION CANONICAL LINEAGE ENFORCEMENT OPTIONS ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "LEGACY_CORRIDOR_SMOKE_READ_LINEAGE_REQUIRED=YES"
echo "LEGACY_CORRIDOR_SMOKE_CANONICAL_AUTHORITY=NO"
echo "CANONICAL_PACKAGE_EXISTS=YES"
echo "CANONICAL_DELEGATION_CURRENTLY_EXISTS=NO"
echo "CURRENT_VALIDATION_TABLE_CANONICAL_WRITE_TEST=INCONCLUSIVE_NO_CANONICAL_DELEGATION"
echo "CURRENT_DATABASE_FOREIGN_KEY_CHECK=CURRENTLY_NOT_CLEAN"
echo "STALE_VALIDATION_DELEGATION_PARENT=GOVERNANCE_DELEGATIONS_LEGACY_ROOT"
echo "NEW_VALIDATION_REQUIRES_AUTHORIZED_CANONICAL_DELEGATION=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== GOVERNING VALIDATION / DELEGATION CONTRACT ==="
grep -nE -C 12 \
  'Relationship To Governance Validation|prerequisite for Governance Validation|only evaluate authorized interpretations|Governance Validation consumes Delegation|does not create Delegation' \
  docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md \
  2>/dev/null || true

echo
echo "=== VALIDATION CHARTER ==="
if [[ -f docs/governance/GOVERNANCE_VALIDATION_CHARTER.md ]]; then
  cat docs/governance/GOVERNANCE_VALIDATION_CHARTER.md
fi

echo
echo "=== CURRENT VALIDATION / DELEGATION FOREIGN KEYS ==="
for table in governance_delegations governance_validation_results; do
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== CURRENT ROOT MEMBERSHIP ==="
sqlite3 -header -column db/main.db "
SELECT 'legacy_package' AS artifact_class, package_id AS artifact_id, package_version AS artifact_version
FROM governance_packages
UNION ALL
SELECT 'canonical_package', package_id, package_version
FROM matilda_canonical_packages
ORDER BY artifact_class, artifact_id;
"

echo
echo "=== SEARCH FOR DATABASE-ENFORCED COEXISTENCE PATTERNS ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TRIGGER|BEFORE INSERT|BEFORE UPDATE|RAISE\(|CHECK \(|CREATE VIEW|INSTEAD OF|UNION ALL|legacy.*canonical|canonical.*legacy' \
  db drizzle server scripts docs \
  2>/dev/null | head -n 2600

echo
echo "=== SEARCH FOR APP-LAYER LINEAGE ENFORCEMENT ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createGovernanceValidationResult|createGovernanceDelegation|authorization_state|AUTHORIZED|missing Delegation lineage|Delegation lineage|canonical package|matilda_canonical_packages' \
  db/governance-runtime.ts server/routes scripts/smoke-governance-validation-runtime.mjs scripts/validate-canonical-delegation-root.sh \
  2>/dev/null | head -n 2600

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=LEGACY_VALIDATION_READ_LINEAGE_MUST_BE_PRESERVED"
echo "VERIFIED_OUTCOME=NEW_VALIDATION_REQUIRES_CANONICAL_PACKAGE_AND_DELEGATION_AUTHORITY"
echo "ARCHITECTURAL_QUESTION=CAN_ONE_VALIDATION_PERSISTENCE_SURFACE_ENFORCE_NEW_CANONICAL_AUTHORITY_WITHOUT_FALSELY_REPARENTING_HISTORICAL_ROWS"
echo "ALTERNATIVE_IF_NO=SEPARATE_CANONICAL_VALIDATION_PERSISTENCE_WITH_EXPLICIT_READ_COMPATIBILITY"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_MINIMUM_DATABASE_ENFORCED_COEXISTENCE_MODEL"
