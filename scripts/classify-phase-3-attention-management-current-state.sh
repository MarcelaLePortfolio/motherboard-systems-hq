#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 3 ATTENTION MANAGEMENT CURRENT STATE ==="

REQUIRED_ANCESTOR="0bc3f80d"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 reconciliation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-attention-management-current-state\.sh$|^ M scripts/classify-phase-3-attention-management-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING RECONCILIATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE_RECONCILED|PHASE_3_ATTENTION_MANAGEMENT_IMPLEMENTATION=NOT_STARTED|PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED|NEXT_ACTION=CLASSIFY_PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE' \
  scripts/reconcile-phase-3-attention-management-current-state.sh

echo
echo "=== VERIFY CONVERSATION CONTEXT RESPONSIBILITIES ==="
sed -n '1,180p' server/matilda-conversation-context-runtime.ts

echo
echo "=== VERIFY HISTORY SELECTION RESPONSIBILITY ==="
cat server/matilda-history-selection-runtime.ts

echo
echo "=== VERIFY EXISTING OLLAMA CONTEXT CHANNELS ==="
grep -nE -C 4 \
  'selectedContextSegments|priorInvestigationLifecycle|projectContextExcerpts|projectContextSegmentCandidates|history' \
  scripts/utils/ollamaChat.ts |
head -n 420

echo
echo "=== VERIFY NO DEDICATED ATTENTION ARTIFACT OR PERSISTENCE ==="
attention_runtime_refs="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='reconcile-phase-3-attention-management-current-state.sh' \
    --exclude='classify-phase-3-attention-management-current-state.sh' \
    'MatildaAttention(State|Artifact|Context)|matilda_attention|attention_state|attention_json|attention_context|attention_priority|attentionPriority' \
    server db scripts/utils 2>/dev/null ||
  true
)"

if [[ -n "$attention_runtime_refs" ]]; then
  echo "STOP: possible dedicated Attention Management runtime evidence exists and requires reclassification:"
  printf '%s\n' "$attention_runtime_refs"
  exit 2
fi

echo "DEDICATED_ATTENTION_RUNTIME_OR_PERSISTENCE_ABSENT"

cat <<'FINDINGS'

Phase 3 — Attention Management current-state classification:

1. No dedicated Matilda Attention Management semantic artifact is established
   by current repository evidence.

2. No dedicated Matilda Attention Management runtime is established by current
   repository evidence.

3. No dedicated Matilda Attention Management persistence is established by
   current repository evidence.

4. Existing selectedHistory is an architectural input to Phase 3, not itself
   sufficient evidence of an Attention Management responsibility.

5. Existing selectedContextSegments is an architectural input to Phase 3, not
   itself sufficient evidence of an Attention Management responsibility.

6. Adaptive Detail Selection remains a closed Phase 1 Response Composition
   responsibility and is not reopened.

7. Investigation Lifecycle remains a closed Phase 2 responsibility.

8. Investigation Lifecycle provides durable semantic identity for the governing
   investigation and governingQuestion, including Matilda-authored lifecycle
   events that can establish continuation, advancement, resolution,
   supersession, or abandonment.

9. Those lifecycle facts can inform Attention Management, but Phase 3 must not
   duplicate or replace Investigation Lifecycle semantic authorship.

10. Conversation Context Runtime is an aggregation/composition surface and is
    not automatically the owner of Attention Management.

11. Current repository evidence therefore does not support implementation of a
    new Attention Management artifact, persistence layer, prompt contract, or
    deterministic selection rule yet.

12. The unresolved architectural question is the responsibility boundary:
    what Attention Management must decide beyond already-established history
    selection, project-context selection, response-detail selection, and
    Investigation Lifecycle continuity.

13. Phase 3 therefore requires a narrower responsibility-boundary
    investigation before representation or implementation readiness can be
    classified.

14. That investigation must distinguish at minimum:

    - semantic prioritization authored by Matilda;
    - deterministic use of already-authored priority facts;
    - allocation of bounded generation attention/context;
    - suppression or deprioritization of deferred concerns;
    - interaction with resolved, superseded, or abandoned investigations;
    - and responsibilities already owned by Phases 1 and 2.

15. No implementation is authorized by this classification.

16. Phase 1 Response Composition remains closed.

17. Phase 2 Investigation Lifecycle remains closed.

Smallest next unit:

INVESTIGATE_PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY

Determine from repository evidence:

1. What exact problem remains unsolved after Response Composition and
   Investigation Lifecycle are both closed.

2. What semantic object, question, investigation, concern, or work item can
   legitimately receive or lose attention.

3. Whether attention priority is itself a Matilda-authored semantic fact.

4. Whether runtime requires any deterministic attention-selection
   responsibility after Matilda authors semantic priority.

5. How active attention differs from deferred work without duplicating
   Investigation Lifecycle.

6. Whether resolved, superseded, or abandoned lifecycle state is sufficient to
   suppress prior concerns, or whether a separate attention determination is
   required.

7. Whether multiple simultaneous candidate concerns are required before a
   distinct Attention Management capability has architectural meaning.

8. Which existing context-selection mechanisms are inputs rather than owners.

9. What authority boundary preserves Matilda as semantic Interpretation
   Authority.

10. What evidence would falsify the need for a new Phase 3 runtime capability.

11. The smallest candidate semantic contract, if any, that should be
    investigated next.

Do not implement.

Do not define an Attention Management schema.

Do not add persistence.

Do not change prompts.

Do not change selectedHistory.

Do not change selectedContextSegments.

Do not change Conversation Context Runtime.

Do not change Investigation Lifecycle.

Do not infer a priority model from existing ordering alone.

Do not reopen Phase 1.

Do not reopen Phase 2.

Preserve:

Matilda
= semantic Interpretation Authority

Investigation Lifecycle
= closed semantic continuity responsibility

Response Composition
= closed response-composition responsibility

Runtime
= deterministic enforcement only where explicit invariants are established

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_CURRENT_STATE_CLASSIFIED"
echo "DEDICATED_ATTENTION_SEMANTIC_ARTIFACT=ABSENT"
echo "DEDICATED_ATTENTION_RUNTIME=ABSENT"
echo "DEDICATED_ATTENTION_PERSISTENCE=ABSENT"
echo "SELECTED_HISTORY_ROLE=ARCHITECTURAL_INPUT_NOT_PHASE_3_OWNER"
echo "SELECTED_CONTEXT_SEGMENTS_ROLE=ARCHITECTURAL_INPUT_NOT_PHASE_3_OWNER"
echo "INVESTIGATION_LIFECYCLE_ROLE=GOVERNING_INVESTIGATION_SEMANTIC_INPUT"
echo "ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY=UNRESOLVED"
echo "PHASE_3_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_UNIT=INVESTIGATE_PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY"

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
  echo "STOP: production runtime changed during Phase 3 current-state classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-attention-management-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 3 classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-3-attention-management-current-state.sh
git diff --cached --check
git commit -m "Classify Phase 3 Attention Management current state"
git push
