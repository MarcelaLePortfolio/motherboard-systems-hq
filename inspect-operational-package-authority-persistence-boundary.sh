#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPERATIONAL PACKAGE AUTHORITY PERSISTENCE AND OWNERSHIP BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED CONTRACT ==="
echo "AUTHORITY_NAME=OPERATIONAL_PACKAGE_AUTHORITY"
echo "AUTHORITY_SCOPE=PROJECT_SCOPED"
echo "AUTHORITATIVE_BINDING=(project_id,package_id,package_version)"
echo "PACKAGE_IDENTITY_REQUIREMENT=EXACT_CANONICAL_PACKAGE_VERSION"
echo "ONE_ACTIVE_OPERATIONAL_PACKAGE_PER_PROJECT=YES"
echo "SELECTION_MUST_BE_EXPLICIT=YES"
echo "SELECTION_MUST_BE_PERSISTED=YES"
echo "SELECTION_MUST_BE_AUDITABLE=YES"
echo "SUCCESSOR_VERSION_AUTO_ACTIVATION=NO"
echo "DELEGATION_REQUIRED_FOR_SELECTION=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== ACTIVE CONTEXT PERSISTENCE PRECEDENT ==="
sed -n '86,130p' server/project-registry.mjs
sed -n '260,325p' server/project-registry.mjs
sed -n '892,970p' server/project-registry.mjs

echo
echo "=== CANONICAL PACKAGE PERSISTENCE SURFACE ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TABLE.*matilda_canonical_packages|matilda_canonical_packages|package_version|project_id' \
  db server scripts docs/governance \
  2>/dev/null | head -n 3200 || true

echo
echo "=== GOVERNANCE RUNTIME OWNERSHIP SURFACES ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'ensureGovernanceRuntimeTables|createGovernanceDelegation|createGovernanceValidationResult|governance_delegations|governance_validation_results' \
  db/governance-runtime.ts server scripts docs/governance \
  2>/dev/null | head -n 3200 || true

echo
echo "=== PROJECT REGISTRY OWNERSHIP SURFACE ==="
rg -n -C 14 \
  'ensureProjectRegistry|active_context|setActiveProject|getProjectRegistryState|installProjectRegistryRoutes' \
  server/project-registry.mjs \
  2>/dev/null | head -n 2200 || true

echo
echo "=== MISSION READ CONSUMER BOUNDARY ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createMissionReadRepository|loadMission|assembleMissionReadModel|package_id|package_version' \
  db/mission-read-repository.ts db/mission-read-model-assembler.ts server/routes client/src \
  2>/dev/null | head -n 3000 || true

echo
echo "=== SEARCH FOR EXISTING PROJECT-SCOPED SINGLETON PERSISTENCE ==="
rg -n -C 14 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'PRIMARY KEY.*project_id|UNIQUE.*project_id|ON CONFLICT\(project_id\)|INSERT OR REPLACE|current_.*_id|active_.*context|selected_.*package' \
  db server drizzle scripts \
  2>/dev/null | head -n 3000 || true

echo
echo "=== DATABASE ROOTS ==="
sqlite3 -header -column db/main.db "
SELECT
  name,
  sql
FROM sqlite_master
WHERE type = 'table'
  AND (
    name LIKE '%canonical%'
    OR name LIKE '%governance%'
    OR name LIKE '%project%'
    OR name LIKE '%active%'
  )
ORDER BY name;
"

echo
echo "=== CANONICAL PACKAGE PROJECT OWNERSHIP ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY project_id, package_id, package_version;
"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_CONTRACT=OPERATIONAL_PACKAGE_AUTHORITY_IS_DISTINCT_PROJECT_SCOPED_AUTHORITY"
echo "PERSISTENCE_REQUIREMENT=ONE_EXACT_CANONICAL_PACKAGE_VERSION_BINDING_PER_PROJECT"
echo "PERSISTENCE_MUST_REFERENCE_CANONICAL_PACKAGE_IDENTITY=YES"
echo "PERSISTENCE_MUST_PRESERVE_PROJECT_OWNERSHIP=YES"
echo "PERSISTENCE_MUST_NOT_MUTATE_CANONICAL_PACKAGE=YES"
echo "PERSISTENCE_MUST_NOT_CREATE_DELEGATION=YES"
echo "PERSISTENCE_MUST_NOT_CREATE_VALIDATION=YES"
echo "PERSISTENCE_MUST_NOT_ACTIVATE_EXECUTION=YES"
echo "MISSION_READ_MODEL_OWNS_AUTHORITY=NO"
echo "MISSION_READ_MODEL_MAY_CONSUME_AUTHORITY=YES"
echo "PROJECT_ACTIVE_CONTEXT_IS_PRECEDENT_NOT_AUTHORITY_REUSE=YES"
echo "IMPLEMENTATION_SHAPE=UNDER_INVESTIGATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_WHETHER_AUTHORITY_PERSISTENCE_BELONGS_WITH_CANONICAL_PACKAGE_GOVERNANCE_PROJECT_CONTEXT_OR_A_DEDICATED_BOUNDARY"
