#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== ROUTE IMPORTS AND MOUNTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B15 -A30 \
  '(matilda-routing-route|matilda-assignment-route|matilda-execution-planning-route|/api/matilda/routing|/api/matilda/assignment|/api/matilda/execution-planning)' \
  server db routes scripts \
  2>/dev/null || true

printf '\n=== DIRECT RUNTIME IMPORTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B15 -A30 \
  '(matilda-routing-runtime|matilda-assignment-runtime|matilda-execution-planning-runtime)' \
  server db routes scripts \
  2>/dev/null || true

printf '\n=== CREATE FUNCTION CALLERS EXCLUDING DEFINITIONS AND TESTS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  '(createRouting\(|createAssignment\(|createExecutionPlan\()' \
  server db routes scripts \
  2>/dev/null || true

printf '\n=== SERVER ROUTE REGISTRATION SURFACE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B10 -A25 \
  '(app\.use|router\.use|register.*route|mount.*route)' \
  server \
  2>/dev/null | head -n 2500 || true

printf '\n=== ROUTE FILE LINEAGE ===\n'
for f in \
  server/routes/matilda-routing-route.ts \
  server/routes/matilda-assignment-route.ts \
  server/routes/matilda-execution-planning-route.ts
do
  echo
  echo "--- $f ---"
  git log --follow \
    --date=iso \
    --format='%H %ad %s' \
    -- "$f" 2>/dev/null | head -30 || true
done

printf '\n=== RUNTIME FILE LINEAGE ===\n'
for f in \
  db/matilda-routing-runtime.ts \
  db/matilda-assignment-runtime.ts \
  db/matilda-execution-planning-runtime.ts
do
  echo
  echo "--- $f ---"
  git log --follow \
    --date=iso \
    --format='%H %ad %s' \
    -- "$f" 2>/dev/null | head -30 || true
done

printf '\n=== CURRENT DATABASE ACTIVITY EVIDENCE ===\n'
for dbfile in motherboard.sqlite db/main.db; do
  [ -f "$dbfile" ] || continue
  echo
  echo "--- $dbfile ---"
  stat -f 'modified=%Sm size=%z' -t '%Y-%m-%d %H:%M:%S %z' "$dbfile" 2>/dev/null || true
done

printf '\n=== RECONCILIATION REFERENCES TO ROUTING / ASSIGNMENT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B20 -A50 \
  '(reconcil.*(routing|assignment|assigned_agent)|(routing|assignment|assigned_agent).*reconcil)' \
  server db \
  2>/dev/null || true

printf '\n=== CURRENT AGENT IDENTITY REFERENCES OUTSIDE LEGACY CHAIN ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='matilda-routing-runtime.ts' \
  --exclude='matilda-assignment-runtime.ts' \
  --exclude='matilda-routing-route.ts' \
  --exclude='matilda-assignment-route.ts' \
  --include='*.ts' --include='*.mjs' \
  -B15 -A35 \
  '(assigned_agent|assignedAgent|AgentId|agent_id|routing_destination)' \
  server db \
  2>/dev/null | head -n 3000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=ARE_JULY_ROUTING_AND_ASSIGNMENT_ROUTES_MOUNTED_IN_CURRENT_SERVER'
echo 'QUESTION_2=DOES_ANY_CURRENT_PRODUCTION_CALLER_INVOKE_CREATE_ROUTING_OR_CREATE_ASSIGNMENT'
echo 'QUESTION_3=IS_MOTHERBOARD_SQLITE_PART_OF_CURRENT_RUNTIME_OR_ONLY_LEGACY_INFRASTRUCTURE'
echo 'QUESTION_4=IS_SEPTEMBER_EXECUTION_PLANNING_ROUTE_MOUNTED_AND_LIVE'
echo 'QUESTION_5=DOES_CURRENT_RECONCILIATION_HAVE_A_SEPARATE_AGENT_IDENTITY_SURFACE'
echo 'QUESTION_6=WHAT_CURRENT_SURFACE_SHOULD_DEFINE_SYSTEM_AGENT_IDENTITY'
echo 'DO_NOT_PROMOTE_LEGACY_ROUTER_OR_ASSIGNMENT_TYPES_TO_CANONICAL_IDENTITY_WITHOUT_LIVENESS_PROOF=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
