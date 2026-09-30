#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== ROUTING RUNTIME ===\n'
sed -n '1,320p' db/matilda-routing-runtime.ts 2>/dev/null || true

printf '\n=== ASSIGNMENT RUNTIME ===\n'
sed -n '1,360p' db/matilda-assignment-runtime.ts 2>/dev/null || true

printf '\n=== EXECUTION PLANNING RUNTIME ===\n'
sed -n '1,420p' db/matilda-execution-planning-runtime.ts 2>/dev/null || true

printf '\n=== ROUTING ROUTE ===\n'
sed -n '1,260p' server/routes/matilda-routing-route.ts 2>/dev/null || true

printf '\n=== ASSIGNMENT ROUTE ===\n'
sed -n '1,260p' server/routes/matilda-assignment-route.ts 2>/dev/null || true

printf '\n=== EXECUTION PLANNING ROUTE ===\n'
sed -n '1,280p' server/routes/matilda-execution-planning-route.ts 2>/dev/null || true

printf '\n=== SCHEMA DEFINITIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B20 -A80 \
  'CREATE TABLE.*(routing|assignment|execution_plan)|matilda_routings|matilda_assignments|matilda_execution_plans' \
  db server \
  2>/dev/null || true

printf '\n=== CROSS-RUNTIME CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B25 -A60 \
  'createRouting\(|createAssignment\(|createExecutionPlan\(' \
  server db routes \
  2>/dev/null || true

printf '\n=== ASSIGNED AGENT OWNERSHIP ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B30 -A70 \
  'assigned_agent|assignedAgent' \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  server/routes/matilda-routing-route.ts \
  server/routes/matilda-assignment-route.ts \
  server/routes/matilda-execution-planning-route.ts \
  2>/dev/null || true

printf '\n=== LIVE TABLE CONTENTS ===\n'
for table in matilda_routings matilda_assignments matilda_execution_plans; do
  echo
  echo "--- $table ---"
  sqlite3 -header -column db/main.db "SELECT * FROM $table ORDER BY rowid;" 2>/dev/null || \
    echo "$table unavailable"
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_ROUTING_A_DISTINCT_PERSISTED_GOVERNANCE_ARTIFACT'
echo 'QUESTION_2=IS_ASSIGNMENT_A_DISTINCT_PERSISTED_GOVERNANCE_ARTIFACT'
echo 'QUESTION_3=WHICH_ARTIFACT_FIRST_BINDS_AN_AGENT_ID'
echo 'QUESTION_4=DOES_EXECUTION_PLANNING_CONSUME_ASSIGNMENT_OR_INDEPENDENTLY_ACCEPT_ASSIGNED_AGENT'
echo 'QUESTION_5=WHAT_AUTHORITY_MUST_EXIST_BEFORE_ROUTING_OR_ASSIGNMENT'
echo 'QUESTION_6=IS_ANY_CHIEF_OF_STAFF_IDENTITY_PRESENT_IN_THIS_CHAIN'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
