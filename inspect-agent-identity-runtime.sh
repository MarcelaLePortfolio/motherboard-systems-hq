#!/usr/bin/env bash
set -euo pipefail

echo "=== BASELINE ==="
git fetch origin feature/support-source-references-runtime
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "HEAD=$(git rev-parse HEAD)"
echo "REMOTE=$(git rev-parse origin/feature/support-source-references-runtime)"
echo "STATUS:"
git status --short

echo
echo "=== RELEVANT DATABASE SCHEMA ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  m.name AS table_name,
  p.cid,
  p.name AS column_name,
  p.type
FROM sqlite_master AS m
JOIN pragma_table_info(m.name) AS p
WHERE m.type='table'
  AND (
    lower(m.name) LIKE '%delegat%' OR
    lower(m.name) LIKE '%worker%' OR
    lower(m.name) LIKE '%agent%' OR
    lower(m.name) LIKE '%execut%' OR
    lower(m.name) LIKE '%schedul%' OR
    lower(m.name) LIKE '%claim%' OR
    lower(p.name) LIKE '%agent%' OR
    lower(p.name) LIKE '%actor%' OR
    lower(p.name) LIKE '%worker%' OR
    lower(p.name) LIKE '%executor%' OR
    lower(p.name) LIKE '%delegat%' OR
    lower(p.name) LIKE '%assign%' OR
    lower(p.name) LIKE '%claim%' OR
    lower(p.name) LIKE '%owner%'
  )
ORDER BY m.name, p.cid;
SQL

echo
echo "=== GOVERNANCE_DELEGATIONS DEFINITION ==="
sqlite3 db/main.db <<'SQL'
SELECT sql
FROM sqlite_master
WHERE type='table'
  AND name='governance_delegations';
SQL

echo
echo "=== GOVERNANCE_DELEGATIONS DATA ==="
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT * FROM governance_delegations LIMIT 100;
SQL

echo
echo "=== RUNTIME IDENTITY REFERENCES ==="
grep -RniE \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  --include='*.js' \
  'agent_id|agentId|actor_id|actorId|worker_id|workerId|executor_id|executorId|assigned_to|assignedTo|assignee|delegated_to|delegatedTo|claimed_by|claimedBy|worker_owner|WORKER_OWNER|PHASE26_WORKER_ACTOR|docker-wA|docker-wB' \
  server db routes client/src \
  2>/dev/null || true

echo
echo "=== DELEGATION RUNTIME REFERENCES ==="
grep -RniE \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  --include='*.js' \
  'governance_delegations|delegation_id|delegationId|delegat(e|ed|ion)' \
  server db routes client/src \
  2>/dev/null || true

echo
echo "=== SCHEDULER / CLAIM / WORKER REFERENCES ==="
grep -RniE \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  --include='*.js' \
  'scheduler|worker|claim|lease|dispatch|execution consumer|execution-consumer' \
  server db routes \
  2>/dev/null | head -n 500 || true

echo
echo "=== HISTORICAL NAMED ACTOR REFERENCES ==="
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude='inspect-agent-identity-runtime.sh' \
  'docker-wA|docker-wB|PHASE26_WORKER_ACTOR|WORKER_OWNER' \
  . \
  2>/dev/null || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "LIFECYCLE_COMPONENTS_AUTOMATICALLY_AGENTS=NO"
echo "AGENT_IDENTITY_REQUIRES_EXPLICIT_RUNTIME_OR_PERSISTED_BINDING=YES"
echo "EMPTY_GOVERNANCE_DELEGATIONS_MEANS_NO_CURRENT_DELEGATION_ROWS=YES"
echo "EMPTY_GOVERNANCE_DELEGATIONS_ALONE_PROVES_NO_AGENT_IDENTITIES=NO"
echo "LIVE_TASK_SUBMISSION_PERFORMED=NO"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "NEW_AUTHORITY_INTRODUCED=NO"

echo
echo "=== FINAL WORKTREE ==="
git status --short
