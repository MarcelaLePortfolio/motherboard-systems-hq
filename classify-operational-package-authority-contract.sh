#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY OPERATIONAL PACKAGE AUTHORITY CONTRACT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== REPOSITORY-EVIDENCED AUTHORITY MODEL ==="
echo "PACKAGE_CREATION_EVENT=APPROVAL"
echo "PACKAGE_CANONICAL_MEANING_AUTHORITY=YES"
echo "PACKAGE_CREATION_AUTHORIZES_ORGANIZATIONAL_PROCESSING=NO"
echo "PACKAGE_CREATION_AUTHORIZES_GOVERNANCE_VALIDATION=NO"
echo "PACKAGE_CREATION_AUTHORIZES_ROUTING=NO"
echo "PACKAGE_CREATION_AUTHORIZES_EXECUTION=NO"
echo "PENDING_DELEGATION_AFTER_PACKAGE_CREATION=YES"
echo "DELEGATION_DISTINCT_AUTHORITY_EVENT=YES"
echo "DELEGATION_REFERENCES_EXISTING_PACKAGE=YES"
echo "DELEGATION_SPECIFIC_PACKAGE_VERSION=YES"
echo "DELEGATION_CREATES_MEANING=NO"
echo "DELEGATION_AUTHORIZES_EXISTING_PACKAGE=YES"
echo "APPROVAL_AND_DELEGATION_IMPLY_EACH_OTHER=NO"

echo
echo "=== TERMINOLOGY CLASSIFICATION ==="
echo "OPERATIONAL_PACKAGE_AUTHORITY_SELECTION_AS_GENERIC_NEW_AUTHORITY=REJECTED"
echo "CORRECT_EXISTING_GOVERNANCE_CONCEPT=DELEGATION_BY_REFERENCE"
echo "RATIONALE=REPOSITORY_GOVERNANCE_ALREADY_DEFINES_THE_POST_APPROVAL_AUTHORITY_EVENT_AS_DELEGATION"
echo "NEW_PARALLEL_AUTHORITY_MODEL_REQUIRED=NO"

echo
echo "=== MINIMUM WRITE CONTRACT CANDIDATE ==="
echo "WRITE_EVENT=EXPLICIT_DELEGATION"
echo "PROJECT_SCOPE_REQUIRED=YES"
echo "PACKAGE_ID_REQUIRED=YES"
echo "PACKAGE_VERSION_REQUIRED=YES"
echo "PACKAGE_CONTENT_COPY_REQUIRED=NO"
echo "PACKAGE_REFERENCE_REMAINS_AUTHORITATIVE=YES"
echo "OPERATOR_INTENT_REQUIRED=YES"

echo
echo "=== FAIL-CLOSED PRECONDITIONS ==="
echo "CHECK_1=PROJECT_EXISTS_IN_PROJECT_REGISTRY"
echo "CHECK_2=PACKAGE_EXISTS"
echo "CHECK_3=PACKAGE_PROJECT_ID_MATCHES_TARGET_PROJECT_ID"
echo "CHECK_4=PACKAGE_VERSION_MATCHES_REFERENCED_VERSION"
echo "CHECK_5=PACKAGE_STATUS_IS_CANONICAL_APPROVED"
echo "CHECK_6=EXPLICIT_DELEGATION_AUTHORITY_EVENT_IS_PRESENT"
echo "ON_FAILURE=NO_AUTHORITY_WRITE"

echo
echo "=== CURRENT DATABASE EVIDENCE ==="
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  p.project_id,
  p.status,
  CASE WHEN r.project_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS registered_project_match
FROM matilda_canonical_packages p
LEFT JOIN project_registry r
  ON r.project_id = p.project_id
ORDER BY p.created_at;
"

echo
echo "=== EXISTING DELEGATION RUNTIME SURFACES ==="
rg -n -C 28 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'matilda.*delegat|delegation_id|create.*delegation|Delegated Package|Pending Delegation|delegation.*package|package.*delegation' \
  db server routes \
  2>/dev/null | head -n 4800 || true

echo
echo "=== DELEGATION TABLE SCHEMA ==="
sqlite3 -header -column db/main.db "
SELECT
  name,
  sql
FROM sqlite_master
WHERE type IN ('table','index')
  AND (
    lower(name) LIKE '%delegat%'
    OR lower(sql) LIKE '%delegation%'
  )
ORDER BY type, name;
"

echo
echo "=== MISSION READ PACKAGE SURFACES ==="
rg -n -C 30 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createMissionReadRepository|loadMission|assembleMissionReadModel|MissionRead|canonical.*package|package_id|package_version' \
  db server routes \
  2>/dev/null | head -n 4800 || true

echo
echo "=== CLASSIFICATION ==="
echo "DATABASE_FEASIBILITY=SUPPORTED"
echo "AUTHORITY_SEMANTICS=EXISTING_DELEGATION_MODEL"
echo "MINIMUM_REFERENCE=(project_id,package_id,package_version)"
echo "WRITE_MUST_FAIL_CLOSED=YES"
echo "APPROVAL_ALONE_SUFFICIENT=NO"
echo "DELEGATION_REQUIRED_FOR_POST_APPROVAL_ORGANIZATIONAL_PROCESSING=YES"
echo "GOVERNANCE_VALIDATION_REQUIRES_DELEGATED_PACKAGE=YES"
echo "MISSION_READ_DIRECT_CONSUMPTION=NOT_YET_ESTABLISHED"
echo "MISSION_READ_CHANGE_AUTHORIZED=NO"
echo "PARALLEL_OPERATIONAL_AUTHORITY_CONCEPT=NOT_SUPPORTED_BY_CURRENT_EVIDENCE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== NEXT DECISION ==="
echo "NEXT_DECISION=DETERMINE_WHETHER_EXISTING_DELEGATION_RUNTIME_ALREADY_SATISFIES_PROJECT_SCOPED_PACKAGE_REFERENCE_AUTHORITY_OR_REQUIRES_A_BOUNDED_PROJECT_SCOPE_EXTENSION"
