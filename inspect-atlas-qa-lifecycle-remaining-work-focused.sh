#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6d9e777bc"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== HISTORICAL TABLE CURRENT ROW COUNTS ===\n'
sqlite3 db/main.db <<'SQL'
SELECT
  source_kind,
  COUNT(*) AS count
FROM atlas_historical_observations
GROUP BY source_kind
ORDER BY source_kind;
SQL

printf '\n=== HISTORICAL CONVERSATION COVERAGE ===\n'
sqlite3 db/main.db <<'SQL'
SELECT
  project_id,
  conversation_id,
  source_kind,
  COUNT(*) AS count,
  MIN(observed_at) AS first_observed_at,
  MAX(observed_at) AS last_observed_at
FROM atlas_historical_observations
GROUP BY project_id, conversation_id, source_kind
ORDER BY last_observed_at DESC
LIMIT 80;
SQL

printf '\n=== CURRENT DOGFOOD / QA CONVERSATION CANDIDATES ===\n'
sqlite3 db/main.db <<'SQL'
SELECT
  conversation_id,
  project_id,
  created_at,
  status
FROM matilda_conversations
ORDER BY created_at DESC
LIMIT 40;
SQL

printf '\n=== CHECK WHETHER HISTORICAL DATA SURVIVES SOURCE ABSENCE ===\n'
sqlite3 db/main.db <<'SQL'
SELECT
  h.source_kind,
  h.source_identity,
  h.project_id,
  h.conversation_id,
  h.observed_at,
  CASE
    WHEN h.source_kind = 'interpretation_evidence'
      THEN EXISTS (
        SELECT 1
        FROM matilda_interpretation_evidence_ledger i
        WHERE i.entry_id = h.source_identity
      )
    WHEN h.source_kind = 'living_draft'
      THEN EXISTS (
        SELECT 1
        FROM matilda_living_draft_packages d
        WHERE d.draft_package_id = json_extract(h.payload_json, '$.draft_package_id')
          AND d.updated_at = json_extract(h.payload_json, '$.updated_at')
      )
    ELSE 0
  END AS live_source_still_present
FROM atlas_historical_observations h
ORDER BY h.observed_at DESC
LIMIT 100;
SQL

printf '\n=== EXISTING ATLAS CLEANUP / RETENTION CODE ===\n'
git grep -n -E \
  'atlas_historical_observations|persistAtlasHistoricalObservation|readAtlasHistoricalTypedObservations|dogfood.*cleanup|cleanup.*dogfood|retention.*Atlas|Atlas.*retention' \
  -- db server scripts docs \
  | head -260 || true

printf '\n=== CURRENT DOGFOOD BACKUPS ===\n'
find db -maxdepth 1 -type f \
  \( -name '*dogfood*' -o -name '*pre-dogfood*' \) \
  -print | sort

printf '\n=== CLOSURE QUESTIONS ===\n'
echo "Q1=Do historical observations exist for actual dogfood conversations?"
echo "Q2=Can historical rows remain readable when their corresponding mutable live source revision is absent?"
echo "Q3=Is there any product cleanup/retention mechanism already present?"
echo "Q4=Is remaining work only destructive dogfood cleanup, or is another retention capability missing?"
echo "DOGFOOD_CLEANUP_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"

printf '\n=== VERIFY NO MUTATION ===\n'
git diff --cached --name-status
echo "NO MUTATION / NO COMMIT / NO PUSH"
