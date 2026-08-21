#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 4 · DOWNSTREAM OPERATIONAL STATE BOUNDARY\n'
printf 'STATUS: 🟢 NOW ACTIVE · CLASSIFICATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR_1=AUTHORITATIVE_ACTIVE_MISSION_SELECTION:CLOSED_DR_PROTECTED' \
'CORRIDOR_2=CANONICAL_TO_GOVERNANCE_PACKAGE_TRANSITION:CLOSED_DR_PROTECTED' \
'CORRIDOR_3=AUTHORITATIVE_PACKAGE_LINEAGE_RECONCILIATION:CLOSED_DR_PROTECTED' \
'CORRIDOR_4_CANDIDATE=DOWNSTREAM_OPERATIONAL_STATE_BOUNDARY' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== PHASE / SUCCESSOR CONTRACTS ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'Project-Scoped Mission Control|active mission|operational mission|Delegation|Governance Validation|Mission Control.*project|Mission Control.*read-only' \
  docs/architecture docs/checkpoints docs/*.md 2>/dev/null | head -420 || true

printf '\n=== LIVE MOUNTED SERVER SURFACE ===\n'
sed -n '1,150p' server/index.ts

printf '\n=== DOWNSTREAM GOVERNANCE ROUTE HISTORY ===\n'
git log --all --oneline --decorate -- \
  server/routes/governance-delegation-route.ts \
  server/routes/governance-validation-route.ts \
  server/routes/governance-envelope-gate-route.ts \
  server/routes/governance-envelope-route.ts \
  server/routes/matilda-delegation-route.ts \
  server/routes/matilda-governance-validation-route.ts \
  server/routes/matilda-envelope-route.ts | head -180

printf '\n=== MOUNT / UNMOUNT / DEFERRED GOVERNANCE EVIDENCE ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'mount.*governance|governance.*mount|unmounted|not mounted|route mounting|Delegation.*mount|Governance Validation.*mount|downstream lifecycle|operationalization.*route' \
  docs scripts server 2>/dev/null | head -420 || true

printf '\n=== CORRIDOR 4 CLASSIFICATION QUESTIONS ===\n'
printf '%s\n' \
'Q1=Is authoritative downstream operational state intentionally deferred, accidentally disconnected, or superseded?' \
'Q2=Does restoring downstream lifecycle authority belong inside this Mission Control phase or in a separate governance/runtime phase?' \
'Q3=Can this Mission Control phase proceed meaningfully without authoritative downstream operational state?' \
'Q4=Should this phase close as BLOCKED_BY_UPSTREAM_GOVERNANCE_DEPENDENCY rather than implement speculative binding?' \
'Q5=What is the smallest evidence-supported next corridor?' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
