#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 4 · DOWNSTREAM OPERATIONAL STATE BOUNDARY\n'
printf 'STATUS: 🟢 ACTIVE · RUNTIME DISPOSITION CLASSIFICATION\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=DOWNSTREAM_OPERATIONAL_STATE_BOUNDARY' \
'CORRIDOR_3_DR=6de2a611' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== DOWNSTREAM LIFECYCLE CANONICAL CONTRACT ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'Canonical Package.*Delegation|Delegation.*Governance Validation|Governance Validation.*Envelope|Package.*Delegation.*Governance|pending_governance_validation|authorized_for_governance_validation' \
  docs/governance docs/contracts docs/architecture 2>/dev/null | head -420 || true

printf '\n=== DOWNSTREAM IMPLEMENTATION AUTHORIZATION HISTORY ===\n'
git log --all --oneline --decorate \
  --grep='delegation runtime\|governance validation runtime\|envelope runtime\|governance runtime integration\|route mounting\|mount governance' \
  -120

printf '\n=== GOVERNANCE RUNTIME IMPLEMENTATION CHECKPOINTS ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'Governance Runtime Integration|Delegation.*VALIDATED|Governance Validation.*VALIDATED|Envelope.*VALIDATED|production.*Delegation|production.*Validation|production.*Envelope' \
  docs 2>/dev/null | head -420 || true

printf '\n=== ROUTE-MOUNT AUTHORIZATION / DEFERRAL EVIDENCE ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'route.*out of scope|routes.*out of scope|route mounting.*authorized|route mounting.*not authorized|mount.*not authorized|mounting.*deferred|API routes.*out of scope|API route.*authorized' \
  docs scripts 2>/dev/null | head -420 || true

printf '\n=== ACTIVE SERVER MOUNT HISTORY ===\n'
git log --all --oneline --decorate -p -- server/index.ts \
  | grep -E -C 6 'governance|delegation|validation|envelope|matildaCanonicalPackageRouter' \
  | head -420 || true

printf '\n=== CORRIDOR 4 DECISION TARGET ===\n'
printf '%s\n' \
'QUESTION_1=Was downstream governance implementation validated but route mounting intentionally withheld?' \
'QUESTION_2=Was downstream governance ever mounted and later removed or rolled back?' \
'QUESTION_3=Does current architecture require governance runtime restoration before Mission Control active binding?' \
'QUESTION_4=Is that restoration outside Executive Mission Control scope?' \
'IF_VALIDATED_BUT_INTENTIONALLY_UNMOUNTED=UPSTREAM_RUNTIME_ACTIVATION_DEPENDENCY' \
'IF_PREVIOUSLY_MOUNTED_THEN_REMOVED=RECOVERY_BOUNDARY_REQUIRES_SEPARATE_INVESTIGATION' \
'IF_NEVER_AUTHORIZED_FOR_MOUNTING=MISSION_CONTROL_PHASE_BLOCKED_BY_GOVERNANCE_RUNTIME_DEPENDENCY' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
