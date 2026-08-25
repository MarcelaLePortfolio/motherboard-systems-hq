#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY GOVERNANCE PACKAGE WRITE SEMANTICS ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== PRODUCTION PACKAGE PIPELINE ==="
rg -n -C 45 \
  'createGovernancePackage|create_governance_package|package_id|package_version|project_id|requested_outcome|authority|authorized' \
  server/package/production-package-consumer.ts \
  server/package/production-package-entry-point.ts \
  server/routes/governance-package-route.ts \
  db/governance-runtime.ts

echo
echo "=== GOVERNANCE PACKAGE INPUT CONTRACT ==="
rg -n -C 35 \
  'CreateGovernancePackageInput|CreatedGovernancePackage|createGovernancePackage' \
  db/governance-runtime.ts \
  server/package \
  --glob '*.ts'

echo
echo "=== GOVERNANCE PACKAGE TABLE CONTRACT ==="
rg -n -C 45 \
  'CREATE TABLE.*governance_packages|INSERT INTO governance_packages|governance_packages' \
  db \
  --glob '*.ts' \
  --glob '!*.bak'

echo
echo "=== CANONICAL PACKAGE SEMANTIC SOURCE ==="
rg -n -C 25 \
  'approved_interpretation|approved_work|approved_artifacts|approved_scope|approved_constraints|approved_expected_outcome|canonical_approved' \
  db/matilda-canonical-package-runtime.ts

echo
echo "=== CALLER AUTHORITY ORIGIN TEST ==="
rg -n -C 30 \
  'consumeProductionPackageEntryPoint|invokeProductionPackageEntryPoint|/api/governance/package|requested_outcome|scope|containment|constraints|success_criteria' \
  server routes \
  --glob '*.ts' \
  --glob '!*.test.ts'

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_governance_packages_CURRENTLY_CREATED_FROM_CALLER_SUPPLIED_PACKAGE_SEMANTICS_RATHER_THAN_FROM_matilda_canonical_packages"
echo "QUESTION_2=DOES_THE_PRODUCTION_PACKAGE_PIPELINE_REQUIRE_OR_VERIFY_canonical_approved_SOURCE_PROVENANCE"
echo "QUESTION_3=DOES_createGovernancePackage_PRESERVE_AN_EXACT_PREEXISTING_CANONICAL_project_id+package_id+package_version_OR_CREATE_AN_INDEPENDENT_GOVERNANCE_RECORD_FROM_INPUT"
echo "QUESTION_4=CAN_EXISTING_governance_packages_BE_REUSED_AS_A_DERIVED_HANDOFF_READ_MODEL_WITHOUT_RETAINING_THE_CURRENT_INDEPENDENT_WRITE_SEMANTICS"
echo "QUESTION_5=IS_A_NEW_BOUNDED_CANONICAL_TO_GOVERNANCE_PROJECTION_REQUIRED_AT_THE_APPROVAL_PERSISTENCE_BOUNDARY"

echo
echo "=== CURRENT EVIDENCE BOUNDARY ==="
echo "CANONICAL_PACKAGE_AUTHORITY_ROOT=matilda_canonical_packages"
echo "CANONICAL_APPROVAL_STATUS=canonical_approved"
echo "MISSION_READ_DURABLE_PACKAGE_SOURCE=governance_packages"
echo "MISSION_READ_IS_HANDOFF_OWNER=NO"
echo "MISSION_CONTROL_IS_HANDOFF_OWNER=NO"
echo "DELEGATION_IS_HANDOFF_OWNER=NO"
echo "GOVERNANCE_PACKAGE_WRITE_PATH_EXISTS=YES"
echo "GOVERNANCE_PACKAGE_WRITE_AUTHORITY_SEMANTICS=UNDER_INVESTIGATION"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=DETERMINE_WHETHER_EXISTING_GOVERNANCE_PACKAGE_WRITE_IS_DERIVED_PROJECTION_OR_LEGACY_INDEPENDENT_PACKAGE_CREATION"
