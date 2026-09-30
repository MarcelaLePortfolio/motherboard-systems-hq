#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CURRENT DETERMINATION ===\n'
echo 'ELLIS_CANONICAL_ASSIGNMENT_AUTHORITY=YES'
echo 'ELLIS_CANONICAL_LIFECYCLE_ACTOR=YES'
echo 'ELLIS_GENERIC_ROUTER_AGENT=NOT_ESTABLISHED'
echo 'ELLIS_EXECUTABLE_AGENT_IDENTITY=NOT_YET_ESTABLISHED'
echo 'CONFIG_AGENTS_JSON_RUNTIME_AUTHORITY=NO_CURRENT_CONSUMER_FOUND'
echo 'NEXT_STEP=LOCATE_EXACT_IMPLEMENTED_ELLIS_BOUNDARY_AND_COMPARE_WITH_EXECUTABLE_AGENT_CONTRACTS'

printf '\n=== EXACT LIFECYCLE IMPLEMENTATION FILES ===\n'
find server db \
  -type f \( -name '*.ts' -o -name '*.mjs' -o -name '*.js' \) \
  -not -path '*/dist/*' \
  -not -path '*/node_modules/*' \
  -print0 2>/dev/null |
while IFS= read -r -d '' f; do
  if grep -qiE '(ellis|assignment_state|assigned_department|assigned_actor|routing_history)' "$f"; then
    echo "$f"
  fi
done

printf '\n=== ELLIS SYMBOL DEFINITIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  '(^|[[:space:]])(export[[:space:]]+)?(async[[:space:]]+)?(function|class|const|let|var|interface|type)[[:space:]]+[A-Za-z0-9_]*[Ee]llis[A-Za-z0-9_]*' \
  server db scripts \
  2>/dev/null | head -n 5000 || true

printf '\n=== ASSIGNMENT SYMBOL DEFINITIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  '(^|[[:space:]])(export[[:space:]]+)?(async[[:space:]]+)?(function|class|const|let|var|interface|type)[[:space:]]+[A-Za-z0-9_]*(Assignment|Assign|Route)[A-Za-z0-9_]*' \
  server db \
  2>/dev/null | head -n 7000 || true

printf '\n=== GOVERNANCE LIFECYCLE ROUTE AND CALL GRAPH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B30 -A140 \
  '(/api/governance/lifecycle|governance.*lifecycle|lifecycle.*governance)' \
  server db \
  2>/dev/null | head -n 14000 || true

printf '\n=== ASSIGNED TRANSITION WRITERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B40 -A160 \
  '(assignment_state.{0,80}assigned|ASSIGNED|assigned_department[[:space:]]*[:=]|assigned_actor[[:space:]]*[:=]|routing_history)' \
  server db \
  2>/dev/null | head -n 18000 || true

printf '\n=== CADE EXECUTABLE IDENTITY CONTRACT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B20 -A100 \
  '(executeCadeAction|cade-executor|chosen\.id === "cade")' \
  server \
  2>/dev/null | head -n 6000 || true

printf '\n=== EFFIE EXECUTABLE IDENTITY SURFACES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B20 -A100 \
  '(executeEffie|effie-executor|agent.*effie|effie.*agent)' \
  server scripts \
  2>/dev/null | head -n 6000 || true

printf '\n=== ATLAS EXECUTABLE IDENTITY SURFACES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B20 -A100 \
  '(executeAtlas|atlas-executor|agent.*atlas|atlas.*agent)' \
  server scripts \
  2>/dev/null | head -n 6000 || true

printf '\n=== ROUTER AGENT CONTRACT ===\n'
sed -n '1,180p' server/orchestration/router.ts 2>/dev/null || true

printf '\n=== ROUTER CALL GRAPH ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B20 -A80 \
  '(routeTask\(|AgentSnapshot|AgentId)' \
  server scripts \
  2>/dev/null | head -n 10000 || true

printf '\n=== ELLIS HISTORICAL IMPLEMENTATION LINEAGE ===\n'
git log --all \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -G'(Ellis|ellis|assignment_state|assigned_department|assigned_actor|routing_history)' \
  -- server db \
  2>/dev/null | head -n 8000 || true

printf '\n=== CLASSIFICATION ===\n'
echo 'PROVEN_1=ELLIS_EXISTS_AS_CANONICAL_NAMED_LIFECYCLE_AUTHORITY'
echo 'PROVEN_2=ELLIS_OWNS_ASSIGNMENT_MUTATIONS'
echo 'PROVEN_3=ASSIGNED_IS_OUTCOME_OF_ELLIS_COORDINATION'
echo 'PROVEN_4=GENERIC_ROUTER_AGENT_ID_CURRENTLY_EXCLUDES_ELLIS'
echo 'UNRESOLVED_1=WHETHER_ELLIS_HAS_EXECUTABLE_RUNTIME_COMPONENT'
echo 'UNRESOLVED_2=WHETHER_AGENT_ID_MEANS_ALL_AGENTS_OR_ONLY_GENERIC_ROUTER_TARGETS'
echo 'UNRESOLVED_3=WHETHER_ADDING_ELLIS_TO_AGENT_ID_WOULD_CORRECT_IDENTITY_OR_WRONGLY_EXPAND_ROUTABILITY'
echo 'DECISION_RULE=DO_NOT_ADD_ELLIS_TO_AGENT_ID_UNLESS_EXECUTABLE_IDENTITY_AND_GENERIC_ROUTABILITY_ARE_BOTH_PROVEN'
echo 'IDENTITY_MUTATION=NO'
echo 'ROUTER_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
