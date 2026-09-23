#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="425f95013"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CLASSIFICATION ===\n'
echo "MISSION_CONTROL_PROJECTION_DEFECT=NO_EVIDENCE"
echo "AUTHORIZED_DELEGATION_PRESENT=YES"
echo "DOWNSTREAM_ENVELOPE_OBSERVED=NO"
echo "NEXT_BOUNDARY=DELEGATION_TO_ENVELOPE_HANDOFF"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "NEW_AUTHORITY_AUTHORIZED=NO"

printf '\n=== DELEGATION CONSUMER ===\n'
sed -n '1,420p' server/delegation/production-delegation-consumer.ts 2>/dev/null || true

printf '\n=== DELEGATION ENTRY POINT ===\n'
sed -n '1,420p' server/delegation/production-delegation-entry-point.ts 2>/dev/null || true

printf '\n=== DELEGATION ROUTE ===\n'
sed -n '1,420p' server/routes/governance-delegation-route.ts 2>/dev/null || true

printf '\n=== ENVELOPE CONSUMER ===\n'
sed -n '1,420p' server/envelope/production-envelope-consumer.ts 2>/dev/null || true

printf '\n=== ENVELOPE ENTRY POINT ===\n'
sed -n '1,420p' server/envelope/production-envelope-entry-point.ts 2>/dev/null || true

printf '\n=== ENVELOPE ROUTE ===\n'
sed -n '1,420p' server/routes/governance-envelope-route.ts 2>/dev/null || true

printf '\n=== EXACT DELEGATION → ENVELOPE CALL SITES ===\n'
grep -RniE \
  'consume.*Delegation|Delegation.*consume|productionDelegation|create.*Envelope|consume.*Envelope|productionEnvelope|governance-envelope|governance_envelopes|ENVELOPE_CREATED' \
  server db \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -520 || true

printf '\n=== DELEGATION AND ENVELOPE TEST CONTRACTS ===\n'
for f in \
  server/delegation/production-delegation-consumer.test.ts \
  server/delegation/production-delegation-entry-point.test.ts \
  server/routes/governance-delegation-route.test.ts \
  server/envelope/production-envelope-consumer.test.ts \
  server/envelope/production-envelope-entry-point.test.ts \
  server/routes/governance-envelope-route.test.ts
do
  if [ -f "$f" ]; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,420p' "$f"
  fi
done

printf '\n=== PERSISTENCE CONTRACTS ===\n'
grep -RniE \
  'persist.*delegation|persist.*envelope|createGovernanceDelegation|createGovernanceEnvelope|INSERT INTO governance_delegations|INSERT INTO governance_envelopes' \
  db server \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -420 || true

printf '\n=== CURRENT HQ LINEAGE — READ ONLY ===\n'
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
WHERE project_id = 'hq'
ORDER BY created_at DESC
LIMIT 10;

SELECT
  envelope_id,
  delegation_id,
  project_id,
  package_id,
  package_version,
  lifecycle_state,
  created_at
FROM governance_envelopes
WHERE project_id = 'hq'
ORDER BY created_at DESC
LIMIT 10;
SQL

printf '\n=== QUESTIONS TO RESOLVE ===\n'
echo "Q1=Is envelope creation an existing production capability?"
echo "Q2=Does delegation production code invoke that capability?"
echo "Q3=If not, is a deliberate handoff contract already defined?"
echo "Q4=What authority does envelope creation require?"
echo "Q5=Can an AUTHORIZED delegation be consumed without synthesizing new authority?"
echo "Q6=Is the missing behavior wiring, persistence, or an intentionally absent authorization step?"
echo "Q7=What is the smallest existing seam that could connect the stages while preserving Approval != Delegation != Execution?"

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nDELEGATION_TO_ENVELOPE_INVESTIGATION=COMPLETE\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
