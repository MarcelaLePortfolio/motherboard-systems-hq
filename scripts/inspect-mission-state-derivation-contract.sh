#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'ACTIVE_CORRIDOR=MISSION_STATE_PROJECTION' \
  'CORRIDOR_1_DR=20260818_193830' \
  'CURRENT_CHECKPOINT=848936f5' \
  'PURPOSE=RESOLVE_STATE_DERIVATION_RULES_BEFORE_IMPLEMENTATION'

printf '\n=== ASSEMBLER TEST CONTRACT ===\n'
cat db/mission-read-model-assembler.test.ts

printf '\n=== GOVERNANCE AUTHORIZATION RULES ===\n'
sed -n '90,185p' db/governance-lifecycle-enforcement.ts

printf '\n=== DELEGATION PRODUCTION VALUES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'authorization_state:|authorization_state =|AUTHORIZED|authorized_for_governance_validation' \
  server/delegation db/matilda-delegation-runtime.ts db/governance-runtime.ts 2>/dev/null | head -160

printf '\n=== VALIDATION PRODUCTION VALUES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'validation_status:|validation_status =|VALIDATION_PASSED' \
  server/validation db/governance-runtime.ts 2>/dev/null | head -160

printf '\n=== ENVELOPE GATE PRODUCTION VALUES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'gate_status:|gate_status =|OPEN|PASSED' \
  server/gate db/governance-runtime.ts 2>/dev/null | head -160

printf '\n=== CURRENT WORKTREE ===\n'
git status --short
