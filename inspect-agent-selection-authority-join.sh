#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== ROUTING / ASSIGNMENT PRODUCERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A160 \
  '(createAssignment\(|assigned_agent|routing_id|routing_decision|selected_agent|agent_selection)' \
  server db \
  2>/dev/null | head -n 4000 || true

printf '\n=== AUTHORIZED DELEGATION JOIN POINTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B60 -A180 \
  '(delegation.*(routing|assignment|assigned_agent)|assignment.*delegation|execution_approved|execution_authorized|authorization.*assignment)' \
  server db \
  2>/dev/null | head -n 4500 || true

printf '\n=== MATILDA ROUTING RUNTIMES ===\n'
find db server -type f \
  \( -iname '*routing*' -o -iname '*delegation*' -o -iname '*assignment*' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/dist/*' \
  -print | sort

printf '\n=== DURABLE AGENT VALUES ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT assigned_agent, COUNT(*) AS count
FROM matilda_execution_plans
GROUP BY assigned_agent
ORDER BY count DESC, assigned_agent;
SQL

printf '\n=== CLASSIFICATION ===\n'
echo 'AGENT_IDENTITY_AND_EXECUTION_AUTHORITY_ARE_SEPARATE=YES'
echo 'DURABLE_ASSIGNED_AGENT_CONTRACT=ESTABLISHED'
echo 'ORIGINAL_AGENT_SELECTION_SOURCE=UNDER_INVESTIGATION'
echo 'AUTHORIZED_DELEGATION_JOIN_POINT=UNDER_INVESTIGATION'
echo 'NEW_DELEGATION_CREATED=NO'
echo 'LIVE_TASK_CREATED=NO'
echo 'NEW_AUTHORITY_CREATED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
