#!/usr/bin/env bash
set -euo pipefail

echo "=== CORRIDOR 1 — VALIDATION CANONICAL ROOT READINESS ==="

echo
echo "=== VALIDATION AUTHORITY CONTRACT ==="
sed -n '1,340p' docs/governance/GOVERNANCE_VALIDATION_CHARTER.md

echo
echo "=== VALIDATION ELIGIBILITY FINDINGS ==="
for f in \
  docs/governance-validation-eligibility-authorization-assessment.md \
  docs/governance-validation-pass-justification-boundary-finding.md \
  docs/governance-validation-pass-justification-scope-correction.md \
  docs/governance-validation-status-canonicality-finding.md; do
  if [[ -f "$f" ]]; then
    echo "--- $f ---"
    sed -n '1,320p' "$f"
  fi
done

echo
echo "=== PRODUCTION VALIDATION CONSUMER ==="
sed -n '1,300p' server/validation/production-validation-consumer.ts

echo
echo "=== PRODUCTION VALIDATION ENTRY POINT ==="
sed -n '1,280p' server/validation/production-validation-entry-point.ts

echo
echo "=== VALIDATION ROUTE ==="
sed -n '1,320p' server/routes/governance-validation-route.ts

echo
echo "=== VALIDATION PERSISTENCE FUNCTION ==="
sed -n '800,930p' db/governance-runtime.ts

echo
echo "=== EXACT DELEGATION LINEAGE ENFORCEMENT SEARCH ==="
rg -n -C 8 \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'authorization_state|AUTHORIZED|delegation_id|package_id|package_version|createGovernanceValidationResult|consumeProductionValidationEntryPoint|invokeProductionValidationEntryPoint' \
  db/governance-runtime.ts \
  server/validation \
  server/routes/governance-validation-route.ts \
  scripts \
  2>/dev/null | head -n 900

echo
echo "=== CANONICAL PACKAGE / DELEGATION / VALIDATION LIVE ROWS ==="
if command -v sqlite3 >/dev/null 2>&1 && [[ -f db/main.db ]]; then
  echo "--- canonical packages ---"
  sqlite3 -header -column db/main.db \
    "SELECT package_id, package_version, project_id, status FROM matilda_canonical_packages ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  echo "--- delegations ---"
  sqlite3 -header -column db/main.db \
    "SELECT delegation_id, package_id, package_version, authorization_state, delegated_by FROM governance_delegations ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true

  echo "--- validation results ---"
  sqlite3 -header -column db/main.db \
    "SELECT validation_result_id, package_id, package_version, delegation_id, validation_status FROM governance_validation_results ORDER BY rowid DESC LIMIT 20;" \
    2>/dev/null || true
fi

echo
echo "=== FALSIFICATION SEARCH ==="
rg -n \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'canonical-root-validation|canonical validation root|validation.*matilda_canonical_packages|matilda_canonical_packages.*validation|validation.*governance_delegations|governance_delegations.*validation|legacy governance_packages.*validation|validation.*legacy governance_packages' \
  db server routes scripts docs \
  2>/dev/null | head -n 900

echo
echo "=== CURRENT CLASSIFICATION ==="
echo "DELEGATION_CANONICAL_ROOT=VERIFIED"
echo "VALIDATION_PACKAGE_ROOT=LEGACY_GOVERNANCE_PACKAGES"
echo "VALIDATION_REQUIRES_DELEGATION_LINEAGE=VERIFIED"
echo "VALIDATION_CANONICAL_ROOT_RECONCILIATION=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
