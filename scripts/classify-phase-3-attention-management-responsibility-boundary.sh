#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY PHASE 3 ATTENTION MANAGEMENT RESPONSIBILITY BOUNDARY ==="

REQUIRED_ANCESTOR="1528b44a"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 3 responsibility-boundary investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-phase-3-attention-management-responsibility-boundary\.sh$|^ M scripts/classify-phase-3-attention-management-responsibility-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING INVESTIGATION ==="
grep -nE \
  'PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY_INVESTIGATED|IMPLEMENTATION_NOT_STARTED|NEXT_ACTION=CLASSIFY_PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY' \
  scripts/investigate-phase-3-attention-management-responsibility-boundary.sh

echo
echo "=== VERIFY SINGLE-ACTIVE-INVESTIGATION BOUNDARY ==="
grep -nE -C 5 \
  'One active investigation per conversation|Nothing in current evidence requires concurrent active investigations|at most one active investigation per conversation|concurrent investigations' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh \
  scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts.sh

echo
echo "=== VERIFY DURABLE UNRESOLVED-QUESTION REPRESENTATIONS ==="
grep -RInE -C 4 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'unresolved_questions|unresolved questions|Preserve unresolved questions|Preserve uncertainty and unresolved questions' \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_LIVING_DRAFT_PACKAGE_RUNTIME_VALIDATED_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_SCOPE_2026-07-05.md \
  docs/governance/MATILDA_RECONCILED_INTENT_SUMMARY_RUNTIME_VALIDATED_2026-07-05.md \
  2>/dev/null || true

echo
echo "=== VERIFY COLLABORATION EVIDENCE FOR DEFERRED RECONCILIATION ==="
grep -nE -C 7 \
  'deferred reconciliation|Preservation mechanisms were established|observations, hypotheses, candidate findings, open questions, and corridor artifacts' \
  docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md || true

echo
echo "=== VERIFY CURRENT ATTENTION-ADJACENT INPUTS ==="
cat server/matilda-history-selection-runtime.ts
printf '\n--- CURRENT CONVERSATION CONTEXT ---\n'
cat server/matilda-conversation-context-runtime.ts
printf '\n--- PRIOR INVESTIGATION LIFECYCLE CHANNEL ---\n'
grep -nE -C 7 \
  'priorInvestigationLifecycle|Prior Matilda-authored Investigation Lifecycle state' \
  scripts/utils/ollamaChat.ts

cat <<'FINDINGS'

Phase 3 — Attention Management responsibility-boundary classification:

1. The repository does not currently establish multiple simultaneous active
   investigations as a required capability.

2. The Investigation Lifecycle corridor explicitly established at most one
   active investigation per conversation as the safe minimum constraint.

3. Concurrent active investigations were explicitly deferred until a
   contradictory use case requires reopening that assumption.

4. Therefore Phase 3 must not introduce multiple active investigations merely
   to create an object over which an attention-priority mechanism could operate.

5. Existing history selection answers a different question:
   which historical turns are eligible and uncontaminated for semantic
   generation.

6. Existing selectedContextSegments answers a different question:
   which supplied project-context child segments materially affect the
   immediate reply.

7. Existing Adaptive Detail Selection answers a different question:
   how much response detail is appropriate.

8. Existing Investigation Lifecycle answers a different question:
   what investigation currently governs, what question it is investigating,
   and how that investigation semantically transitions.

9. None of those existing mechanisms independently establishes an Attention
   Management responsibility.

10. Repository evidence does establish durable preservation of unresolved
    questions in IEL-derived and Living Draft representations.

11. Collaboration evidence also establishes that preservation mechanisms can
    make deferred reconciliation safe: observations, hypotheses, candidate
    findings, open questions, and corridor artifacts can remain preserved while
    immediate work proceeds elsewhere.

12. That evidence establishes the architectural legitimacy of a distinction
    between:
       a. semantic material that remains valid and preserved; and
       b. semantic material that currently governs the immediate collaboration.

13. However, current repository evidence does not yet establish a production
    semantic contract that explicitly represents this distinction as
    "attention."

14. "Deferred" is therefore not classified as an Investigation Lifecycle event.

15. resolved, superseded, and abandoned must not be repurposed as generic
    temporary deprioritization states.

16. A valid unresolved concern may conceptually remain preserved without
    governing the immediate collaboration, but the current production runtime
    does not yet expose an explicit Matilda-authored attention determination for
    that distinction.

17. This is the smallest residual Phase 3 problem supported by current evidence:

    PRESERVED_VALID_SEMANTIC_MATERIAL
    versus
    CURRENTLY_GOVERNING_SEMANTIC_MATERIAL

18. The residual problem is not ranking raw conversation turns.

19. The residual problem is not ranking project-context excerpts.

20. The residual problem is not response-detail selection.

21. The residual problem is not lifecycle continuity.

