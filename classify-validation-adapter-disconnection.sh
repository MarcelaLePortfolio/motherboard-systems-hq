#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n=== ESTABLISHED EVIDENCE ===\n'
echo "HISTORICAL_MATILDA_ROUTE_FILE=PRESENT"
echo "HISTORICAL_MATILDA_RUNTIME_FILE=PRESENT"
echo "HISTORICAL_ROUTE_DELETED=NO"
echo "HISTORICAL_RUNTIME_DELETED=NO"
echo "HISTORICAL_ACTOR=operator"
echo "HISTORICAL_DOWNSTREAM_AUTHORITY=NONE"
echo "CURRENT_PRODUCTION_ROUTE=/api/governance/validation"
echo "CURRENT_PRODUCTION_ROUTE_MOUNTED=YES"
echo "CURRENT_ACTIVE_MATILDA_ROUTE_MOUNTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== ACTIVE SERVER VALIDATION MOUNTS ===\n'
grep -n -C 4 -E \
  'GovernanceValidation|governance-validation|matildaGovernanceValidation|matilda-governance-validation' \
  server/index.ts || true

printf '\n=== LEGACY ROUTE REFERENCES OUTSIDE ITS OWN FILE ===\n'
grep -RniE \
  'matildaGovernanceValidationRouter|matilda-governance-validation-route' \
  server \
  --exclude='matilda-governance-validation-route.ts' \
  2>/dev/null || true

printf '\n=== CURRENT CLIENT VALIDATION ACTION ===\n'
grep -RniE \
  '/api/governance/validation|/api/matilda/governance-validation|validation_actor|governance.?validation|validate.*governance' \
  client/src \
  2>/dev/null || true

printf '\n=== ACTIVE ENTRY-POINT HISTORY ===\n'
git log --all --date=iso --format='%H %ad %s' -- server/index.ts | head -80

printf '\n=== ENTRY-POINT TRANSITION EVIDENCE ===\n'
git log --all -p -- server/index.ts server.mjs package.json 2>/dev/null | \
grep -n -C 8 -E \
  'server/index|server\.mjs|dist/server/index|matildaGovernanceValidationRouter|createGovernanceValidationRouter' \
  | head -700 || true

printf '\n=== PRODUCTION VALIDATION AUTHORITY CONTRACT ===\n'
grep -n -C 6 -E \
  'delegation_id|validation_status|downstream_governance_authorized|new_authority_introduced|authorized|operator' \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-entry-point.ts \
  server/validation/production-validation-consumer.ts \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo "LEGACY_OPERATOR_ADAPTER=DISCONNECTED_NOT_DELETED"
echo "NEXT_QUESTION=IS_THE_ONLY_MISSING_SEAM_AN_EXPLICIT_OPERATOR_TRIGGER_ON_THE_EXISTING_PRODUCTION_ROUTE"
echo "RESTORE_LEGACY_DATABASE_RUNTIME=NOT_JUSTIFIED_BY_CURRENT_EVIDENCE"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\n=== WORKTREE ===\n'
git status --short
