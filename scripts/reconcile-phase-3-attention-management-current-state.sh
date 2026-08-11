#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE PHASE 3 ATTENTION MANAGEMENT CURRENT STATE ==="

REQUIRED_ANCESTOR="c0934a3b"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 2 closure checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INVESTIGATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-phase-3-attention-management-current-state\.sh$|^ M scripts/reconcile-phase-3-attention-management-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 2 CLOSURE ==="
grep -nE \
  'PHASE_2_INVESTIGATION_LIFECYCLE_COMPLETE|PHASE_2_INVESTIGATION_LIFECYCLE_STATUS=CLOSED|PHASE_2_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE|NEXT_PHASE=PHASE_3_ATTENTION_MANAGEMENT|PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED|NEXT_ACTION=RECONCILE_PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE' \
  scripts/classify-phase-2-investigation-lifecycle-closure.sh

echo
echo "=== INVENTORY ATTENTION-MANAGEMENT TERMINOLOGY ==="
grep -RInE \
  'Attention Management|attention management|attention-management|attentionManagement|attention_management|attention budget|constituent attention|governing attention|governs attention|focus management|attention state' \
  docs scripts server db \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-3-attention-management-current-state.sh' \
  2>/dev/null |
head -n 1800 ||
true

echo
echo "=== INVENTORY EXISTING CONTEXT / SELECTION RESPONSIBILITIES ==="
grep -RInE \
  'selectedHistory|selectedContextSegments|projectContextExcerpts|priorInvestigationLifecycle|unresolved_questions|evidenceSufficient|explanationStatus|history selection|context selection|selection runtime|semantic history' \
  server scripts/utils db \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  2>/dev/null |
head -n 1800 ||
true

echo
echo "=== INVENTORY INVESTIGATION-LIFECYCLE ATTENTION SEMANTICS ==="
grep -RInE -C 4 \
  'governingQuestion|governing investigation|govern.*attention|superseded|abandoned|resolved' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh \
  scripts/classify-phase-2-investigation-lifecycle-closure.sh \
  2>/dev/null ||
true

echo
echo "=== INVENTORY CONVERSATION CONTEXT RUNTIME ==="
sed -n '1,260p' server/matilda-conversation-context-runtime.ts

echo
echo "=== INVENTORY HISTORY SELECTION RUNTIME ==="
cat server/matilda-history-selection-runtime.ts

echo
echo "=== INVENTORY OLLAMA CONTEXT CONTRACT ==="
grep -nE -A100 -B25 \
  'export interface OllamaChatContext|selectedHistory|selectedContextSegments|priorInvestigationLifecycle|projectContextExcerpts' \
  scripts/utils/ollamaChat.ts |
head -n 700

echo
echo "=== SEARCH FOR EXISTING ATTENTION STATE TYPES / TABLES ==="
grep -RInE \
  'AttentionState|AttentionArtifact|AttentionContext|attention_state|attention_json|attention_context|attention_priority|attentionPriority|focus_state|focusState' \
  server scripts db \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  2>/dev/null ||
true

echo
echo "=== SEARCH FOR EXISTING ATTENTION PERSISTENCE ==="
grep -RInE \
  'CREATE TABLE.*attention|ALTER TABLE.*attention|INSERT INTO.*attention|UPDATE.*attention|attention.*TEXT|attention.*JSON' \
  db server scripts \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  2>/dev/null ||
true

echo
echo "=== SEARCH FOR EXISTING ATTENTION-SPECIFIC TESTS / GUARDS ==="
find scripts server db -type f \
  \( -iname '*attention*' -o -iname '*focus*' \) \
  -print |
sort

echo
echo "=== FALSIFICATION — POSSIBLE EXISTING PHASE 3 CAPABILITY ==="
grep -RInE \
  'attention.*(implemented|runtime|artifact|state|selection|priority|prioritization)|focus.*(implemented|runtime|artifact|state|selection|priority)' \
  docs scripts server db \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-3-attention-management-current-state.sh' \
  2>/dev/null |
head -n 1800 ||
true

cat <<'FINDINGS'

Phase 3 — Attention Management current-state reconciliation:

Starting state:

PHASE_1_RESPONSE_COMPOSITION=CLOSED
PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED
PHASE_3_ATTENTION_MANAGEMENT=ACTIVE_INVESTIGATION
PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_AUTHORIZED

This unit is repository reconciliation only.

The purpose is to determine what Attention Management already means in the
repository before defining any new runtime capability.

Required distinctions:

1. Existing conversation-history selection is not automatically Attention
   Management.

2. Existing project-context selection is not automatically Attention
   Management.

3. Adaptive Detail Selection is a completed Response Composition responsibility
   and must not be reopened merely because it affects what context reaches
   generation.

4. Investigation Lifecycle already establishes a governing investigation and
   governingQuestion, but that does not by itself establish a distinct Attention
   Management runtime.

5. Investigation Lifecycle superseded / abandoned semantics may affect what
   should cease governing attention, but Phase 3 must not duplicate lifecycle
   semantic authorship.

6. selectedHistory remains conversation-history selection unless repository
   evidence establishes an additional governed responsibility.

7. selectedContextSegments remains an established context-selection capability
   unless repository evidence establishes an additional governed responsibility.

8. priorInvestigationLifecycle remains a dedicated Investigation Lifecycle
   semantic-context channel.

9. Conversation Context Runtime must not be expanded merely because it is an
   available aggregation surface.

Questions for current-state classification:

A. Does a dedicated Attention Management semantic artifact already exist?

B. Does a dedicated Attention Management runtime already exist?

C. Does dedicated Attention Management persistence already exist?

D. Does the repository already define what object or question receives
   attention?

E. Does the repository distinguish active attention from deferred work?

F. Does Investigation Lifecycle provide sufficient semantic authority for
   identifying the governing investigation while leaving attention allocation
   as a separate responsibility?

G. Is attention management primarily semantic prioritization authored by
   Matilda, deterministic selection of already-authored priorities,
   context-budget allocation, suppression of deferred or superseded concerns,
   another responsibility, or a combination requiring further decomposition?

H. Which existing runtime capabilities are architectural inputs to Attention
   Management rather than Attention Management itself?

I. Which authority boundary owns attention decisions?

J. What repository evidence would falsify the hypothesis that Phase 3 requires
   a new capability?

K. What is the smallest next investigation that materially reduces uncertainty?

Do not implement.

Do not define a new Attention Management schema.

Do not add persistence.

Do not change prompts.

Do not change selectedHistory.

Do not change selectedContextSegments.

Do not change Conversation Context Runtime.

Do not change Investigation Lifecycle.

Do not reopen Phase 1.

Do not reopen Phase 2.

Do not infer Phase 3 semantics from the phrase "Attention Management" alone.

Do not create a Phase 3 implementation plan until the current capability and
responsibility boundary is classified.

Preserve:

Matilda
= semantic Interpretation Authority

Investigation Lifecycle
= semantic continuity of governing investigations

Response Composition
= closed Phase 1 responsibility

Runtime
= only deterministic responsibilities explicitly established by evidence

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE_RECONCILED"
echo "PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts
then
  echo "STOP: production runtime changed during Phase 3 current-state reconciliation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-phase-3-attention-management-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 3 investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reconcile-phase-3-attention-management-current-state.sh
git diff --cached --check
git commit -m "Reconcile Phase 3 Attention Management current state"
git push
