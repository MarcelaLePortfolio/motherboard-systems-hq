#!/usr/bin/env bash
set -euo pipefail

echo "=== CORRIDOR 1 — VALIDATION LINEAGE SUCCESSOR BOUNDARY ==="

echo
echo "=== DELEGATION RECONCILIATION CLOSURE ==="
sed -n '1,280p' docs/governance/PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_CLOSURE_2026-08-23.md

echo
echo "=== VALIDATION CREATION IMPLEMENTATION ==="
sed -n '680,930p' db/governance-runtime.ts

echo
echo "=== PRODUCTION VALIDATION ENTRY POINT ==="
sed -n '1,260p' server/validation/production-validation-entry-point.ts

echo
echo "=== VALIDATION TESTS ==="
sed -n '1,360p' server/validation/production-validation-entry-point.test.ts

echo
echo "=== VALIDATION AUTHORITY / PACKAGE LINEAGE DOCUMENTATION ==="
rg -n -C 6 \
  'Governance Validation|Validation Result|Delegation|Canonical Package|Package lineage|package root|governance_packages|matilda_canonical_packages' \
  docs/governance \
  docs/checkpoints/GOVERNANCE_RUNTIME_ACTIVATION_CORRIDOR_1_FINDINGS.md \
  docs/checkpoints/PROJECT_SCOPED_MISSION_CONTROL_CORRIDOR_2_COMPLETE.md \
  docs/checkpoints/PROJECT_SCOPED_MISSION_CONTROL_CORRIDOR_3_INVESTIGATION_DR.md \
  2>/dev/null | head -n 800

echo
echo "=== VALIDATION CREATION GUARDS ==="
rg -n -C 10 \
  'createGovernanceValidationResult|delegation_id|authorization_state|AUTHORIZED|package_id|package_version|governance_packages|matilda_canonical_packages' \
  db/governance-runtime.ts \
  server/validation \
  2>/dev/null | head -n 700

echo
echo "=== FALSIFICATION SEARCH: ALTERNATE VALIDATION ROOT OR BRIDGE ==="
rg -n \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'canonical.*validation|validation.*canonical|delegation.*validation|validation.*delegation|package.*validation.*bridge|validation.*package.*bridge|validation.*root|root.*validation|canonical.*governance_packages|governance_packages.*canonical' \
  db server routes scripts docs architecture drizzle \
  2>/dev/null | head -n 800

echo
echo "=== INSPECTION COMPLETE ==="
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "SCOPE_QUESTION=IS_VALIDATION_THE_NEXT_SMALLEST_UNRECONCILED_CANONICAL_LINEAGE_BOUNDARY"
