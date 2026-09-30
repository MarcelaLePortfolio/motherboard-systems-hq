#!/usr/bin/env bash
set -euo pipefail

echo "=== GOVERNANCE DELEGATIONS: ACTUAL SCHEMA ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
PRAGMA table_info(governance_delegations);
SQL

echo
echo "=== GOVERNANCE DELEGATIONS: CREATE STATEMENT ==="
sqlite3 db/main.db <<'SQL'
SELECT sql
FROM sqlite_master
WHERE type='table'
  AND name='governance_delegations';
SQL

echo
echo "=== GOVERNANCE DELEGATIONS: CURRENT ROWS ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT *
FROM governance_delegations
LIMIT 50;
SQL

echo
echo "=== IDENTITY-BEARING DATABASE COLUMNS ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  m.name AS table_name,
  p.name AS column_name,
  p.type
FROM sqlite_master AS m
JOIN pragma_table_info(m.name) AS p
WHERE m.type='table'
  AND (
    lower(p.name) LIKE '%agent%' OR
    lower(p.name) LIKE '%actor%' OR
    lower(p.name) LIKE '%worker%' OR
    lower(p.name) LIKE '%executor%' OR
    lower(p.name) LIKE '%assignee%' OR
    lower(p.name) LIKE '%assign%' OR
    lower(p.name) LIKE '%delegate%' OR
    lower(p.name) LIKE '%target%' OR
    lower(p.name) LIKE '%owner%'
  )
ORDER BY m.name, p.cid;
SQL

echo
echo "=== RUNTIME IDENTITY / DELEGATION / ASSIGNMENT REFERENCES ==="
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  'governance_delegations|delegated_(to|by)|delegation.*(actor|agent|worker|target)|assigned_to|assignedTo|assignee|actor_id|worker_id|executor_id|WORKER_OWNER|PHASE26_WORKER_ACTOR' \
  server db routes client/src \
  2>/dev/null || true

echo
echo "=== HISTORICAL WORKER / ACTOR REFERENCES ==="
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'docker-wA|docker-wB|WORKER_OWNER|PHASE26_WORKER_ACTOR|agent identity|agent registry|requesting runtime or actor' \
  . \
  2>/dev/null || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "SCHEMA_FIRST_INSPECTION=COMPLETE"
echo "LIFECYCLE_COMPONENTS_AUTOMATICALLY_AGENTS=NO"
echo "IDENTITIES_REQUIRE_RUNTIME_OR_PERSISTED_EVIDENCE=YES"
echo "LIVE_TASK_SUBMISSION_PERFORMED=NO"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "NEW_AUTHORITY_INTRODUCED=NO"
