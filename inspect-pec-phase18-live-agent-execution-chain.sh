#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== PEC COMPILER FULL CONTRACT ===\n'
sed -n '1,320p' server/execution/package-to-execution-compiler.ts 2>/dev/null || true

printf '\n=== PEC BINDER FULL CONTRACT ===\n'
sed -n '1,320p' server/execution/pec-runtime-binder.ts 2>/dev/null || true

printf '\n=== PHASE18 STORE AND TICK ===\n'
sed -n '1,320p' server/orchestrator/phase18_store.mjs 2>/dev/null || true
sed -n '1,360p' server/orchestrator/phase18_tick.mjs 2>/dev/null || true
sed -n '1,320p' server/orchestrator/phase18_orchestration.mjs 2>/dev/null || true

printf '\n=== PEC PRODUCTION CALLERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B30 -A80 \
  '(executePackageThroughPEC|compilePackageToExecutionPlan)' \
  server db scripts \
  2>/dev/null || true

printf '\n=== PHASE18 QUEUE PRODUCERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B25 -A70 \
  '(\.enqueue\(|store\.enqueue|queue\.push)' \
  server db scripts \
  2>/dev/null | head -n 3000 || true

printf '\n=== PHASE18 QUEUE CONSUMERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --include='*.ts' --include='*.mjs' \
  -B30 -A90 \
  '(\.dequeue\(|store\.dequeue|queue\.shift|task\.agent|item\.agent|payload\.agent)' \
  server db scripts \
  2>/dev/null | head -n 4000 || true

printf '\n=== EXECUTION TASK TYPE OWNERSHIP ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(ExecutionTask|type Agent =|agent:[[:space:]]*"matilda"|agent:[[:space:]]*"cade"|agent:[[:space:]]*"effie"|agent:[[:space:]]*"atlas")' \
  server db \
  2>/dev/null | head -n 4000 || true

printf '\n=== PHASE18 STARTUP / SERVER ENTRYPOINT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' \
  -B30 -A100 \
  '(startPhase18OrchestrationRuntime|PHASE18_ENABLE_ORCHESTRATION|__orchestratorStore|__orchestrator)' \
  server/index.ts server \
  2>/dev/null | head -n 4000 || true

printf '\n=== PEC / PHASE18 LINEAGE ===\n'
for f in \
  server/execution/package-to-execution-compiler.ts \
  server/execution/pec-runtime-binder.ts \
  server/orchestrator/phase18_store.mjs \
  server/orchestrator/phase18_tick.mjs \
  server/orchestrator/phase18_orchestration.mjs
do
  [ -f "$f" ] || continue
  echo
  echo "--- $f ---"
  git log --follow \
    --date=iso \
    --format='%H %ad %s' \
    -- "$f" | head -50
done

printf '\n=== AGENT SET HISTORY IN PEC ===\n'
git log --all -p -- \
  server/execution/package-to-execution-compiler.ts \
  server/execution/pec-runtime-binder.ts \
  2>/dev/null | grep -nE \
  '^(commit |Date:|    Phase|[-+].*type Agent|[-+].*agent:|[-+].*matilda|[-+].*cade|[-+].*effie|[-+].*atlas)' \
  | head -n 1000 || true

printf '\n=== ROUTER VS PEC IDENTITY SET ===\n'
echo 'ROUTER_AGENT_ID_SET=matilda,cade,effie,atlas,unknown'
grep -nE \
  '(type Agent =|agent:[[:space:]]*"(matilda|cade|effie|atlas)")' \
  server/execution/package-to-execution-compiler.ts \
  2>/dev/null || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_PEC_BOUND_TO_A_CURRENT_PRODUCTION_CALLER'
echo 'QUESTION_2=IS_PHASE18_STARTED_BY_THE_CURRENT_SERVER_ENTRYPOINT'
echo 'QUESTION_3=DO_PHASE18_QUEUE_ITEMS_REACH_ANY_EXECUTION_CONSUMER'
echo 'QUESTION_4=DOES_THE_EXECUTION_CONSUMER_ENFORCE_OR_TRUST_TASK_AGENT'
echo 'QUESTION_5=IS_PEC_AGENT_ASSIGNMENT_CURRENT_ARCHITECTURE_OR_HISTORICAL_SCAFFOLDING'
echo 'QUESTION_6=WHY_DOES_PEC_DEFINE_MATILDA_CADE_EFFIE_WHILE_ROUTER_ADDS_ATLAS'
echo 'QUESTION_7=IS_ATLAS_INTENTIONALLY_OUTSIDE_EXECUTION_GRAPH_ASSIGNMENT'
echo 'QUESTION_8=CAN_ANY_EXISTING_AGENT_SET_BE_CALLED_CANONICAL_AFTER_THIS_TRACE'
echo 'DO_NOT_MUTATE_IDENTITY_UNTIL_PEC_TO_EXECUTION_LIVENESS_IS_PROVEN=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
