#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY HYBRID CONTEXT REQUIREMENT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="91ed9a5b"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 2 disposition checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-hybrid-context-requirement\.sh$|^ M scripts/classify-hybrid-context-requirement\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_2_DISPOSITION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE TRANSITION ==="

grep -nE \
  'PHASE_2_STATUS=|COMPLETE|NEXT_PHASE=|HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION|NEXT_CORRIDOR=|HYBRID_CONTEXT_REQUIREMENT|NEXT_ACTION=|CLASSIFY_HYBRID_CONTEXT_REQUIREMENT' \
  scripts/classify-phase-2-context-budget-and-window-optimization-disposition.sh

echo "GOVERNING_PHASE_TRANSITION=CONFIRMED"

echo
echo "=== VERIFY CURRENT DISTINCT CONTEXT CHANNELS ==="

grep -RniE \
  'selectedHistory|projectContextExcerpts|projectContextWarning|priorInvestigationLifecycle|selectedContextSegments|ConversationContextRuntime|OllamaChatContext' \
  server \
  docs/architecture/SEMANTIC_HISTORY_*.md \
  scripts \
  --include='*.ts' \
  --include='*.md' \
  --include='*.sh' \
  2>/dev/null | head -360 || true

echo
echo "=== SEARCH FOR EXISTING HYBRID COORDINATION OR CONVERGENCE ==="

grep -RniE \
  'hybrid context|hybrid-context|combined context ranking|cross-context ranking|cross context priority|conversation history.*project context|project context.*conversation history|selectedHistory.*projectContextExcerpts|projectContextExcerpts.*selectedHistory|context convergence' \
  server \
  docs \
  scripts \
  --exclude='classify-hybrid-context-requirement.sh' \
  2>/dev/null | head -300 || true

echo
echo "=== SEARCH FOR CONCRETE FAILURE REQUIRING HYBRID COORDINATION ==="

grep -RniE \
  'conversation history.*conflict.*project context|project context.*conflict.*conversation history|history.*crowd.*project context|project context.*crowd.*history|cross-context.*failure|hybrid.*failure|context competition|context collision|priority conflict|relevant project context.*omitted|relevant history.*omitted.*project context' \
  server \
  docs \
  scripts \
  --exclude='classify-hybrid-context-requirement.sh' \
  2>/dev/null | head -300 || true

echo
echo "=== HYBRID CONTEXT REQUIREMENT CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION

CORRIDOR=
  HYBRID_CONTEXT_REQUIREMENT

CURRENT_CONVERSATION_HISTORY_CHANNEL=
  selectedHistory

CURRENT_PROJECT_CONTEXT_CHANNEL=
  projectContextExcerpts

CURRENT_INVESTIGATION_LIFECYCLE_CHANNEL=
  priorInvestigationLifecycle

CURRENT_CONTEXT_CHANNEL_RELATIONSHIP=
  DISTINCT_TYPED_INPUTS_TO_SEMANTIC_GENERATION

CURRENT_HYBRID_RANKING_OR_CROSS_CONTEXT_PRIORITY=
  NOT_ESTABLISHED

CURRENT_CONTEXT_CONVERGENCE=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_CONVERSATION_HISTORY_AND_PROJECT_CONTEXT_MUST_BE_COORDINATED=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_OF_CONCRETE_CROSS_CONTEXT_FAILURE=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_CURRENT_DISTINCT_CHANNELS_ARE_OPTIMAL=
  NOT_ESTABLISHED

HYBRID_CONTEXT_REQUIREMENT=
  NOT_ESTABLISHED

CLASSIFICATION=
  PRESERVE_DISTINCT_CONTEXT_CHANNELS_UNLESS_CONTRADICTORY_BEHAVIORAL_OR_ARCHITECTURAL_EVIDENCE_REQUIRES_COORDINATION

RATIONALE=
  Conversation history and project context currently enter semantic generation
  through distinct typed channels with different provenance and authority
  semantics.

  Prior Investigation Lifecycle context is also transported through its own
  distinct typed channel.

  Repository evidence does not establish an existing cross-context ranking,
  convergence, or shared priority mechanism.

  The absence of such a mechanism does not itself establish that one is
  required.

  Repository evidence also does not currently establish a concrete behavioral
  failure caused by keeping conversation history, project context, and prior
  lifecycle context distinct.

  Therefore no hybrid coordination mechanism should be introduced
  speculatively.

FALSIFICATION_CONDITION=
  Reopen the hybrid-context requirement if repository-supported evidence
  demonstrates that distinct context channels produce systematic semantic
  conflict, omission, crowding, authority confusion, or ordering failure that
  cannot be resolved within their existing independent boundaries.

HYBRID_CONTEXT_IMPLEMENTATION=
  NOT_AUTHORIZED

HISTORY_AND_PROJECT_CONTEXT_RELATIONSHIP_CLASSIFICATION_REQUIRED=
  NO_WHILE_HYBRID_REQUIREMENT_REMAINS_UNESTABLISHED

CROSS_CONTEXT_PRIORITY_CLASSIFICATION_REQUIRED=
  NO_WHILE_HYBRID_REQUIREMENT_REMAINS_UNESTABLISHED

CONVERSATION_HISTORY_CHANNEL=
  PRESERVE

PROJECT_CONTEXT_CHANNEL=
  PRESERVE

PRIOR_INVESTIGATION_LIFECYCLE_CHANNEL=
  PRESERVE

AUTHORITY_BOUNDARIES=
  PRESERVE

PROVENANCE_BOUNDARIES=
  PRESERVE

SELECTED_HISTORY=
  PRESERVE

PROJECT_CONTEXT_RETRIEVAL=
  PRESERVE_AS_DISTINCT_SUBSYSTEM

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

HYBRID_CONTEXT_REQUIREMENT_CORRIDOR=
  COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED

NEXT_CORRIDOR=
  MODEL_RUNTIME_CONTEXT_BOUNDARY

NEXT_ACTION=
  CLASSIFY_MODEL_RUNTIME_CONTEXT_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-hybrid-context-requirement\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside hybrid-context requirement scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
