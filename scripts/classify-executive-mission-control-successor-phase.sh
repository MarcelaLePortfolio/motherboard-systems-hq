#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'COMPLETED_PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'COMPLETED_PHASE_STATUS=CLOSED_AND_DR_PROTECTED' \
  'COMPLETED_PHASE_CHECKPOINT=d94e8d2e' \
  'SUCCESSOR_PHASE_CANDIDATE=DELEGATION_WORKSPACE' \
  'BASIS=EXECUTIVE_WORKSPACE_ARCHITECTURE_SEQUENCES_MISSION_CONTROL_BEFORE_DELEGATION' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_DELEGATION_WORKSPACE_PHASE_AND_CORRIDOR_MAP'

printf '\n=== SUCCESSOR ARCHITECTURE EVIDENCE ===\n'
sed -n '140,235p' docs/architecture/EXECUTIVE_WORKSPACE_MODEL.md
sed -n '300,340p' docs/architecture/EXECUTIVE_WORKSPACE_MODEL.md

printf '\n=== DELEGATION WORKSPACE REFERENCES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Delegation workspace|Delegation Workspace|CEO inbox|Delegation|executive inbox|decision inbox' \
  docs/architecture docs client/src server db 2>/dev/null | head -280

printf '\n=== EXISTING DELEGATION AUTHORITY ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'matilda-delegation|governance_delegations|production-delegation|authorization_state' \
  db server routes 2>/dev/null | head -240

printf '\n=== SUCCESSOR PHASE CLASSIFICATION ===\n'
printf '%s\n' \
  'SUCCESSOR_PHASE=DELEGATION_WORKSPACE' \
  'SUCCESSOR_PURPOSE=CEO_DECISION_AND_DELEGATION_INTERFACE' \
  'MISSION_CONTROL_ROLE=OBSERVABILITY_COMPLETE' \
  'DELEGATION_ROLE=EXECUTIVE_ACTION_HANDOFF' \
  'NEW_AUTHORITY_MAY_NOT_BE_INVENTED=YES' \
  'EXISTING_GOVERNANCE_AUTHORITY_MUST_BE_REUSED=YES' \
  'PHASE_MAP_STATUS=REQUIRES_BOUNDED_CLASSIFICATION' \
  'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
