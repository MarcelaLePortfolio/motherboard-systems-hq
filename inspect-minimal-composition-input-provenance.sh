#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="8274529cf"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== DEPARTMENT HANDSHAKE PRODUCERS ===\n'
grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'ACKNOWLEDGED|CAPABILITY_CONFIRMED|DepartmentAssignmentHandshake|department_handshake' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u || true

printf '\n=== AVAILABLE DEPARTMENT PRODUCERS ===\n'
grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'available_departments|availableDepartments' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u || true

printf '\n=== LIFECYCLE PERSISTENCE PRODUCERS ===\n'
grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'persistGovernanceEnvelopeLifecycleTransition|persist_lifecycle_transition|createDefaultLifecyclePersistence' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u || true

printf '\n=== POSSIBLE INPUT-PROVENANCE INTERSECTIONS ===\n'
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
    echo "HANDSHAKE_AND_DEPARTMENTS=$f"
  fi

  if [ "$HAS_HANDSHAKE" -eq 1 ] &&
     [ "$HAS_DEPARTMENTS" -eq 1 ] &&
     [ "$HAS_PERSISTENCE" -eq 1 ]; then
    echo "FULL_EXISTING_INPUT_OWNER=$f"
  fi
done

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=EXISTING_SHARED_ENVELOPE_LIFECYCLE_CALLER_ABSENT'
echo 'KNOWN=NEW_MINIMAL_COMPOSITION_SURFACE_REQUIRED'
echo 'QUESTION=WHETHER_EXISTING_RUNTIME_ALREADY_PRODUCES_ALL_REQUIRED_LIFECYCLE_INPUTS'
echo 'NEW_SURFACE_MAY_ONLY_ACCEPT_EXISTING_INPUTS=YES'
echo 'NEW_SURFACE_MAY_SYNTHESIZE_HANDSHAKE=NO'
echo 'NEW_SURFACE_MAY_SYNTHESIZE_DEPARTMENTS=NO'
echo 'NEW_SURFACE_MAY_CREATE_AUTHORITY=NO'
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
