#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== CURRENT PRODUCERS: routing_destination ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A80 \
  '(routing_destination[[:space:]]*[:=]|routingDestination[[:space:]]*[:=])' \
  server db scripts client/src \
  2>/dev/null | head -n 12000 || true

printf '\n=== CURRENT PRODUCERS: assigned_agent ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B35 -A80 \
  '(assigned_agent[[:space:]]*[:=]|assignedAgent[[:space:]]*[:=])' \
  server db scripts client/src \
  2>/dev/null | head -n 12000 || true

printf '\n=== CADE / MATILDA ROUTING REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B40 -A100 \
  '((cade|matilda).{0,100}(routing_destination|assigned_agent|assignedAgent|destination|routing|assignment)|(routing_destination|assigned_agent|assignedAgent|destination|routing|assignment).{0,100}(cade|matilda))' \
  server db scripts client/src \
  2>/dev/null | head -n 16000 || true

printf '\n=== POSSIBLE AGENT REGISTRIES / ENUMS / MAPS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -B50 -A140 \
  '(agent_registry|agentRegistry|known_agents|supported_agents|allowed_agents|agent_ids|agentIds|agent_type|agentType|AgentId|AgentType|routing.*map|route.*map)' \
  server db scripts client/src \
  2>/dev/null | head -n 20000 || true

printf '\n=== NAMED SYSTEM IDENTITIES ===\n'
for name in matilda cade effie atlas ellis bastion stryxx; do
  echo
  echo "===== $name ====="
  grep -RniE \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    -B8 -A20 \
    "\\b${name}\\b" \
    server db scripts client/src \
    2>/dev/null | head -n 2500 || true
done

printf '\n=== HISTORY: CADE ===\n'
git log --all -i \
  -G'cade' \
  --date=iso \
  --format='COMMIT %H%nDATE %ad%nSUBJECT %s' \
  -p -- server db scripts \
  2>/dev/null | grep -iE -B20 -A80 \
  '(cade|routing_destination|assigned_agent|assignedAgent)' \
  | head -n 20000 || true

printf '\n=== HISTORY: MATILDA ===\n'
git log --all -i \
  -G'matilda' \
  --date=iso \
  --format='COMMIT %H%nDATE %ad%nSUBJECT %s' \
  -p -- server db scripts \
  2>/dev/null | grep -iE -B20 -A80 \
  '(matilda|routing_destination|assigned_agent|assignedAgent)' \
  | head -n 20000 || true

printf '\n=== DATABASE ROUTING EVIDENCE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  id,
  package_id,
  routing_destination,
  assigned_agent,
  assignment_state,
  created_at,
  updated_at
FROM governance_execution_reconciliation
WHERE routing_destination IS NOT NULL
   OR assigned_agent IS NOT NULL
ORDER BY created_at ASC;
" 2>/dev/null || true

printf '\n=== DATABASE SCHEMA / TRIGGERS / VIEWS ===\n'
sqlite3 db/main.db "
SELECT type, name, sql
FROM sqlite_master
WHERE lower(COALESCE(sql,'')) LIKE '%assigned_agent%'
   OR lower(COALESCE(sql,'')) LIKE '%routing_destination%'
   OR lower(COALESCE(sql,'')) LIKE '%cade%'
   OR lower(COALESCE(sql,'')) LIKE '%matilda%'
ORDER BY type, name;
" 2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'AUTHORITY_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
