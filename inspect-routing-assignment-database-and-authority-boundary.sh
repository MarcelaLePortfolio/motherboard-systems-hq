#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== DATABASE OWNERSHIP ===\n'
grep -n 'new Database' \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  2>/dev/null || true

printf '\n=== TARGET TABLES BY DATABASE ===\n'
for dbfile in motherboard.sqlite db/main.db motherboard.db; do
  [ -f "$dbfile" ] || continue
  echo "--- $dbfile ---"
  sqlite3 "$dbfile" "
    SELECT name
    FROM sqlite_master
    WHERE type='table'
      AND (
        name LIKE '%routing%'
        OR name LIKE '%assignment%'
        OR name LIKE '%execution_plan%'
      )
    ORDER BY name;
  " 2>/dev/null || true
done

printf '\n=== ROUTING ROWS ===\n'
[ -f motherboard.sqlite ] &&
sqlite3 -header -column motherboard.sqlite \
  'SELECT * FROM matilda_routing ORDER BY rowid;' 2>/dev/null || true

printf '\n=== ASSIGNMENT ROWS ===\n'
[ -f motherboard.sqlite ] &&
sqlite3 -header -column motherboard.sqlite \
  'SELECT * FROM matilda_assignments ORDER BY rowid;' 2>/dev/null || true

printf '\n=== PREDECESSOR VALIDATION SEARCH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B25 -A60 \
  'routing_id|assignment_id|routing_destination|assigned_agent' \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  server/routes/matilda-routing-route.ts \
  server/routes/matilda-assignment-route.ts \
  server/routes/matilda-execution-planning-route.ts \
  2>/dev/null || true

printf '\n=== DATABASE PATH LINEAGE ===\n'
git log --all -p -- \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  2>/dev/null | grep -nE \
  '^(commit |Date:|    Phase|[-+]const db = new Database|[-+].*motherboard\.sqlite|[-+].*db/main\.db)' \
  | head -500 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_MOTHERBOARD_SQLITE_CURRENT_OR_STALE'
echo 'QUESTION_2=IS_DB_MAIN_DB_THE_CURRENT_CANONICAL_RUNTIME_DATABASE'
echo 'QUESTION_3=DOES_ASSIGNMENT_VERIFY_ROUTING_ID'
echo 'QUESTION_4=DOES_PLANNING_VERIFY_ASSIGNMENT_ID'
echo 'QUESTION_5=IS_ASSIGNED_AGENT_DERIVED_OR_CALLER_SUPPLIED'
echo 'QUESTION_6=IS_ROUTING_DESTINATION_RECONCILED_WITH_ASSIGNED_AGENT'
echo 'QUESTION_7=DO_NOT_CHANGE_IDENTITY_UNTIL_DATABASE_AND_LINEAGE_BOUNDARY_IS_PROVEN'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
