#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CONCLUSION FROM ROUTER LINEAGE ===\n'
echo 'ATLAS_WAS_IN_ORIGINAL_ROUTER_AGENT_UNION=YES'
echo 'ATLAS_WAS_NOT_LATER_ADDITION=YES'
echo 'ROUTER_AGENT_UNION_ORIGIN_COMMIT=c57fa6151'
echo 'ROUTER_HAS_DIRECT_EXECUTION_PATH_ONLY_FOR_CADE=YES'
echo 'ROUTER_PRODUCTION_AUTHORITY=NOT_YET_ESTABLISHED'
echo 'NEXT_TARGET=LIVE_AGENT_RUNTIME_SURFACES'

printf '\n=== SCHEDULER CONTRACT ===\n'
sed -n '1,220p' server/orchestration/scheduler.ts 2>/dev/null || true

printf '\n=== LOCAL CADE LAUNCHER ===\n'
sed -n '1,260p' scripts/_local/agent-runtime/launch-cade.ts 2>/dev/null || true

printf '\n=== LOCAL TASK ROUTER ===\n'
sed -n '1,260p' scripts/_local/handlers/taskRouter.ts 2>/dev/null || true

printf '\n=== PHASE 64 NAMED AGENT AUDITS ===\n'
for f in \
  scripts/_local/phase64_agent_signal_audit.sh \
  scripts/_local/phase64_named_agent_path_audit.sh
do
  if test -f "$f"; then
    printf '\n--- %s ---\n' "$f"
    sed -n '1,360p' "$f"
  fi
done

printf '\n=== PRODUCTION IMPORTS OF ORCHESTRATION ROUTER ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '(from ["'\''][^"'\'']*orchestration/router|require\([^)]*orchestration/router|routeTask\()' \
  server db client/src \
  2>/dev/null | head -n 1000 || true

printf '\n=== CURRENT PRODUCTION AGENT / ACTOR FIELDS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.spec.ts' \
  '(agent_id|agentId|agent_name|agentName|assigned_agent|assignedAgent|assigned_actor|actor|delegated_by)' \
  server db \
  2>/dev/null | head -n 1400 || true

printf '\n=== DATABASE AGENT / ACTOR COLUMNS ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT
  m.name AS table_name,
  p.cid,
  p.name AS column_name,
  p.type
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type='table'
  AND (
    lower(p.name) LIKE '%agent%' OR
    lower(p.name) LIKE '%actor%' OR
    lower(p.name) LIKE '%delegate%' OR
    lower(p.name) LIKE '%owner%'
  )
ORDER BY m.name, p.cid;
SQL

printf '\n=== DURABLE NAMED IDENTITY VALUES ===\n'
for table in $(sqlite3 db/main.db "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"); do
  cols="$(sqlite3 db/main.db "PRAGMA table_info('$table');" | awk -F'|' 'tolower($2) ~ /(agent|actor|delegate|owner)/ {print $2}')"
  for col in $cols; do
    printf '\n--- %s.%s ---\n' "$table" "$col"
    sqlite3 -header -column db/main.db \
      "SELECT \"$col\", COUNT(*) AS row_count FROM \"$table\" WHERE \"$col\" IS NOT NULL AND trim(CAST(\"$col\" AS TEXT)) <> '' GROUP BY \"$col\" ORDER BY row_count DESC LIMIT 50;" \
      2>/dev/null || true
  done
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_PHASE17_ROUTER_CURRENT_PRODUCTION_RUNTIME_OR_LEGACY_ORCHESTRATION'
echo 'QUESTION_2=WHAT_IDENTITY_FIELD_DOES_CURRENT_PRODUCTION_EXECUTION_ACTUALLY_PERSIST'
echo 'QUESTION_3=DO_CURRENT_DURABLE_RECORDS_NAME_CADE_EFFIE_MATILDA_ATLAS_OR_OTHER_ACTORS'
echo 'QUESTION_4=WHICH_IDENTITY_SURFACE_SHOULD_BACK_FIRST_LIVE_DELEGATED_TASK'
echo 'LIVE_DELEGATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
