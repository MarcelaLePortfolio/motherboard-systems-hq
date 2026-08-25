#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY DELEGATION PROJECT-SCOPE EXTENSION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== EVIDENCE-BASED DETERMINATION ==="
echo "CANONICAL_PACKAGE_HAS_PROJECT_ID=YES"
echo "DELEGATION_HAS_PROJECT_ID=NO"
echo "DELEGATION_REFERENCE=(package_id,package_version)"
echo "PROJECT_ID_PARTICIPATES_IN_DELEGATION_PACKAGE_FK=NO"
echo "EXISTING_DELEGATION_PROJECT_SCOPE_SUFFICIENT=NO"
echo "BOUNDED_PROJECT_SCOPE_EXTENSION_REQUIRED=YES"
echo "RATIONALE=DELEGATION_CAN_REFERENCE_AN_EXISTING_CANONICAL_PACKAGE_VERSION_BUT_DOES_NOT_ITSELF_PERSIST_OR_DATABASE_BIND_PROJECT_SCOPE"

echo
echo "=== CURRENT AUTHORITY MODEL ==="
echo "PACKAGE_APPROVAL_AUTHORIZES_DELEGATION_AUTOMATICALLY=NO"
echo "DELEGATION_REMAINS_EXPLICIT_AUTHORITY_EVENT=YES"
echo "DELEGATION_CREATES_NEW_PACKAGE_MEANING=NO"
echo "DELEGATION_MAY_AUTHORIZE_SCHEDULER=NO"
echo "DELEGATION_MAY_AUTHORIZE_ROUTING=NO"
echo "DELEGATION_MAY_AUTHORIZE_ASSIGNMENT=NO"
echo "DELEGATION_MAY_AUTHORIZE_EXECUTION=NO"
echo "DOWNSTREAM_GOVERNANCE_AUTOMATICALLY_AUTHORIZED=NO"

echo
echo "=== MINIMUM REQUIRED SEMANTIC CONTRACT ==="
echo "DELEGATION_PACKAGE_REFERENCE=(project_id,package_id,package_version)"
echo "PROJECT_ID_SOURCE=EXPLICIT_DELEGATION_INPUT"
echo "PROJECT_ID_MEANING=IDENTIFIES_THE_PROJECT_OWNING_THE_ALREADY_APPROVED_CANONICAL_PACKAGE"
echo "PROJECT_ID_NEW_AUTHORITY=NO"
echo "PROJECT_ID_NEW_PACKAGE_MEANING=NO"
echo "PROJECT_ID_ROUTING_AUTHORITY=NO"
echo "PROJECT_ID_EXECUTION_AUTHORITY=NO"

echo
echo "=== INSPECT TYPE DEFINITIONS ==="
rg -n -C 24 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CreateGovernanceDelegationInput|CreatedGovernanceDelegation|GovernanceDelegation' \
  db server \
  2>/dev/null | head -n 4200 || true

echo
echo "=== INSPECT TABLE CREATION / MIGRATION SURFACE ==="
rg -n -C 35 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TABLE.*governance_delegations|governance_delegations|ALTER TABLE.*governance_delegations' \
  db server scripts migrations \
  2>/dev/null | head -n 5200 || true

echo
echo "=== INSPECT CANONICAL PACKAGE IDENTITY CONSTRAINTS ==="
sqlite3 -header -column db/main.db "
SELECT
  type,
  name,
  tbl_name,
  sql
FROM sqlite_master
WHERE tbl_name = 'matilda_canonical_packages'
   OR (
     type = 'index'
     AND tbl_name = 'matilda_canonical_packages'
   )
ORDER BY type, name;
"

echo
echo "=== INSPECT DELEGATION IDENTITY CONSTRAINTS ==="
sqlite3 -header -column db/main.db "
SELECT
  type,
  name,
  tbl_name,
  sql
FROM sqlite_master
WHERE tbl_name = 'governance_delegations'
   OR (
     type = 'index'
     AND tbl_name = 'governance_delegations'
   )
