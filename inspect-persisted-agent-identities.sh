#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== DATABASE FILES ===\n'
ls -lh db/main.db motherboard.sqlite motherboard.db 2>/dev/null || true

printf '\n=== AGENT / ROUTING / ASSIGNMENT TABLES: MAIN DB ===\n'
sqlite3 db/main.db "
SELECT name
FROM sqlite_master
WHERE type='table'
  AND (
    lower(name) LIKE '%agent%'
    OR lower(name) LIKE '%routing%'
    OR lower(name) LIKE '%assignment%'
    OR lower(name) LIKE '%reconcil%'
    OR lower(name) LIKE '%delegat%'
  )
ORDER BY name;
" 2>/dev/null || true

printf '\n=== DISTINCT AGENT-LIKE VALUES: MAIN DB ===\n'
for table in $(sqlite3 db/main.db "SELECT name FROM sqlite_master WHERE type='table';" 2>/dev/null); do
  cols=$(sqlite3 db/main.db "PRAGMA table_info('$table');" 2>/dev/null | cut -d'|' -f2)
  for col in $cols; do
    case "$col" in
      *agent*|*actor*|*owner*|*destination*|*delegate*)
        echo
        echo "--- db/main.db :: $table.$col ---"
        sqlite3 db/main.db "SELECT \"$col\", COUNT(*) FROM \"$table\" WHERE \"$col\" IS NOT NULL AND TRIM(CAST(\"$col\" AS TEXT)) <> '' GROUP BY \"$col\" ORDER BY COUNT(*) DESC;" 2>/dev/null || true
        ;;
    esac
  done
done

for dbfile in motherboard.sqlite motherboard.db; do
  [ -f "$dbfile" ] || continue
  printf '\n=== DISTINCT AGENT-LIKE VALUES: %s ===\n' "$dbfile"
  for table in $(sqlite3 "$dbfile" "SELECT name FROM sqlite_master WHERE type='table';" 2>/dev/null); do
    cols=$(sqlite3 "$dbfile" "PRAGMA table_info('$table');" 2>/dev/null | cut -d'|' -f2)
    for col in $cols; do
      case "$col" in
        *agent*|*actor*|*owner*|*destination*|*delegate*)
          echo
          echo "--- $dbfile :: $table.$col ---"
          sqlite3 "$dbfile" "SELECT \"$col\", COUNT(*) FROM \"$table\" WHERE \"$col\" IS NOT NULL AND TRIM(CAST(\"$col\" AS TEXT)) <> '' GROUP BY \"$col\" ORDER BY COUNT(*) DESC;" 2>/dev/null || true
          ;;
      esac
    done
  done
done

printf '\n=== PRODUCERS OF ROUTING DESTINATION / ASSIGNED AGENT ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A100 \
  '(routing_destination[[:space:]]*[:=]|assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=])' \
  server db scripts client/src \
  2>/dev/null | head -n 20000 || true

printf '\n=== RECONCILIATION AGENT IDENTITY REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A120 \
  '(reconcil.{0,80}(agent|actor|destination|assignment)|(agent|actor|destination|assignment).{0,80}reconcil)' \
  server db scripts docs \
  2>/dev/null | head -n 20000 || true

printf '\n=== HISTORICAL NAMED ENTITY ASSIGNMENT SEARCH ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  git log --all -G"(assigned_agent|assignedAgent|routing_destination).*[\"']${name}[\"']|[\"']${name}[\"'].*(assigned_agent|assignedAgent|routing_destination)" \
    --date=short \
    --format='%h %ad %s' \
    -- server db scripts \
    2>/dev/null | head -100 || true
done

printf '\n=== CLASSIFICATION TARGET ===\n'
echo 'QUESTION_1=WHICH_IDENTITIES_HAVE_ACTUALLY_BEEN_PERSISTED_AS_AGENTS_OR_DESTINATIONS'
echo 'QUESTION_2=WHICH_RUNTIME_PRODUCED_THOSE_IDENTITIES'
echo 'QUESTION_3=DOES_RECONCILIATION_DEFINE_OR_ONLY_PRESERVE_AGENT_IDENTITY'
echo 'QUESTION_4=ARE_THERE_SYSTEM_ENTITIES_BEYOND_MATILDA_CADE_EFFIE_ATLAS'
echo 'QUESTION_5=WHICH_OF_THOSE_IDENTITIES_ARE_CURRENT_VS_HISTORICAL_OR_STALE'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
