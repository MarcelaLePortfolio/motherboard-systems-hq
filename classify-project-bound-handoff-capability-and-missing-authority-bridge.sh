#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PROJECT-BOUND HANDOFF CAPABILITY AND MISSING AUTHORITY BRIDGE ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "PACKAGE_HANDOFF_CONTRACT_REMAINS_CLOSED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT LIVE HANDOFF STATE ==="
sqlite3 -header -column db/main.db '
SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.status,
  g.project_id AS mission_project_id,
  g.package_id AS mission_package_id,
  g.package_version AS mission_package_version
FROM matilda_canonical_packages c
LEFT JOIN governance_packages g
  ON g.package_id = c.package_id
 AND g.package_version = c.package_version
WHERE c.status = "canonical_approved"
ORDER BY c.created_at DESC;
'

echo
echo "=== SEARCH FOR PERSISTED OPERATIONAL PACKAGE AUTHORITY ==="
sqlite3 -header -column db/main.db "
SELECT
  type,
  name,
  tbl_name,
  sql
FROM sqlite_master
WHERE lower(name) LIKE '%operational%package%'
   OR lower(name) LIKE '%active%package%'
   OR lower(name) LIKE '%selected%package%'
   OR lower(name) LIKE '%mission%package%authority%'
ORDER BY type, name;
"

echo
echo "=== SEARCH FOR PRODUCTION AUTHORITY RUNTIME ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'operational_package_authority|OperationalPackageAuthority|active_package_id|selected_package_id|selectedPackageId|authoritative_package_id|mission_package_authority' \
  db server routes client/src \
  2>/dev/null || true

echo
echo "=== MISSION READ API IDENTITY INPUT ==="
sed -n '1,280p' db/mission-read-repository.ts

echo
echo "=== MISSION READ CALLERS ==="
rg -n -C 18 \
  'getMissionReadModel|loadMission\(' \
  db server routes client/src \
  2>/dev/null || true

echo
echo "=== EXISTING OPERATIONAL AUTHORITY DESIGN EVIDENCE ==="
for file in \
  inspect-operational-package-authority-gap.sh \
  classify-operational-package-authority-boundary.sh \
  classify-operational-package-authority-persistence-ownership.sh \
  inspect-operational-package-authority-database-constraint-model.sh \
  classify-null-project-canonical-package-compatibility.sh \
  inspect-operational-package-authority-runtime-contract.sh
do
  echo "--- ${file} ---"
  if [[ -f "${file}" ]]; then
    rg -n \
      'AUTHORITY_NAME=|AUTHORITATIVE_BINDING=|ONE_ACTIVE_OPERATIONAL_PACKAGE_PER_PROJECT=|EXPLICIT_SELECTION_REQUIRED=|PERSISTENCE_REQUIREMENT=|DATABASE_ENFORCED|MISSION_READ|IMPLEMENTATION_AUTHORIZED=|PROPOSED_IMPLEMENTATION=|NEXT_DECISION=' \
      "${file}" \
      2>/dev/null || true
  else
    echo "MISSING"
  fi
done

echo
echo "=== CAPABILITY CLASSIFICATION ==="
echo "CANONICAL_APPROVED_PACKAGE_EXISTS=YES"
echo "DERIVED_MISSION_PACKAGE_PROJECTION_EXISTS=YES"
echo "DEDICATED_PROJECT_SCOPED_OPERATIONAL_PACKAGE_AUTHORITY_RUNTIME=NOT_ESTABLISHED"
echo "PERSISTED_OPERATIONAL_PACKAGE_SELECTION_EVENT=NOT_ESTABLISHED"
echo "ACTIVE_PROJECT_CONTEXT_IS_OPERATIONAL_PACKAGE_AUTHORITY=NO"
echo "PACKAGE_WORKSPACE_UI_SELECTION_IS_OPERATIONAL_PACKAGE_AUTHORITY=NO"
echo "DELEGATION_IS_OPERATIONAL_PACKAGE_AUTHORITY=NO"
echo "MISSION_CONTROL_IS_OPERATIONAL_PACKAGE_AUTHORITY=NO"
echo "MISSION_READ_IS_OPERATIONAL_PACKAGE_AUTHORITY=NO"

echo
echo "=== MINIMUM MISSING AUTHORITY BRIDGE ==="
echo "MISSING_CAPABILITY=PROJECT_SCOPED_OPERATIONAL_PACKAGE_AUTHORITY"
echo "REQUIRED_BINDING=project_id+package_id+package_version"
echo "ONE_ACTIVE_OPERATIONAL_PACKAGE_PER_PROJECT=YES"
echo "EXPLICIT_SELECTION_REQUIRED=YES"
echo "PERSISTENCE_REQUIRED=YES"
echo "AUDIT_METADATA_REQUIRED=YES"
echo "EXACT_CANONICAL_PACKAGE_REFERENCE_REQUIRED=YES"
echo "PROJECT_PACKAGE_OWNERSHIP_MATCH_REQUIRED=YES"
echo "SUCCESSOR_VERSION_AUTO_ACTIVATION=NO"
echo "CANONICAL_PACKAGE_MUTATION=NO"
echo "MISSION_PACKAGE_PROJECTION_MUTATION=NO"
echo "DELEGATION_CREATION=NO"
echo "VALIDATION_CREATION=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"

echo
echo "=== MISSION READ CONSUMPTION BOUNDARY ==="
echo "MISSION_READ_MAY_CONSUME_OPERATIONAL_PACKAGE_AUTHORITY=YES"
echo "MISSION_READ_MAY_OWN_OPERATIONAL_PACKAGE_AUTHORITY=NO"
echo "MISSION_CONTROL_MAY_CONSUME_DERIVED_MISSION_READ_AFTER_AUTHORITY_RESOLUTION=YES"
echo "MISSION_CONTROL_MAY_SELECT_OPERATIONAL_PACKAGE=NO"
echo "MISSION_CONTROL_INTAKE_READY=NO"

echo
echo "=== SCOPE DETERMINATION ==="
echo "PROJECT_BOUND_HANDOFF_GAP=ESTABLISHED"
echo "PROJECT_BOUND_HANDOFF_REQUIRED_CAPABILITY=DEDICATED_OPERATIONAL_PACKAGE_AUTHORITY_BINDING"
echo "DATABASE_CONSTRAINT_FEASIBILITY=PREVIOUSLY_ESTABLISHED"
echo "PERSISTENCE_OWNERSHIP_MODEL=PREVIOUSLY_CLASSIFIED_AS_DEDICATED_PROJECT_SCOPED_BOUNDARY"
echo "RUNTIME_WRITE_AND_READ_CONTRACT=REQUIRES_CURRENT_RECONCILIATION_BEFORE_IMPLEMENTATION"
echo "PROJECT_BOUND_HANDOFF_IMPLEMENTATION_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=RECONCILE_PREVIOUS_OPERATIONAL_PACKAGE_AUTHORITY_DESIGN_WITH_CURRENT_POST_PACKAGE_HANDOFF_RUNTIME_AND_DEFINE_MINIMUM_PROJECT_BOUND_HANDOFF_WRITE_AND_READ_CONTRACT"
