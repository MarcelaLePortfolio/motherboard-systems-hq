#!/usr/bin/env bash
set -u

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean || exit 1

printf '\n=== PHASE 18 AGENT STORE ===\n'
sed -n '1,260p' server/orchestrator/phase18_store.mjs 2>/dev/null || true

printf '\n=== PHASE 18 AGENT PRODUCERS / CONSUMERS ===\n'
grep -RniE \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  '(upsertAgent|state\.agents|agents\.get|agents\.set|agentId|agent_id)' \
  server/orchestrator server \
  2>/dev/null | head -n 1000 || true

printf '\n=== EXISTING RECONCILIATION ARTIFACTS ===\n'
for f in \
  inspect-current-entity-reconciliation-lineage.sh \
  reconcile-live-phase-4-state.sh \
  inspect-pre-orchestrator-authority-and-project-identity-gap.sh
do
  if test -f "$f"; then
    printf '\n--- %s ---\n' "$f"
    sed -n '1,420p' "$f"
  fi
done

printf '\n=== AGENT STORE HISTORY ===\n'
git log --all --follow --date=short \
  --format='%h %ad %s' \
  -- server/orchestrator/phase18_store.mjs | head -100 || true

printf '\n=== HISTORICAL AGENT-ID DEFINITIONS ===\n'
git log --all -S'AgentId' --oneline -- server | head -100 || true
git log --all -S'upsertAgent' --oneline -- server | head -100 || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
echo 'ELLIS_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'BASTION_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'STRYXX_CANONICAL_AGENT=NOT_ESTABLISHED'
echo 'CURRENT_EXPLICIT_AGENT_ID_UNION=MATILDA_CADE_EFFIE_ATLAS_UNKNOWN'
echo 'QUESTION=DO_PHASE18_OR_RECONCILIATION_LINEAGES_ESTABLISH_ADDITIONAL_CANONICAL_AGENT_IDENTITIES'
echo 'MUTATION_PERFORMED=NO'

printf '\n=== REPOSITORY STATE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
git status --short
