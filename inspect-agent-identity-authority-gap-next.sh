#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== VERIFIED DETERMINATION ===\n'
echo 'SINGLE_CURRENT_CANONICAL_AGENT_IDENTITY_SOURCE=NOT_ESTABLISHED'
echo 'IDENTITY_MODEL_APPEARS_DISTRIBUTED=YES'
echo 'CURRENT_ROUTER_AGENT_ID_AUTHORITY=LOCAL_ROUTING_TYPE_ONLY'
echo 'HISTORICAL_RUNTIME_IDENTITIES=MATILDA_CADE_EFFIE_ATLAS'
echo 'ELLIS_CURRENT_RUNTIME_ADDRESSABILITY=NOT_ESTABLISHED'
echo 'BASTION_CURRENT_RUNTIME_ADDRESSABILITY=NOT_ESTABLISHED'
echo 'STRYXX_CURRENT_RUNTIME_ADDRESSABILITY=NOT_ESTABLISHED'
echo 'IDENTITY_AUTHORITY_GAP_BEFORE_ROUTER_EXPANSION=YES'

printf '\n=== ELLIS PROMOTION / RECONCILIATION LINEAGE ===\n'
git log --all \
  --date=iso \
  --format='COMMIT=%H%nDATE=%ad%nSUBJECT=%s' \
  -G'([Ee]llis|promotion|promoted|reconciliation|reconcile)' \
  -- server db docs scripts config \
  2>/dev/null | head -n 12000 || true

printf '\n=== ELLIS EXACT HISTORY ===\n'
git log --all -S'Ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- server db docs scripts config \
  2>/dev/null | head -n 1000 || true

git log --all -S'ellis' \
  --date=iso \
  --format='%H %ad %s' \
  -- server db docs scripts config \
  2>/dev/null | head -n 1000 || true

printf '\n=== CURRENT ELLIS STRUCTURAL EVIDENCE ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  --include='*.json' --include='*.md' \
  -B40 -A160 \
  '([Ee]llis.{0,120}(promotion|promoted|agent|identity|authority|role|coordinator|delegat|reconcil|runtime)|((promotion|promoted|agent|identity|authority|role|coordinator|delegat|reconcil|runtime).{0,120}[Ee]llis))' \
  server db docs scripts config \
  2>/dev/null | head -n 12000 || true

printf '\n=== HISTORICAL ELLIS FILES ===\n'
git log --all --name-only --format= \
  | grep -i 'ellis' \
  | sort -fu \
  | head -n 2000 || true

printf '\n=== POSSIBLE IDENTITY AUTHORITY SURFACES ===\n'
find server db scripts config docs \
  -type f \
  \( -iname '*agent*' -o -iname '*identity*' -o -iname '*role*' \
     -o -iname '*registry*' -o -iname '*actor*' -o -iname '*coordinator*' \) \
  -print 2>/dev/null \
  | sort | head -n 5000 || true

printf '\n=== CURRENT ACTOR / ROLE / EXECUTOR ENUMS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  -B30 -A120 \
  '(type|enum|const).{0,80}(Actor|Agent|Executor|Coordinator|Role|Worker|Principal|Identity)|((actor|agent|executor|coordinator|role|worker|principal|identity)[_-]?(id|name|type))' \
  server db scripts config \
  2>/dev/null | head -n 14000 || true

printf '\n=== DATABASE COLUMNS THAT MAY CARRY IDENTITY ===\n'
if [ -f db/main.db ]; then
  sqlite3 db/main.db "
    SELECT m.name AS table_name, p.name AS column_name, p.type
    FROM sqlite_master m
    JOIN pragma_table_info(m.name) p
    WHERE m.type='table'
      AND (
        lower(p.name) LIKE '%agent%'
        OR lower(p.name) LIKE '%actor%'
        OR lower(p.name) LIKE '%identity%'
        OR lower(p.name) LIKE '%executor%'
        OR lower(p.name) LIKE '%coordinator%'
        OR lower(p.name) LIKE '%owner%'
        OR lower(p.name) LIKE '%role%'
      )
    ORDER BY m.name, p.cid;
  " 2>/dev/null || true
fi

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=IS_ELLIS_PROMOTION_EXPLICITLY_RECONCILED_IN_HISTORY'
echo 'QUESTION_2=WHAT_EXACT_IDENTITY_OR_ROLE_DID_PROMOTION_GRANT'
echo 'QUESTION_3=DID_PROMOTION_MAKE_ELLIS_AN_AGENT_OR_ONLY_A_COORDINATOR'
echo 'QUESTION_4=WHAT_AUTHORITY_SURFACE_RECORDED_THE_PROMOTION'
echo 'QUESTION_5=DOES_THAT_AUTHORITY_SURFACE_HAVE_A_CURRENT_SUCCESSOR'
echo 'QUESTION_6=CAN_THAT_SURFACE_DEFINE_THE_CANONICAL_IDENTITY_MODEL'
echo 'QUESTION_7=SHOULD_ROUTER_MEMBERSHIP_BE_DERIVED_FROM_IDENTITY_PLUS_CAPABILITY_INSTEAD_OF_HAND_EDITED'
echo 'IDENTITY_MUTATION=NO'
echo 'ROUTER_MUTATION=NO'
echo 'AUTHORITY_MUTATION=NO'
echo 'RUNTIME_MUTATION=NO'
echo 'WORKTREE_CLEANUP=NO'

printf '\n=== REPOSITORY STATE ===\n'
git status --short
