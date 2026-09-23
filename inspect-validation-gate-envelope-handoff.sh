#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="84ade0257"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== BOUNDARY CLASSIFICATION ===\n'
echo "DELEGATION_TO_ENVELOPE_DIRECT_HANDOFF=NOT_AUTHORIZED_BY_EXISTING_CONTRACT"
echo "ENVELOPE_CREATION_CAPABILITY=EXISTS"
echo "ENVELOPE_REQUIRES_VALIDATION_RESULT=YES"
echo "ENVELOPE_REQUIRES_ENVELOPE_GATE=YES"
echo "NEXT_BOUNDARY=VALIDATION_TO_GATE_TO_ENVELOPE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "NEW_AUTHORITY_AUTHORIZED=NO"

printf '\n=== VALIDATION PRODUCTION FILES ===\n'
find server -maxdepth 3 -type f \
  \( -iname '*validation*' -o -iname '*validator*' \) \
  -print | sort

printf '\n=== ENVELOPE GATE PRODUCTION FILES ===\n'
for f in \
  server/gate/production-envelope-gate-entry-point.ts \
  server/gate/production-envelope-gate-consumer.ts \
  server/routes/governance-envelope-gate-route.ts
do
  if [ -f "$f" ]; then
    printf '\n----- %s -----\n' "$f"
    sed -n '1,460p' "$f"
  fi
done

printf '\n=== VALIDATION / GATE TEST CONTRACTS ===\n'
find server db -type f \
  \( -iname '*validation*.test.ts' -o -iname '*gate*.test.ts' \) \
  -print | sort | while read -r f
do
  printf '\n----- %s -----\n' "$f"
  sed -n '1,460p' "$f"
done

printf '\n=== VALIDATION → GATE → ENVELOPE REFERENCES ===\n'
grep -RniE \
  'validation_result_id|envelope_gate_id|VALIDATION_PASSED|createGovernanceValidation|createGovernanceEnvelopeGate|consume.*Gate|invoke.*Gate|createGovernanceEnvelope|consume.*Envelope|invoke.*Envelope' \
  server db \
  --exclude='*.bak' \
  --exclude='*.sqlite*' \
  --exclude='main.db' \
  2>/dev/null | head -700 || true

printf '\n=== GOVERNANCE RUNTIME TYPES AND PERSISTENCE ===\n'
sed -n '1,220p' db/governance-runtime.ts
sed -n '820,1140p' db/governance-runtime.ts

printf '\n=== CURRENT HQ PRE-ENVELOPE LINEAGE — READ ONLY ===\n'
sqlite3 -readonly db/main.db <<'SQL' 2>/dev/null || true
.headers on
.mode column

SELECT *
FROM governance_delegations
WHERE project_id = 'hq'
ORDER BY created_at DESC
LIMIT 5;

SELECT *
FROM governance_validation_results
ORDER BY rowid DESC
LIMIT 10;

SELECT *
FROM governance_envelope_gates
ORDER BY rowid DESC
LIMIT 10;

SELECT *
FROM governance_envelopes
WHERE project_id = 'hq'
ORDER BY created_at DESC
LIMIT 10;
SQL

printf '\n=== QUESTIONS TO RESOLVE ===\n'
echo "Q1=Which artifact is required immediately after AUTHORIZED Delegation?"
echo "Q2=How is validation_result_id produced and what lineage does it bind to?"
echo "Q3=What exact conditions authorize creation of an Envelope Gate?"
echo "Q4=Does Envelope Gate creation itself grant downstream governance authority?"
echo "Q5=What exact conditions permit canonical Envelope creation?"
echo "Q6=Is there already a production composition/consumer connecting Validation, Gate, and Envelope?"
echo "Q7=For the live delegated HQ package, which prerequisite artifact is first absent?"
echo "Q8=Is the missing behavior an unwired existing handoff or a deliberately unimplemented authority transition?"

printf '\n=== WORKTREE — PRESERVE ===\n'
git status --short

printf '\nVALIDATION_GATE_ENVELOPE_INVESTIGATION=COMPLETE\n'
printf 'IMPLEMENTATION_PERFORMED=NO\n'
