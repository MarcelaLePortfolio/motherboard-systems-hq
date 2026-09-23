#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d03a06da1"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "INVESTIGATION=DELEGATION_TO_MISSION_CONTROL_PROJECTION"
echo "INVESTIGATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "NEW_AUTHORITY_CREATION_AUTHORIZED=NO"

printf '\n=== GOVERNANCE LIFECYCLE MODEL ===\n'
sed -n '1,360p' docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md 2>/dev/null || true

printf '\n=== MISSION READ MODEL CONTRACT ===\n'
sed -n '1,300p' docs/architecture/MISSION_READ_MODEL.md 2>/dev/null || true

printf '\n=== CANONICAL PACKAGE MISSION PROJECTION ===\n'
sed -n '1,360p' db/canonical-package-mission-projection.ts 2>/dev/null || true

printf '\n=== MISSION READ ASSEMBLER ===\n'
sed -n '1,280p' db/mission-read-model-assembler.ts 2>/dev/null || true

printf '\n=== DELEGATION ENTRY / CONSUMPTION ===\n'
for f in \
  server/delegation/production-delegation-entry-point.ts \
  server/delegation/production-delegation-consumer.ts \
  server/routes/governance-delegation-route.ts
do
  printf '\n----- %s -----\n' "$f"
  sed -n '1,360p' "$f" 2>/dev/null || true
done

printf '\n=== DOWNSTREAM OPERATIONAL PATH ===\n'
for f in \
  db/operational-package-authority.ts \
  db/operational-intake-runtime.ts \
  db/governance-lifecycle-composition.ts \
  db/governance-lifecycle-integration.ts \
  server/operational/production-operational-consumer.ts
do
  printf '\n----- %s -----\n' "$f"
  sed -n '1,380p' "$f" 2>/dev/null || true
done

printf '\n=== MISSION CONTROL CLIENT READ PATH ===\n'
sed -n '1,380p' client/src/mission-control/MissionControlProvider.tsx 2>/dev/null || true

printf '\n=== DELEGATION → LIFECYCLE CALL-SITE SEARCH ===\n'
grep -RniE \
  'DELEGATION_AUTHORIZED|governance_delegations|operational.*intake|ASSIGNED|assembleMission|canonicalPackageMission|lifecycle_state' \
  server db \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -420 || true

printf '\n=== CURRENT PERSISTED STATE — READ ONLY ===\n'
sqlite3 -readonly db/main.db <<'SQL' 2>/dev/null || true
.headers on
.mode column

SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at DESC
LIMIT 10;

SELECT
  envelope_id,
  project_id,
  package_id,
  package_version,
  lifecycle_state,
  execution_authorized
FROM governance_envelopes
ORDER BY rowid DESC
LIMIT 10;
SQL

printf '\n=== QUESTIONS TO RESOLVE ===\n'
echo "Q1=Does AUTHORIZED Delegation itself enter Mission Read?"
echo "Q2=Which persisted artifact supplies Mission Read lifecycle_state?"
echo "Q3=What transition exists between DELEGATION_AUTHORIZED and ASSIGNED?"
echo "Q4=Does that transition require separate authority?"
echo "Q5=Does the delegated package currently possess the required downstream artifact?"
echo "Q6=Is Mission Control correctly displaying absence of downstream lifecycle state?"
echo "Q7=If a handoff is missing, what is the smallest existing architectural seam?"

printf '\n=== WORKTREE — MUST REMAIN PRESERVED ===\n'
git status --short

printf '\nINVESTIGATION_COMPLETE=YES\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
