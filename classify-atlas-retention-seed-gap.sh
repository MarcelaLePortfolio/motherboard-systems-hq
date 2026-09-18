#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="930595c9d"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== CONCLUSION FROM FOCUSED INSPECTION ===\n'
echo "HISTORICAL_TABLE_ROWS=0"
echo "DOGFOOD_CONVERSATIONS_PRESENT=YES"
echo "RUNTIME_PERSISTENCE_WRITER=LANDED"
echo "RUNTIME_HISTORICAL_READER=LANDED"
echo "ACTUAL_RETENTION_BEHAVIOR_ON_DOGFOOD_DATA=NOT_YET_PROVEN"
echo "DOGFOOD_CLEANUP_REMAINS_FROZEN=YES"

printf '\n=== VERIFY TABLE EXISTS BUT IS EMPTY ===\n'
sqlite3 db/main.db <<'SQL'
SELECT name
FROM sqlite_master
WHERE type = 'table'
  AND name = 'atlas_historical_observations';

SELECT COUNT(*) AS atlas_historical_observation_count
FROM atlas_historical_observations;
SQL

printf '\n=== VERIFY WRITER SEAMS ===\n'
grep -n -B20 -A55 \
  'persistAtlasHistoricalObservation' \
  server/matilda-chat-workflow.ts

printf '\n=== VERIFY RECENT CONVERSATION SOURCE DATA ===\n'
sqlite3 db/main.db <<'SQL'
SELECT
  c.conversation_id,
  c.project_id,
  COUNT(DISTINCT i.entry_id) AS interpretation_entries,
  COUNT(DISTINCT d.draft_package_id) AS living_drafts
FROM matilda_conversations c
LEFT JOIN matilda_interpretation_evidence_ledger i
  ON i.conversation_id = c.conversation_id
LEFT JOIN matilda_living_draft_packages d
  ON d.conversation_id = c.conversation_id
WHERE c.project_id = 'hq'
GROUP BY c.conversation_id, c.project_id
ORDER BY c.created_at DESC
LIMIT 20;
SQL

printf '\n=== SEARCH EXISTING SAFE DOGFOOD / WORKFLOW HARNESS ===\n'
git grep -n -E \
  'runMatildaConversationWorkflow|matilda-chat-workflow|dogfood|live regression|fresh conversation' \
  -- scripts server \
  | head -320 || true

printf '\n=== SEARCH HISTORICAL WRITER TEST COVERAGE ===\n'
git grep -n -E \
  'atlas_historical_observations|persistAtlasHistoricalObservation|historical observation' \
  -- 'server/*test*' 'server/**/*test*' 'db/*test*' \
  || true

printf '\n=== CLASSIFICATION ===\n'
echo "Q1_ACTUAL_DOGFOOD_HISTORY_EXISTS=NO"
echo "Q2_INDEPENDENT_HISTORY_AFTER_SOURCE_REMOVAL=UNIT_PROVEN_ONLY"
echo "Q3_RETENTION_CAPABILITY_CODE=YES"
echo "Q4_REMAINING_WORK=PROVE_RETENTION_WITH_A_FRESH_POST_INTEGRATION_DOGFOOD_RECORD_BEFORE_ANY_DESTRUCTIVE_CLEANUP"
echo "NEXT_DECISION=SELECT_EXISTING_SAFE_DOGFOOD_HARNESS_OR_DEFINE_BOUNDED_VALIDATION"
echo "DOGFOOD_CLEANUP_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"

printf '\n=== VERIFY NO EFFECT ===\n'
git diff --cached --name-status
echo "NO MUTATION / NO COMMIT / NO PUSH"
