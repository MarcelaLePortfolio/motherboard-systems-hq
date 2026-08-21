#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 4 · DOWNSTREAM OPERATIONAL STATE BOUNDARY\n'
printf 'STATUS: 🟢 ACTIVE · GOVERNANCE RUNTIME ACTIVATION BOUNDARY\n'
printf '============================================================\n\n'

printf '%s\n' \
'MILESTONE=EXECUTIVE_MISSION_CONTROL' \
'PHASE=PROJECT_SCOPED_MISSION_CONTROL_AND_ACTIVE_MISSION_BINDING' \
'CORRIDOR=DOWNSTREAM_OPERATIONAL_STATE_BOUNDARY' \
'PRIOR_CLASSIFICATION_COMMIT=d2728a99' \
'OBSERVED=DOWNSTREAM_LIFECYCLE_PRIMITIVES_IMPLEMENTED_AND_VALIDATED' \
'OBSERVED=CURRENT_SERVER_DOES_NOT_MOUNT_DOWNSTREAM_GOVERNANCE' \
'UNRESOLVED=INTENTIONAL_DEFERRAL_VS_RECOVERY_STATE' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== AUTHORITATIVE DOWNSTREAM VALIDATION DOCUMENTS ===\n'
for file in \
  docs/governance/MATILDA_PACKAGE_DELEGATION_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_GOVERNANCE_VALIDATION_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_ENVELOPE_CREATION_VALIDATED_2026-07-05.md \
  docs/production-runtime-integration-planning.md \
  docs/governance-runtime-integration-readiness-scope-map.md \
  docs/production-lifecycle-surface-contract.md \
  docs/production-lifecycle-entry-point-validation-blocker.md \
  docs/production-lifecycle-entry-point-implementation-reset.md \
  docs/native-database-validation-strategy-finding.md
do
  if [[ -f "$file" ]]; then
    printf '\n--- %s ---\n' "$file"
    cat "$file"
  fi
done

printf '\n=== DOWNSTREAM IMPLEMENTATION HISTORY ===\n'
git log --all --oneline --decorate \
  --grep='delegation runtime\|governance validation runtime\|envelope runtime\|production lifecycle\|governance runtime integration' \
  -180

printf '\n=== PRIOR MOUNT / REMOVE / RESTORE EVIDENCE ===\n'
git log --all -p -- server/index.ts \
  | grep -Ei -C 8 'governance|delegation|validation|envelope|revert|remove|restore' \
  | head -600 || true

printf '\n=== PRODUCTION ACTIVATION DISPOSITION ===\n'
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'production caller|production integration|production runtime|future canonical envelope creation path|not authorized|deferred|blocked|out of scope|revert|three failed' \
  docs/production-runtime-integration-planning.md \
  docs/governance-runtime-integration-readiness-scope-map.md \
  docs/production-lifecycle-surface-contract.md \
  docs/production-lifecycle-entry-point-validation-blocker.md \
  docs/production-lifecycle-entry-point-implementation-reset.md \
  docs/native-database-validation-strategy-finding.md \
  docs/governance 2>/dev/null | head -700 || true

printf '\n=== CORRIDOR 4 DECISION GATE ===\n'
printf '%s\n' \
'QUESTION_1=Were downstream primitives validated independently without production mounting?' \
'QUESTION_2=Did a downstream governance production mount ever exist?' \
'QUESTION_3=Is production activation explicitly future, deferred, or blocked work?' \
'QUESTION_4=Was an attempted production activation reverted under failure-containment rules?' \
'IF_VALIDATED_PLUS_NEVER_MOUNTED_PLUS_DEFERRED=INTENTIONAL_UPSTREAM_RUNTIME_ACTIVATION_DEPENDENCY' \
'IF_PRIOR_MOUNT_FOUND=RECOVERY_BOUNDARY_REQUIRES_SEPARATE_INVESTIGATION' \
'IF_AMBIGUOUS=STOP_WITHOUT_IMPLEMENTATION' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
