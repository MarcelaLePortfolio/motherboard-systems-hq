#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="$(git rev-parse --short=9 HEAD)"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== LIFECYCLE PRODUCTION ENTRY POINT ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B30 -A140 \
  'consumeProductionLifecycleEntryPoint|ProductionLifecycleConsumer|production-lifecycle' \
  server db routes 2>/dev/null || true

printf '\n=== LIFECYCLE ROUTE ===\n'
sed -n '1,430p' server/routes/governance-lifecycle-route.ts 2>/dev/null || true

printf '\n=== ENVELOPE CREATION / GATE ROUTES ===\n'
for file in \
  server/routes/governance-envelope-gate-route.ts \
  server/routes/governance-envelope-route.ts
do
  if test -f "$file"; then
    printf '\n--- %s ---\n' "$file"
    sed -n '1,340p' "$file"
  fi
done

printf '\n=== PRODUCTION LIFECYCLE CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  -B15 -A50 \
  'governance/lifecycle|handleGovernanceLifecycleRouteRequest|consumeProductionLifecycleEntryPoint|completeGovernanceLifecycleAssignmentTransition' \
  server db routes client/src 2>/dev/null || true

printf '\n=== SERVER ROUTE MOUNTING ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A40 \
  'governanceLifecycle|governance-lifecycle|lifecycleRouter|/api/governance/lifecycle' \
  server routes 2>/dev/null || true

printf '\n=== CREATED ENVELOPE HANDOFF SEARCH ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A80 \
  'ENVELOPE_CREATED|effect_intent|department_handshake|lifecycle_transition_authorized' \
  server db routes 2>/dev/null || true

printf '\n=== LIVE ENVELOPE ===\n'
sqlite3 -header -column db/main.db <<'SQL'
SELECT
  envelope_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  lifecycle_state
FROM governance_envelopes
ORDER BY rowid DESC
LIMIT 5;
SQL

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=LIFECYCLE_IMPLEMENTATION_EXISTS'
echo 'KNOWN=DELEGATION_DOES_NOT_CREATE_LIFECYCLE_AUTHORITY'
echo 'QUESTION=WHAT_PRODUCTION_COMPONENT_HANDS_CREATED_ENVELOPE_TO_EXISTING_LIFECYCLE_PATH'
echo 'TARGET=EXACT_PRODUCTION_HANDOFF'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'COMMIT_PERFORMED=NO'
echo 'PUSH_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
