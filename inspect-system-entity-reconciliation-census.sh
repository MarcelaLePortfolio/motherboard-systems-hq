#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"

printf '\n=== NAMED ENTITY / AUTHORITY DEFINITIONS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B20 -A60 \
  '(named system authority|operational coordination authority|agent|actor|orchestrator|interpreter|coordinator|executor|validator|observer|planner|department coordinator)' \
  server db docs \
  2>/dev/null | head -n 12000 || true

printf '\n=== PROMOTION / RECONCILIATION CENSUS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.md' --include='*.txt' --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  '(promot|promotion|reconcil|reconciliation|role transition|authority transition|identity transition)' \
  docs evidence server db scripts \
  2>/dev/null | head -n 15000 || true

printf '\n=== NAMED ENTITY FILES ===\n'
find server db docs evidence scripts \
  -type f \
  \( -iname '*agent*' \
     -o -iname '*actor*' \
     -o -iname '*authority*' \
     -o -iname '*promotion*' \
     -o -iname '*reconciliation*' \
     -o -iname '*ellis*' \
     -o -iname '*atlas*' \
     -o -iname '*cade*' \
     -o -iname '*effie*' \
     -o -iname '*matilda*' \
     -o -iname '*bastion*' \
     -o -iname '*stryxx*' \) \
  -print 2>/dev/null | sort | head -n 8000 || true

printf '\n=== AUTHORITY-BEARING IDENTIFIERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.md' \
  -B15 -A45 \
  '([a-zA-Z0-9_-]+_(authorized|authority)|authority.*[a-zA-Z0-9_-]+|assigned_(agent|actor|department)|routing_destination|delegation.*target)' \
  server db docs \
  2>/dev/null | head -n 12000 || true

printf '\n=== RECONCILIATION HISTORY COMMITS ===\n'
git log --all \
  --date=iso \
  --format='%H %ad %s' \
  --grep='reconcil' \
  --grep='promot' \
  --grep='authority' \
  --grep='agent' \
  --grep='actor' \
  --regexp-ignore-case \
  | head -n 3000 || true

printf '\n=== KNOWN-NAME CROSS CHECK ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  printf 'CURRENT_SOURCE_REFERENCES='
  grep -RilE \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    --include='*.ts' --include='*.mjs' \
    "\\b${name}\\b" server db 2>/dev/null | wc -l | tr -d ' '
  printf 'HISTORICAL_COMMITS='
  git log --all -S"$name" --format='%H' -- . 2>/dev/null | wc -l | tr -d ' '
done

printf '\n=== POSSIBLE ADDITIONAL NAMED SYSTEM ENTITIES ===\n'
grep -RhoEi \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.md' --include='*.ts' --include='*.mjs' \
  '(authority|agent|actor|coordinator|orchestrator|interpreter|executor|observer|validator)[[:space:]:=-]+[A-Z][A-Za-z0-9_-]+' \
  docs server db \
  2>/dev/null | sort -fu | head -n 3000 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHAT_ARE_ALL_NAMED_SYSTEM_ENTITIES'
echo 'QUESTION_2=WHICH_ENTITIES_HAVE_DURABLE_RECONCILIATION_OR_PROMOTION_EVIDENCE'
echo 'QUESTION_3=WHICH_ARE_AGENTS_OR_ACTORS'
echo 'QUESTION_4=WHICH_ARE_COORDINATION_AUTHORITIES'
echo 'QUESTION_5=WHICH_ARE_INTERPRETERS_OR_ORCHESTRATORS'
echo 'QUESTION_6=WHICH_HAVE_DELEGATION_ELIGIBILITY'
echo 'QUESTION_7=WHICH_HAVE_EXECUTION_CAPABILITY'
echo 'QUESTION_8=WHICH_HAVE_NO_NEW_AUTHORITY_DESPITE_BEING_NAMED_RUNTIME_ENTITIES'
echo 'QUESTION_9=ARE_BASTION_OR_STRYXX_PRESENT_IN_REPOSITORY_RECONCILIATION_HISTORY'
echo 'QUESTION_10=ARE_THERE_NAMED_ENTITIES_WE_HAVE_NOT_YET_CONSIDERED'
echo 'QUESTION_11=IS_AGENT_ACTUALLY_THE_CANONICAL_UMBRELLA_CATEGORY_OR_ONLY_ONE_ENTITY_CLASS'
echo 'QUESTION_12=DOES_A_CANONICAL_SYSTEM_ENTITY_MODEL_ALREADY_EXIST_UNDER_DIFFERENT_TERMINOLOGY'
echo 'DO_NOT_FORCE_ALL_SYSTEM_ENTITIES_INTO_AGENT_CATEGORY=YES'
echo 'DO_NOT_PROMOTE_LOCAL_ALLOWLISTS_TO_GLOBAL_REGISTRY=YES'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== FINAL REPOSITORY STATE ===\n'
git status --short
