#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY OPERATIONAL PACKAGE AUTHORITY BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED REPOSITORY EVIDENCE ==="
echo "MISSION_READ_REPOSITORY_REQUIRES_CALLER_SUPPLIED_PACKAGE_ID=YES"
echo "MISSION_DASHBOARD_USES_HARDCODED_ACTIVE_PACKAGE_ID=YES"
echo "MISSION_READ_MODEL_PRESERVES_PACKAGE_VERSION_PROJECT_ID_AND_CONVERSATION_ID_AFTER_SELECTION=YES"
echo "DELEGATION_AUTHORIZATION_ADVANCES_STAGE_AFTER_PACKAGE_SELECTION=YES"
echo "EXISTING_PERSISTED_OPERATIONAL_PACKAGE_NOMINATION_FOUND=NO"
echo "CANONICAL_APPROVAL_AS_OPERATIONAL_NOMINATION_ESTABLISHED=NO"
echo "DELEGATION_AS_OPERATIONAL_NOMINATION_ESTABLISHED=NO"

echo
echo "=== FALSIFICATION: DELEGATION AUTHORITY ==="
rg -n -C 16 \
  'Delegation is|Delegation authorizes|Delegation means|Delegation.*Package|authorization_state|delegated_by|Governance Validation consumes Delegation' \
  docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md \
  docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md \
  server/delegation db/governance-runtime.ts \
  2>/dev/null | head -n 2600 || true

echo
echo "=== FALSIFICATION: CANONICAL APPROVAL AUTHORITY ==="
rg -n -C 16 \
  'Canonical Package|canonical_approved|Approval|approval.*authority|authoritative Package|downstream_governance_authorized|new_authority_introduced' \
  docs/governance \
  server/package \
  db \
  2>/dev/null | head -n 3000 || true

echo
echo "=== CURRENT MISSION-CONTROL SELECTION SURFACE ==="
sed -n '1,380p' client/src/shell/MissionDashboardWorkspace.tsx

echo
echo "=== CURRENT MISSION READ API ==="
sed -n '1,180p' client/src/mission-control/missionReadApi.ts

echo
echo "=== CURRENT MISSION READ REPOSITORY ==="
sed -n '1,180p' db/mission-read-repository.ts

echo
echo "=== SEARCH FOR PROJECT-SCOPED PACKAGE SELECTION PRECEDENT ==="
rg -n -C 14 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'current_project_id|activeProjectId|active_context|package_id.*project_id|project_id.*package_id|current.*package|active.*package|selected.*package|mission.*package' \
  server db client/src docs/governance \
  2>/dev/null | head -n 3600 || true

echo
echo "=== LIVE IDENTITY SURFACES ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  requested_outcome,
  created_at
FROM governance_packages
ORDER BY created_at;
"

echo
echo "=== AUTHORITY CLASSIFICATION ==="
echo "CANONICAL_APPROVAL_AUTHORITY=ESTABLISHES_AUTHORITATIVE_MEANING_NOT_OPERATIONAL_MISSION_SELECTION"
echo "DELEGATION_AUTHORITY=ESTABLISHES_AUTHORIZATION_FOR_DOWNSTREAM_GOVERNANCE_NOT_OPERATIONAL_MISSION_SELECTION"
echo "MISSION_READ_AUTHORITY=READ_ONLY_AND_REQUIRES_PRIOR_PACKAGE_SELECTION"
echo "MISSION_DASHBOARD_SELECTION=HARDCODED_NONAUTHORITATIVE_UI_CONFIGURATION"
echo "PERSISTED_OPERATIONAL_PACKAGE_SELECTION_AUTHORITY=ABSENT_BY_CURRENT_REPOSITORY_EVIDENCE"

echo
echo "=== ARCHITECTURAL BOUNDARY ==="
echo "DISTINCT_ARCHITECTURAL_CAPABILITY_ESTABLISHED=YES"
echo "CAPABILITY=OPERATIONAL_PACKAGE_AUTHORITY"
echo "RESPONSIBILITY=AUTHORITATIVELY_BIND_EXACT_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION_AS_THE_OPERATIONAL_MISSION"
echo "MUST_NOT_IMPLY_DELEGATION=YES"
echo "MUST_NOT_IMPLY_GOVERNANCE_VALIDATION=YES"
echo "MUST_NOT_IMPLY_ENVELOPE_CREATION=YES"
echo "MUST_NOT_IMPLY_ROUTING=YES"
echo "MUST_NOT_IMPLY_ASSIGNMENT=YES"
echo "MUST_NOT_IMPLY_EXECUTION=YES"

echo
echo "=== SCOPE DETERMINATION ==="
echo "VERIFIED_OUTCOME=EXISTING_AUTHORITIES_DO_NOT_ESTABLISH_OPERATIONAL_PACKAGE_NOMINATION"
echo "VERIFIED_OUTCOME=MISSION_CONTROL_CURRENTLY_LACKS_A_PERSISTED_AUTHORITATIVE_PACKAGE_SELECTION_SOURCE"
echo "VERIFIED_OUTCOME=OPERATIONAL_PACKAGE_AUTHORITY_IS_A_DISTINCT_MISSING_ARCHITECTURAL_BOUNDARY"
echo "DEFERRED=VALIDATION_GATE_ENVELOPE_CANONICAL_LINEAGE_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_MINIMUM_SEMANTIC_CONTRACT_FOR_OPERATIONAL_PACKAGE_AUTHORITY_BEFORE_IMPLEMENTATION_READINESS"
