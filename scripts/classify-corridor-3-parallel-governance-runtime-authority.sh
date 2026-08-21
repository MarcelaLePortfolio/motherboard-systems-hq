#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 3 · AUTHORITATIVE PACKAGE LINEAGE RECONCILIATION\n'
printf 'STATUS: 🟢 ACTIVE\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=AUTHORITATIVE_PACKAGE_LINEAGE_RECONCILIATION' \
'DR_CHECKPOINT=20260820_170737' \
'CURRENT_FINDING=PARALLEL_GOVERNANCE_LIFECYCLE_FAMILIES_PRESENT' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== SERVER ROUTE MOUNTING ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist \
-E 'matilda-delegation-route|matilda-governance-validation-route|matilda-envelope-route|matilda-routing-route|matilda-assignment-route|governance-package-route|governance-delegation-route|governance-validation-route|governance-envelope-gate-route|governance-envelope-route' \
server/index.ts server routes 2>/dev/null | head -360 || true

printf '\n=== DATABASE PATH OWNERSHIP ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist \
-E 'motherboard\.sqlite|db/main\.db' db server routes 2>/dev/null | head -320 || true

printf '\n=== MATILDA PARALLEL RUNTIME CALLERS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist \
-E 'createDelegation\(|validateGovernance\(|createEnvelope\(|matilda_delegations|matilda_governance_validations|matilda_envelopes|matilda_routing|matilda_assignments' \
db server routes client/src 2>/dev/null | head -360 || true

printf '\n=== GOVERNANCE RUNTIME CALLERS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist \
-E 'createGovernancePackage\(|createGovernanceDelegation\(|createGovernanceValidationResult\(|createGovernanceEnvelopeGate\(|createGovernanceEnvelope\(' \
db server routes client/src 2>/dev/null | head -360 || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
printf '%s\n' \
'Q1=Are motherboard.sqlite Matilda governance routes mounted in the active server?' \
'Q2=Are Matilda governance runtimes reachable production surfaces or historical parallel implementations?' \
'Q3=Is db/main.db governance runtime the authoritative downstream lifecycle family?' \
'Q4=Does reconciliation require Package-root repair only or broader parallel-lifecycle reconciliation?' \
'Q5=Can reconciliation preserve existing semantic authority?'

printf '\nIMPLEMENTATION_AUTHORIZED=NO\n'
printf 'PRODUCTION_CHANGE=NONE\n'
