#!/usr/bin/env bash
set -euo pipefail

echo "=== VALIDATION ROOT RECONCILIATION — SCOPE INSPECTION ==="

echo
echo "=== PRIOR DELEGATION RECONCILIATION PATTERN ==="
git show --stat --oneline 5ff310bb 2>/dev/null || true
git show --format=fuller --find-renames 5ff310bb -- \
  db/governance-runtime.ts \
  scripts/validate-canonical-delegation-root.sh \
  docs/governance \
  drizzle \
  2>/dev/null || true

echo
echo "=== CURRENT VALIDATION SCHEMA ==="
sed -n '210,285p' db/governance-runtime.ts
sed -n '1,90p' drizzle/0004_governance_lifecycle_artifacts.sql

echo
echo "=== CURRENT VALIDATION WRITE PATH ==="
sed -n '811,930p' db/governance-runtime.ts

echo
echo "=== CANONICAL DELEGATION VALIDATION SCRIPT ==="
sed -n '1,280p' scripts/validate-canonical-delegation-root.sh 2>/dev/null || true

echo
echo "=== VALIDATION TEST SURFACE ==="
find db server scripts -type f \
  \( -iname '*validation*.test.ts' -o -iname '*validation*.spec.ts' -o -iname '*validation*.sh' \) \
  -not -path '*/node_modules/*' \
  -print | sort

echo
echo "=== SCHEMA MIGRATION PATTERN ==="
rg -n -C 8 \
  'governance_delegations|matilda_canonical_packages|FOREIGN KEY|ALTER TABLE|RENAME TO|PRAGMA foreign_keys' \
  drizzle db scripts \
  --glob '!*.bak' \
  2>/dev/null | head -n 700

echo
echo "=== VALIDATION ROOT DEPENDENCIES ==="
rg -n -C 6 \
  'governance_validation_results|REFERENCES governance_packages|REFERENCES matilda_canonical_packages|createGovernanceValidationResult' \
  db server scripts drizzle \
  --glob '!*.bak' \
  2>/dev/null | head -n 800

echo
echo "=== SCOPE CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=DELEGATION_CANONICAL_ROOT_COMPLETE"
echo "PARTIALLY_IMPLEMENTED=DOWNSTREAM_GOVERNANCE_LINEAGE"
echo "CURRENT_SCOPE=VALIDATION_ROOT_RECONCILIATION_READINESS"
echo "DEFERRED=ENVELOPE_GATE_ENVELOPE_OPERATIONAL_INTAKE_ROOT_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
