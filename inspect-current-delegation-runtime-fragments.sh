#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CURRENT DELEGATION RUNTIME FRAGMENTS ==="

echo
echo "=== TYPES ==="
sed -n '35,115p' db/governance-runtime.ts

echo
echo "=== TABLE DEFINITION ==="
sed -n '185,245p' db/governance-runtime.ts

echo
echo "=== REQUIRED DELEGATION FIELDS ==="
sed -n '335,390p' db/governance-runtime.ts

echo
echo "=== CREATE GOVERNANCE DELEGATION ==="
sed -n '680,830p' db/governance-runtime.ts

echo
echo "=== PRODUCTION ENTRY POINT ==="
sed -n '1,175p' server/delegation/production-delegation-entry-point.ts

echo
echo "=== PRODUCTION CONSUMER ==="
sed -n '1,130p' server/delegation/production-delegation-consumer.ts

echo
echo "=== IMPLEMENTATION SCRIPT TARGET PATTERNS ==="
grep -n -A12 -B6 \
  -E 'CreateGovernanceDelegationInput|CreatedGovernanceDelegation|CREATE TABLE IF NOT EXISTS governance_delegations|const delegation_id = requireDelegationText|const canonicalPackage = sqlite.prepare|INSERT INTO governance_delegations' \
  db/governance-runtime.ts

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "FAILURE_CLASS=INSPECTION_PATCH_TARGET_MISMATCH"
echo "AUTHORIZED_IMPLEMENTATION_HYPOTHESIS_REJECTED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=REWRITE_PATCH_AGAINST_VERIFIED_CURRENT_SOURCE_FRAGMENTS"
