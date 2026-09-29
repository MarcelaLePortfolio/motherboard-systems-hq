#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e90f7e4fe"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== CANDIDATE SHARED SURFACES ===\n'

FOUND=0

while IFS= read -r f; do
  [ -n "$f" ] || continue

  HAS_ENVELOPE=0
  HAS_LIFECYCLE_INPUTS=0

  if grep -qE \
    'createGovernanceEnvelope|consumeProductionEnvelope|ENVELOPE_CREATED' \
    "$f"; then
    HAS_ENVELOPE=1
  fi

  if grep -qE \
    'department_handshake|available_departments|available_actors|consumeProductionLifecycleEntryPoint' \
    "$f"; then
    HAS_LIFECYCLE_INPUTS=1
  fi

  if [ "$HAS_ENVELOPE" -eq 1 ] && [ "$HAS_LIFECYCLE_INPUTS" -eq 1 ]; then
    FOUND=1
    printf '\nSHARED_SURFACE=%s\n' "$f"
    grep -nE \
      'createGovernanceEnvelope|consumeProductionEnvelope|ENVELOPE_CREATED|department_handshake|available_departments|available_actors|consumeProductionLifecycleEntryPoint' \
      "$f" || true
  fi
done < <(
  grep -RlE \
    --include='*.ts' --include='*.mjs' \
    'createGovernanceEnvelope|consumeProductionEnvelope|ENVELOPE_CREATED|department_handshake|available_departments|available_actors|consumeProductionLifecycleEntryPoint' \
    server db routes \
    2>/dev/null \
    | grep -vE '\.test\.|\.spec\.' \
    | sort -u
)

printf '\n=== CLASSIFICATION ===\n'
if [ "$FOUND" -eq 1 ]; then
  echo 'EXISTING_SHARED_PRODUCTION_SURFACE=FOUND'
  echo 'NEXT_STEP=IMPLEMENT_AUTHORIZED_HANDOFF_AT_PRINTED_SURFACE'
else
  echo 'EXISTING_SHARED_PRODUCTION_SURFACE=ABSENT'
  echo 'NEXT_STEP=DEFINE_SMALLEST_NEW_COMPOSITION_SURFACE_BETWEEN_EXISTING_ENVELOPE_AND_LIFECYCLE_COMPONENTS'
fi

echo 'AUTHORIZATION=ACTIVE'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
