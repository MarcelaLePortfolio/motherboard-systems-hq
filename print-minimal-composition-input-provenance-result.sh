#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e69c00276"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== INPUT PROVENANCE RESULT ===\n'

FOUND_FULL=0
FOUND_PARTIAL=0

for f in $(find server db routes \
  -type f \( -name '*.ts' -o -name '*.mjs' \) \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u); do

  HAS_HANDSHAKE=0
  HAS_DEPARTMENTS=0
  HAS_PERSISTENCE=0

  grep -qE \
    'ACKNOWLEDGED|CAPABILITY_CONFIRMED|DepartmentAssignmentHandshake|department_handshake' \
    "$f" && HAS_HANDSHAKE=1 || true

  grep -qE \
    'available_departments|availableDepartments' \
    "$f" && HAS_DEPARTMENTS=1 || true

  grep -qE \
    'persistGovernanceEnvelopeLifecycleTransition|persist_lifecycle_transition|createDefaultLifecyclePersistence' \
    "$f" && HAS_PERSISTENCE=1 || true

  if [ "$HAS_HANDSHAKE" -eq 1 ] && [ "$HAS_DEPARTMENTS" -eq 1 ]; then
    FOUND_PARTIAL=1
    echo "HANDSHAKE_AND_DEPARTMENTS=$f"
  fi

  if [ "$HAS_HANDSHAKE" -eq 1 ] &&
     [ "$HAS_DEPARTMENTS" -eq 1 ] &&
     [ "$HAS_PERSISTENCE" -eq 1 ]; then
    FOUND_FULL=1
    echo "FULL_EXISTING_INPUT_OWNER=$f"

    grep -nE \
      'ACKNOWLEDGED|CAPABILITY_CONFIRMED|DepartmentAssignmentHandshake|department_handshake|available_departments|availableDepartments|persistGovernanceEnvelopeLifecycleTransition|persist_lifecycle_transition|createDefaultLifecyclePersistence' \
      "$f" || true
  fi
done

printf '\n=== CLASSIFICATION ===\n'

if [ "$FOUND_FULL" -eq 1 ]; then
  echo 'FULL_EXISTING_INPUT_OWNER=FOUND'
  echo 'NEXT_STEP=VERIFY_OWNER_IS_LIVE_PRODUCTION_PROVENANCE'
elif [ "$FOUND_PARTIAL" -eq 1 ]; then
  echo 'FULL_EXISTING_INPUT_OWNER=ABSENT'
  echo 'PARTIAL_EXISTING_INPUT_OWNER=FOUND'
  echo 'NEXT_STEP=TRACE_MISSING_PERSISTENCE_ORIGIN_WITHOUT_SYNTHESIZING_INPUTS'
else
  echo 'FULL_EXISTING_INPUT_OWNER=ABSENT'
  echo 'PARTIAL_EXISTING_INPUT_OWNER=ABSENT'
  echo 'NEXT_STEP=STOP_AND_REASSESS_INPUT_PROVENANCE_BEFORE_IMPLEMENTATION'
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
