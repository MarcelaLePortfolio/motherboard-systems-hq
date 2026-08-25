#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INVESTIGATE PACKAGE HANDOFF OWNERSHIP BOUNDARY ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== SEMANTIC BASELINE ==="
echo "HANDOFF_SOURCE=matilda_canonical_packages"
echo "HANDOFF_SOURCE_STATUS=canonical_approved"
echo "HANDOFF_IDENTITY=project_id+package_id+package_version"
echo "MISSION_READ_CAN_OWN_SELECTION=NO"
echo "MISSION_CONTROL_CAN_OWN_SELECTION=NO"
echo "DELEGATION_CAN_OWN_SELECTION=NO"
echo "GOVERNANCE_PACKAGES_ASSUMED_HANDOFF_STORE=NO"

echo
echo "=== CANDIDATE OWNERSHIP SURFACES ==="
find db server -maxdepth 3 -type f \
  \( -name '*package*.ts' -o -name '*approval*.ts' -o -name '*canonical*.ts' -o -name '*mission*.ts' -o -name '*governance*.ts' \) \
  -print | sort

echo
echo "=== CANONICAL PACKAGE WRITE / APPROVAL OWNERSHIP ==="
rg -n -C 12 \
  'INSERT INTO matilda_canonical_packages|UPDATE matilda_canonical_packages|canonical_approved|create.*Canonical|approve.*Package|approval_actor|approval_timestamp' \
  db server \
  2>/dev/null | head -n 1800 || true

echo
echo "=== GOVERNANCE PACKAGE WRITE OWNERSHIP ==="
rg -n -C 12 \
  'createGovernancePackage|INSERT INTO governance_packages|governance_packages' \
  db server \
  2>/dev/null | head -n 1800 || true

echo
echo "=== PACKAGE / APPROVAL ROUTES AND ENTRY POINTS ==="
rg -n -C 10 \
  'approval|canonical package|canonical_package|package_id|package_version|project_id' \
  server/routes server \
  --glob '*.ts' \
  2>/dev/null | head -n 2200 || true

echo
echo "=== LIVE CANONICAL / GOVERNANCE IDENTITY RELATIONSHIP ==="
sqlite3 -header -column db/main.db '
SELECT
  c.project_id AS canonical_project_id,
  c.package_id AS canonical_package_id,
  c.package_version AS canonical_package_version,
  c.status AS canonical_status,
  g.project_id AS governance_project_id,
  g.package_id AS governance_package_id,
  g.package_version AS governance_package_version
FROM matilda_canonical_packages AS c
LEFT JOIN governance_packages AS g
  ON g.package_id = c.package_id
 AND g.package_version = c.package_version
ORDER BY c.created_at DESC;
'

echo
echo "=== OWNERSHIP QUESTIONS ==="
echo "Q1=WHICH_RUNTIME_FUNCTION_PERSISTS_CANONICAL_APPROVAL"
echo "Q2=WHICH_SERVER_BOUNDARY_CALLS_THAT_FUNCTION"
echo "Q3=DOES_THAT_BOUNDARY_ALREADY_HAVE_EXACT_PROJECT_PACKAGE_VERSION_IDENTITY"
echo "Q4=IS_THERE_AN_EXISTING_POST_APPROVAL_CALLBACK_OR_SUCCESSOR_BOUNDARY"
echo "Q5=WOULD_HANDOFF_MATERIALIZATION_BELONG_NEXT_TO_CANONICAL_APPROVAL_PERSISTENCE_OR_IN_A_SEPARATE_PERSISTENCE_ADAPTER"
echo "Q6=CAN_HANDOFF_BE_A_READ_ONLY_PROJECTION_WITHOUT_CREATING_A_SECOND_AUTHORITY_ROOT"

echo
echo "=== CLASSIFICATION ==="
echo "HANDOFF_OWNERSHIP_STATUS=INVESTIGATION_ACTIVE"
echo "PACKAGE_HANDOFF_CONTRACT_SEMANTICS=ESTABLISHED"
echo "PACKAGE_HANDOFF_CONTRACT_OWNERSHIP=UNRESOLVED"
echo "PROJECT_BOUND_HANDOFF_STARTED=NO"
echo "MISSION_CONTROL_IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_NEAREST_VALID_HANDOFF_OWNER_FROM_CANONICAL_APPROVAL_WRITE_PATH"
