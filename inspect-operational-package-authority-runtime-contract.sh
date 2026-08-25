#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPERATIONAL PACKAGE AUTHORITY RUNTIME CONTRACT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED DATABASE BOUNDARY ==="
echo "COMPOSITE_CONSTRAINT_FEASIBILITY=SUPPORTED"
echo "PROJECT_BOUND_AUTHORITY_PROBE=PASS"
echo "AUTHORITY_TABLE_PROJECT_ID_PRIMARY_KEY=SUPPORTED"
echo "PARENT_SUPPORTING_UNIQUE_KEY=(project_id,package_id,package_version)"
echo "PROJECT_REGISTRY_FOREIGN_KEY=REQUIRED"
echo "CANONICAL_PROJECT_PACKAGE_VERSION_FOREIGN_KEY=REQUIRED"
echo "HISTORICAL_BACKFILL_REQUIRED=NO"
echo "DOWNSTREAM_GOVERNANCE_RECONCILIATION_IN_SCOPE=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== SEARCH EXISTING ACTIVE-CONTEXT RUNTIME PATTERNS ==="
rg -n -C 20 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'active.*context|setActive|getOrCreateActive|INSERT OR REPLACE|source.*action.*updated_at|project_id.*PRIMARY KEY' \
  db server routes \
  2>/dev/null | head -n 3600 || true

echo
echo "=== SEARCH CANONICAL PACKAGE READ AND APPROVAL SURFACES ==="
rg -n -C 22 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'matilda_canonical_packages|approve_canonical_package|canonical_package|CanonicalPackage|canonical package' \
  db server routes \
  2>/dev/null | head -n 4200 || true

echo
echo "=== SEARCH PROJECT-SCOPED READ CONTRACTS ==="
rg -n -C 18 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'requireProjectId|requireText\(.*project|WHERE .*project_id = \?|belongs to project|project-scoped|project scoped' \
  db server routes \
  2>/dev/null | head -n 3600 || true

echo
echo "=== SEARCH MISSION READ INTEGRATION SURFACE ==="
rg -n -C 24 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createMissionReadRepository|loadMission|assembleMissionReadModel|MissionRead|mission-read' \
  db server routes \
  2>/dev/null | head -n 3600 || true

echo
echo "=== SEARCH MUTATION API CONVENTIONS ==="
rg -n -C 22 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'export function (set|select|activate|approve|create|update)|INSERT OR REPLACE INTO|ON CONFLICT|transaction\(\(\) =>|statusCode = 400|res\.status\(400\)' \
  db server routes \
  2>/dev/null | head -n 4200 || true

echo
echo "=== SEARCH OPERATOR AUTHORITY SEMANTICS ==="
rg -n -C 20 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'operator|authority|authoritative|selection|selected package|active package|operational package|explicit.*approval|explicit.*delegation' \
  db server routes docs/governance \
  2>/dev/null | head -n 4200 || true

echo
echo "=== CURRENT CANONICAL PACKAGES ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
echo "=== PROJECT REGISTRY ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM project_registry
ORDER BY project_id;
"

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=WHAT_EXISTING_RUNTIME_PATTERN_SHOULD_OWN_EXPLICIT_PROJECT_SCOPED_OPERATIONAL_PACKAGE_SELECTION"
echo "QUESTION_2=WHAT_MINIMUM_WRITE_INPUT_IS_REQUIRED_TO_BIND_ONE_REGISTERED_PROJECT_TO_ONE_CANONICAL_APPROVED_PACKAGE"
echo "QUESTION_3=WHAT_FAIL_CLOSED_CHECKS_MUST_PRECEDE_THE_AUTHORITY_WRITE"
echo "QUESTION_4=SHOULD_MISSION_READ_CONSUME_OPERATIONAL_PACKAGE_AUTHORITY_DIRECTLY_OR_REMAIN_UNCHANGED_UNTIL_A_SEPARATE_INTEGRATION_CORRIDOR"
echo "QUESTION_5=CAN_WRITE_AND_READ_CONTRACTS_BE_CLASSIFIED_WITHOUT_IMPLEMENTING_OR_EXPANDING_GOVERNANCE_SCOPE"

echo
echo "=== SCOPE BOUNDARY ==="
echo "DATABASE_FEASIBILITY=ALREADY_ESTABLISHED"
echo "RUNTIME_WRITE_API=UNDER_INVESTIGATION"
echo "MISSION_READ_INTEGRATION=UNDER_INVESTIGATION"
echo "DELEGATION_VALIDATION_GATE_ENVELOPE=OUT_OF_SCOPE"
echo "HISTORICAL_CANONICAL_REWRITE=OUT_OF_SCOPE"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_MINIMUM_OPERATIONAL_PACKAGE_AUTHORITY_WRITE_AND_READ_CONTRACT_FROM_REPOSITORY_EVIDENCE"