ORDER BY type, name;
"

echo
echo "=== CHECK PACKAGE IDENTITY UNIQUENESS ACROSS PROJECTS ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  COUNT(DISTINCT project_id) AS distinct_projects,
  GROUP_CONCAT(DISTINCT project_id) AS projects
FROM matilda_canonical_packages
GROUP BY package_id, package_version
HAVING COUNT(DISTINCT project_id) > 1;
"

echo
echo "=== CHECK GOVERNANCE PACKAGE IDENTITY MODEL ==="
sqlite3 -header -column db/main.db "
SELECT
  type,
  name,
  tbl_name,
  sql
FROM sqlite_master
WHERE tbl_name = 'governance_packages'
   OR (
     type = 'index'
     AND tbl_name = 'governance_packages'
   )
ORDER BY type, name;
"

echo
echo "=== SEARCH PROJECT-SCOPED COMPOSITE REFERENCES FOR PRECEDENT ==="
rg -n -C 24 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'project_id.*package_id|package_id.*project_id|projectId.*packageId|packageId.*projectId|FOREIGN KEY.*project_id' \
  db server \
  2>/dev/null | head -n 5200 || true

echo
echo "=== MINIMUM EXTENSION CANDIDATE ==="
echo "ADD_DELEGATION_PROJECT_ID=YES"
echo "TRANSPORT_PROJECT_ID_THROUGH_PRODUCTION_DELEGATION_CONSUMER=YES"
echo "TRANSPORT_PROJECT_ID_THROUGH_PRODUCTION_DELEGATION_ENTRY_POINT=YES"
echo "PERSIST_PROJECT_ID_ON_GOVERNANCE_DELEGATIONS=YES"
echo "VALIDATE_CANONICAL_PACKAGE_BY_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION=YES"
echo "CHANGE_DELEGATION_AUTHORITY_SEMANTICS=NO"
echo "CHANGE_APPROVAL_SEMANTICS=NO"
echo "CHANGE_VALIDATION_SEMANTICS=NO"
echo "CHANGE_ENVELOPE_GATE_SEMANTICS=NO"
echo "CHANGE_ENVELOPE_SEMANTICS=NO"
echo "ADD_SCHEDULER=NO"
echo "ADD_ROUTING=NO"
echo "ADD_ASSIGNMENT=NO"
echo "ADD_EXECUTION=NO"

echo
echo "=== IMPORTANT STRUCTURAL QUESTION ==="
echo "QUESTION=CAN_PROJECT_ID_BE_DATABASE_BOUND_AS_PART_OF_A_COMPOSITE_FOREIGN_KEY_WITHOUT_CHANGING_CANONICAL_PACKAGE_IDENTITY_CONSTRAINTS"
echo "IF_YES=USE_DATABASE_ENFORCED_COMPOSITE_PROJECT_PACKAGE_REFERENCE"
echo "IF_NO=DO_NOT_SPECULATIVELY_CHANGE_CANONICAL_PACKAGE_IDENTITY;CLASSIFY_APPLICATION_LEVEL_PROJECT_SCOPE_CHECK_AS_MINIMUM_SAFE_BOUNDARY_OR_DEFINE_SEPARATE_SCHEMA_UNIT"

echo
echo "=== SCOPE BOUNDARY ==="
echo "COMPLETED_DELEGATION_PACKAGE_ROOT_RECONCILIATION_REOPENED=NO"
echo "KNOWN_VALIDATION_GATE_ENVELOPE_LINEAGE_DEFECT_REOPENED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "CURRENT_ACTIVITY=CLASSIFICATION_ONLY"

echo
echo "=== NEXT DECISION ==="
echo "NEXT_DECISION=DETERMINE_EXACT_SCHEMA_SAFE_MECHANISM_FOR_PROJECT_SCOPED_DELEGATION_REFERENCE_THEN_PRESENT_BOUNDED_IMPLEMENTATION_UNIT_FOR_AUTHORIZATION"
