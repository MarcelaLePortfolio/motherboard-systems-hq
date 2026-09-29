#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="8d3c296be"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== FILES CALLING ENVELOPE ROUTE/HANDLER ===\n'
grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelopeRouter|consumeProductionEnvelopeEntryPoint' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u || true

printf '\n=== FILES CALLING LIFECYCLE ROUTE/HANDOFF ===\n'
grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'handleGovernanceLifecycleRouteRequest|consumeProductionLifecycleEntryPoint|handoffProductionEnvelopeToLifecycle' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u || true

printf '\n=== FILES CONTAINING BOTH ENVELOPE AND LIFECYCLE CALLS ===\n'
FOUND=0

while IFS= read -r f; do
  test -n "$f" || continue

  if grep -qE \
    'handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelopeRouter|consumeProductionEnvelopeEntryPoint' \
    "$f" &&
     grep -qE \
    'handleGovernanceLifecycleRouteRequest|consumeProductionLifecycleEntryPoint|handoffProductionEnvelopeToLifecycle' \
    "$f"
  then
    FOUND=1
    echo "SHARED_CALLER=$f"
    grep -nE \
      'handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelopeRouter|consumeProductionEnvelopeEntryPoint|handleGovernanceLifecycleRouteRequest|consumeProductionLifecycleEntryPoint|handoffProductionEnvelopeToLifecycle|available_departments|department_handshake|persist_lifecycle_transition' \
      "$f" || true
  fi
done < <(
  find server db routes \
    -type f \( -name '*.ts' -o -name '*.mjs' \) \
    2>/dev/null \
    | grep -vE '\.test\.|\.spec\.' \
    | sort -u
)

printf '\n=== CLASSIFICATION ===\n'
if [ "$FOUND" -eq 1 ]; then
  echo 'EXISTING_LIVE_SHARED_CALLER=FOUND'
  echo 'NEXT_STEP=VERIFY_PRINTED_CALLER_OWNS_EXISTING_LIFECYCLE_INPUTS'
else
  echo 'EXISTING_LIVE_SHARED_CALLER=ABSENT'
  echo 'NEXT_STEP=DEFINE_SMALLEST_NEW_COMPOSITION_SURFACE_WITHOUT_NEW_AUTHORITY'
fi

echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'COMMIT_PERFORMED=NO'
echo 'PUSH_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