22. The residual problem is not concurrent active-investigation management.

23. If a distinct Attention Management capability is ultimately required, its
    semantic authority must remain with Matilda.

24. Runtime must not infer semantic importance from chronology, retrieval rank,
    selectedHistory ordering, evidence ordering, or persistence order.

25. No deterministic runtime responsibility can yet be authorized because no
    minimum Matilda-authored attention fact contract has been established.

26. No new persistence is yet justified because existing durable
    representations already preserve unresolved semantic material; the missing
    question is whether Matilda needs an explicit semantic determination of
    what among preserved valid material currently governs attention.

27. No new structured response field is yet justified.

28. No prompt change is yet justified.

29. No Conversation Context Runtime change is yet justified.

30. No workflow change is yet justified.

31. The next investigation must therefore test whether the residual distinction
    requires a distinct Matilda-authored semantic fact at all.

32. That investigation must begin from the bounded candidate distinction:

       preserved-but-not-currently-governing
       versus
       currently-governing

    without yet naming a schema, vocabulary, persistence representation, or
    runtime implementation.

33. The investigation must determine whether Investigation Lifecycle's existing
    governing investigation plus durable unresolved-question preservation is
    already sufficient to derive this distinction without introducing a new
    semantic artifact.

34. If existing capabilities are sufficient, Phase 3 may close without a new
    runtime capability.

35. If existing capabilities are insufficient, the evidence must identify the
    smallest missing Matilda-authored semantic fact before any implementation
    readiness classification can occur.

36. Phase 3 implementation remains unauthorized.

37. Phase 1 Response Composition remains closed.

38. Phase 2 Investigation Lifecycle remains closed.

Smallest next unit:

INVESTIGATE_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION

Determine from repository evidence:

1. Whether a governing Investigation Lifecycle artifact already provides a
   sufficient positive representation of current attention.

2. Whether preserved unresolved questions already provide a sufficient
   representation of valid non-governing semantic material.

3. Whether combining those existing representations can distinguish
   currently-governing from preserved-but-not-currently-governing material
   without adding a new semantic fact.

4. Whether any semantic ambiguity remains when an unresolved concern is
   preserved but no longer governs the immediate collaboration.

5. Whether that ambiguity creates an actual continuity failure rather than a
   hypothetical capability opportunity.

6. Whether Matilda must explicitly author any additional fact to resolve that
   ambiguity.

7. What evidence would falsify the need for any new Attention Management
   semantic artifact or runtime.

Do not implement.

Do not define an attention schema.

Do not define an attention vocabulary.

Do not add persistence.

Do not change Investigation Lifecycle.

Do not change selectedHistory.

Do not change selectedContextSegments.

Do not change prompts.

Do not change workflow behavior.

Do not change Conversation Context Runtime.

Do not introduce concurrent investigations.

Do not infer priority from chronology or retrieval ordering.

Preserve:

Matilda
= semantic Interpretation Authority

Response Composition
= closed Phase 1 responsibility

Investigation Lifecycle
= closed Phase 2 semantic continuity responsibility

one active investigation per conversation
= current bounded architectural assumption

unresolved semantic material
= already durably preservable

Phase 3 candidate residual responsibility
= distinguish currently governing semantic material from valid preserved
  semantic material only if existing capabilities cannot already do so

Runtime
= deterministic enforcement only after explicit semantic invariants exist

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "PHASE_3_ATTENTION_MANAGEMENT_RESPONSIBILITY_BOUNDARY_CLASSIFIED"
echo "MULTIPLE_ACTIVE_INVESTIGATIONS_REQUIRED=NO"
echo "ONE_ACTIVE_INVESTIGATION_PER_CONVERSATION_ASSUMPTION=PRESERVED"
echo "UNRESOLVED_SEMANTIC_MATERIAL_DURABLY_PRESERVABLE=YES"
echo "RESIDUAL_CANDIDATE_DISTINCTION=PRESERVED_VALID_VS_CURRENTLY_GOVERNING_SEMANTIC_MATERIAL"
echo "NEW_ATTENTION_ARTIFACT_REQUIRED=UNDETERMINED"
echo "NEW_ATTENTION_RUNTIME_REQUIRED=UNDETERMINED"
echo "NEW_ATTENTION_PERSISTENCE_REQUIRED=NOT_ESTABLISHED"
echo "PHASE_3_IMPLEMENTATION=NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED"
echo "NEXT_UNIT=INVESTIGATE_MINIMUM_ATTENTION_SEMANTIC_DISTINCTION"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts
then
  echo "STOP: production runtime changed during Phase 3 responsibility-boundary classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-attention-management-responsibility-boundary\.sh$' ||
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

git add scripts/classify-phase-3-attention-management-responsibility-boundary.sh
git diff --cached --check
git commit -m "Classify Phase 3 Attention Management responsibility boundary"
git push
