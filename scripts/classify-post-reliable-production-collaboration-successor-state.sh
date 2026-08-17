#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY POST-RELIABLE-PRODUCTION-COLLABORATION SUCCESSOR STATE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 9162f5fc HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-post-reliable-production-collaboration-successor-state\.sh$|^ M scripts/classify-post-reliable-production-collaboration-successor-state\.sh$' ||
  true
)"
test -z "$unexpected"

closure="scripts/close-production-reliability-validation-and-reliable-production-collaboration-milestone.sh"
test -f "$closure"

grep -q 'MILESTONE_STATUS=' "$closure"
grep -q '^CLOSED$' \
  <(awk '/MILESTONE_STATUS=/{getline; print}' "$closure")

grep -q 'NEXT_ACTION=' "$closure"
grep -q '^CLASSIFY_NEXT_CANONICAL_MILESTONE_FROM_REPOSITORY_EVIDENCE$' \
  <(awk '/NEXT_ACTION=/{getline; print}' "$closure")

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

JUST_CLOSED_MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

JUST_CLOSED_MILESTONE_STATUS=
CLOSED

PRIOR_PROGRAM_RECONCILIATION_SUCCESSOR_RULE=
REQUIRE_NEW_EVIDENCE_OR_EXPLICIT_NEW_PROGRAM_OBJECTIVE_BEFORE_OPENING_ANOTHER_RUNTIME_MILESTONE

POST_RELIABILITY_EXPLICIT_SUCCESSOR_EVIDENCE=
NONE_FOUND_ON_CURRENT_REPOSITORY_SURFACE

ATTENTION_MANAGEMENT_PROMOTED_AS_SUCCESSOR=
NO

COLLABORATION_GOVERNANCE_PROMOTED_AS_SUCCESSOR=
NO

NEW_RUNTIME_CAPABILITY_REQUIREMENT=
NONE_ESTABLISHED

NEXT_CANONICAL_RUNTIME_MILESTONE=
NONE_ESTABLISHED

NEXT_PROGRAM_STATE=
NO_ACTIVE_RUNTIME_SUCCESSOR_MILESTONE_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

IMPLEMENTATION_STARTED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
AWAIT_NEW_EVIDENCE_OR_EXPLICIT_PROGRAM_OBJECTIVE
MAP
