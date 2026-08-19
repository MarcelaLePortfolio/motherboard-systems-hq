#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'CORRIDOR=PIPELINE_POSITION'

printf '\n=== LIVE MAIN.DB TABLE INVENTORY ===\n'
sqlite3 db/main.db ".tables"

printf '\n=== OPERATIONAL INTAKE RUNTIME PERSISTENCE TARGET ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'CREATE TABLE IF NOT EXISTS operational_intake|CREATE TABLE operational_intake|new Database\\(|main.db|motherboard.sqlite' \
  db/operational-intake-runtime.ts db server/lifecycle 2>/dev/null | head -220

printf '\n=== OPERATIONAL INTAKE RUNTIME ===\n'
sed -n '1,280p' db/operational-intake-runtime.ts

printf '\n=== LIVE GOVERNANCE PIPELINE TABLE SCHEMAS ===\n'
sqlite3 db/main.db ".schema governance_delegations"
sqlite3 db/main.db ".schema governance_validation_results"
sqlite3 db/main.db ".schema governance_envelope_gates"
sqlite3 db/main.db ".schema governance_envelopes"

printf '\n=== CURRENT CORRIDOR 3 CHECKPOINT ===\n'
git rev-parse --short HEAD
git status --short
