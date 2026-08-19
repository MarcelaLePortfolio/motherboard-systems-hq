#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
  'COMPLETED_PHASE=EXECUTIVE_MISSION_OVERVIEW' \
  'COMPLETED_PHASE_STATUS=CLOSED_AND_DR_PROTECTED' \
  'COMPLETED_PHASE_CHECKPOINT=d94e8d2e' \
  'NEXT_ACTION=DETERMINE_NEXT_EXECUTIVE_MISSION_CONTROL_PHASE' \
  'MODE=COLLABORATION' \
  'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== EXECUTIVE MISSION CONTROL REFERENCES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'Executive Mission Control|Executive Mission Overview|Mission Control|next phase|phase map|corridor map' \
  docs scripts client/src db server 2>/dev/null | head -260

printf '\n=== RECENT EXECUTIVE MISSION CONTROL CHECKPOINTS ===\n'
find docs/checkpoints -maxdepth 1 -type f \
  -name 'EXECUTIVE_MISSION_OVERVIEW*' \
  -print | sort | xargs -r -n1 sh -c 'echo "=== $0 ==="; cat "$0"'

printf '\n=== CURRENT REPOSITORY STATE ===\n'
git log -12 --oneline --decorate
git status --short
