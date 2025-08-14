#!/usr/bin/env bash
# Motherboard Systems HQ — Milestone 4: Full Task Delegation Cycle Runner
# Usage: bash scripts/milestone4/run_milestone4.sh

set -euo pipefail

log() { printf "\n\033[1m%s\033[0m\n" "🔧 $*"; }

REPO_ROOT="$(pwd)"

log "Repo root: $REPO_ROOT"

# 1) Ensure memory directories and files exist
log "Ensuring memory directories and files exist…"
mkdir -p "$REPO_ROOT/memory"
mkdir -p "$REPO_ROOT/scripts/_local/memory"

for f in \
  "$REPO_ROOT/memory/agent_chain_state.json" \
  "$REPO_ROOT/scripts/_local/memory/agent_chain_state.json"
do
  if [ ! -s "$f" ]; then
    echo "{}" > "$f"
  elif ! grep -q "{" "$f" 2>/dev/null; then
    echo "{}" > "$f"
  fi
done

log "Memory files ready."

# 2) Stop and clean previous PM2 processes
log "Cleaning PM2 processes…"
pm2 delete cade 2>/dev/null || true
pm2 delete matilda 2>/dev/null || true
pm2 delete effie 2>/dev/null || true
pm2 delete ui-server 2>/dev/null || true

pkill -f tsx 2>/dev/null || true
for PORT in 3012 3013 3014; do
  PIDS="$(lsof -ti :$PORT || true)"
  if [ -n "${PIDS:-}" ]; then
    echo "$PIDS" | xargs kill -9 || true
  fi
done

# 3) Start agents in correct order
log "Starting agents via PM2…"
pm2 start scripts/_local/agent-runtime/launch-cade.ts --name cade --interpreter tsx --cwd "$REPO_ROOT"
pm2 start scripts/_local/agent-runtime/launch-matilda.ts --name matilda --interpreter tsx --cwd "$REPO_ROOT"
pm2 start scripts/_local/agent-runtime/launch-effie.ts --name effie --interpreter tsx --cwd "$REPO_ROOT"
pm2 start scripts/_local/dev-server.ts --name ui-server --interpreter tsx --cwd "$REPO_ROOT" --no-autorestart

# 4) Save PM2 snapshot
log "Saving PM2 snapshot…"
pm2 save
pm2 ls || true

# 5) Quick heartbeat/log check
log "Tailing logs…"
(pm2 logs cade --lines 10 --nostream || true)
(pm2 logs matilda --lines 10 --nostream || true)
(pm2 logs effie --lines 10 --nostream || true)

# 6) Confirm memory files
log "Checking memory/agent_chain_state.json…"
ls -l "$REPO_ROOT/memory/agent_chain_state.json"
head -n 5 "$REPO_ROOT/memory/agent_chain_state.json"

# 7) Trigger Cade to run full task delegation cycle
log "Triggering Cade to start full task delegation cycle…"
npx tsx -e "import { cadeCommandRouter } from './scripts/agents/cade'; cadeCommandRouter('start full task delegation cycle').then(console.log);"
