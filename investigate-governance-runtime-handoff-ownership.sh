#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INVESTIGATE GOVERNANCE RUNTIME HANDOFF OWNERSHIP ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== GOVERNANCE RUNTIME PACKAGE STORE OWNERSHIP ==="
rg -n -C 35 \
  'matilda_canonical_packages|governance_packages|createGovernancePackage|createGovernanceDelegation|canonical_approved|package_version|project_id' \
  db/governance-runtime.ts

echo
echo "=== GOVERNANCE PACKAGE CALLERS ==="
rg -n -C 20 \
  'createGovernancePackage|INSERT INTO governance_packages|governance_packages' \
  server routes db \
  --glob '!db/governance-runtime.ts' \
  --glob '!*.test.ts' \
  2>/dev/null || true

echo
echo "=== CANONICAL APPROVAL WRITE BOUNDARY ==="
rg -n -C 35 \
  'canonical_approved|matilda_canonical_packages|INSERT INTO matilda_canonical_packages|UPDATE matilda_canonical_packages' \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  2>/dev/null || true

echo
echo "=== MISSION READ DURABLE SOURCE ==="
rg -n -C 30 \
  'governance_packages|package_id|package_version|project_id' \
  db/mission-read-repository.ts \
  server \
  --glob '*mission*read*.ts' \
  2>/dev/null || true

echo
echo "=== OWNERSHIP DECISION BOUNDARY ==="
echo "KNOWN_FACT_1=db/governance-runtime.ts_IS_THE_ONLY_NON_TEST_FILE_OBSERVED_REFERENCING_BOTH_PACKAGE_STORES"
echo "KNOWN_FACT_2=governance_packages_HAS_AN_EXISTING_WRITE_BOUNDARY_IN_db/governance-runtime.ts"
echo "KNOWN_FACT_3=CANONICAL_APPROVAL_HAS_A_DISTINCT_PERSISTENCE_BOUNDARY"
echo "KNOWN_FACT_4=MISSION_READ_IS_A_DOWNSTREAM_CONSUMER_OF_governance_packages"
echo "QUESTION_1=DOES_db/governance-runtime.ts_ALREADY_CONTAIN_A_SEMANTIC_BRIDGE_FROM_APPROVED_CANONICAL_IDENTITY_TO_GOVERNANCE_PACKAGE"
echo "QUESTION_2=IF_NOT_IS_createGovernancePackage_A_LEGACY_INDEPENDENT_AUTHORITY_WRITE_OR_A_VALID_DERIVED_PROJECTION_BOUNDARY"
echo "QUESTION_3=WOULD_REUSING_governance_packages_REQUIRE_DUPLICATING_CANONICAL_AUTHORITY_OR_ONLY_MATERIALIZING_A_DERIVED_READ_MODEL"
echo "QUESTION_4=CAN_THE_DERIVED_RECORD_BE_PROVEN_TO_PRESERVE_EXACT_project_id+package_id+package_version_WITHOUT_NEW_AUTHORITY"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_GOVERNANCE_PACKAGE_WRITE_SEMANTICS_FROM_FOCUSED_RUNTIME_EVIDENCE"
