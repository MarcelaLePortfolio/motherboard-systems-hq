#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE SEMANTIC FACT REPRESENTATION ==="

REQUIRED_ANCESTOR="6ba6fbe8"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain representation-investigation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-semantic-fact-representation\.sh$|^ M scripts/classify-investigation-lifecycle-semantic-fact-representation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== VERIFY PRIOR REPRESENTATION INVESTIGATION ==="
grep -n \
  'INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION_EVIDENCE_COLLECTED' \
  scripts/investigate-investigation-lifecycle-semantic-fact-representation.sh

echo
echo "=== VERIFY MINIMUM FACT CONTRACT ==="
grep -nE \
  'MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_ADDITIONAL_SEMANTIC_FIELD|MINIMUM_FACTS=investigationIdentity,governingQuestion,lifecycleEvent,lifecycleDetermination' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

cat <<'CLASSIFICATION'

Classification:

INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_ARTIFACT_READY

Repository-supported determination:

1. The existing single structured Ollama response is the established
   Matilda-authored semantic generation seam.

2. The response already carries multiple semantically distinct structured
   outputs through one model invocation.

3. Existing repository evidence therefore does not require another model
   invocation to author Investigation Lifecycle semantics.

4. Investigation Lifecycle should be represented as one bounded semantic
   artifact rather than four unrelated top-level response fields.

5. The minimum bounded artifact is:

   investigationLifecycle: {
     investigationIdentity,
     governingQuestion,
     lifecycleEvent,
     lifecycleDetermination
   }

6. investigationLifecycle must be optional at the response level.

7. Ordinary non-investigative conversation must represent the absence of an
   active investigation as:

   investigationLifecycle: null

8. Runtime must not manufacture a lifecycle artifact merely because the
   conversation contains uncertainty, evidence, questions, or multiple turns.

9. Matilda remains the semantic author of whether an Investigation Lifecycle
   artifact exists.

10. Matilda remains the semantic author of:

    investigationIdentity
    governingQuestion
    lifecycleEvent
    lifecycleDetermination

11. investigationIdentity is semantic identity, not storage identity.

12. It must remain distinct from:

    conversation_id
    interpretation_entry_id

13. For a newly entered investigation, Matilda may author a new
    investigationIdentity.

14. For continuation or advancement, prior lifecycle context may supply the
    existing investigationIdentity to Matilda.

15. Matilda must preserve that identity when the same investigation continues.

16. Deterministic runtime may validate identity continuity.

17. Deterministic runtime must not invent a replacement investigationIdentity
    when Matilda fails to preserve required continuity.

18. A continuity violation must fail closed rather than being silently repaired
    by runtime inference.

19. governingQuestion identifies the semantic determination around which the
    investigation is organized.

20. For continued or advanced lifecycle events, runtime may validate that the
    governing investigation remains correlated with prior supplied lifecycle
    context.

21. Runtime must not independently rewrite the governingQuestion to manufacture
    semantic continuity.

22. lifecycleEvent remains bounded to:

    entered
    continued
    advanced
    resolved
    superseded
    abandoned

23. Deterministic runtime may validate that lifecycleEvent belongs to this
    vocabulary.

24. Deterministic runtime may derive mechanical state only after Matilda has
    authored a valid lifecycleEvent:

    entered     -> active
    continued   -> active
    advanced    -> active
    resolved    -> closed/resolved
    superseded  -> closed/superseded
    abandoned   -> closed/abandoned

25. lifecycleDetermination remains conditionally substantive:

    entered     -> optional/null
    continued   -> optional/null
    advanced    -> required
    resolved    -> required
    superseded  -> optional when no material replacement determination exists
    abandoned   -> optional when no material abandonment determination exists

26. For advanced, lifecycleDetermination records the material investigative
    progress established by the current turn.

27. For resolved, lifecycleDetermination records the substantive determination
    resolving the governing question.

28. Runtime may validate presence requirements associated with lifecycleEvent.

29. Runtime must not generate lifecycleDetermination from:

    durableInterpretation
    reply
    evidence
    selectedContextSegments
    evidenceSufficient
    unresolved_questions
    chronology

30. Successor relationships are not part of the minimum bounded artifact.

31. A superseded investigation does not always have a formally entered
    successor investigation at the same moment.

32. Successor identity therefore remains an optional future extension only when
    repository evidence demonstrates that it is required.

33. The bounded semantic artifact does not require immediate dedicated
    Investigation Lifecycle persistence.

34. Representation and persistence are separate architectural questions.

35. Existing repository evidence does not establish that lifecycle facts must
    be added to the IEL schema before their semantic response representation can
    be defined and validated.

36. Existing repository evidence also does not establish that a dedicated
    Investigation Lifecycle database table is required.

37. Therefore neither IEL extension nor dedicated persistence is a prerequisite
    for establishing the bounded semantic representation.

38. Persistence must remain a later corridor.

39. The next implementation-readiness question is narrower:

    What is the smallest safe structured-response contract change that allows
    Matilda to author the optional bounded investigationLifecycle artifact while
    preserving all existing response semantics and fail-closed validation?

40. That implementation-readiness investigation must determine:

    - exact TypeScript representation;
    - exact structured-output schema representation;
    - null/absence semantics;
    - lifecycleEvent validation;
    - conditional lifecycleDetermination validation;
    - continuity-validation inputs;
    - prompt requirements;
    - test surface;
    - whether workflow consumption may initially remain absent;
    - rollback boundary.

41. No persistence implementation is authorized by this classification.

42. No IEL extension is authorized by this classification.

43. No dedicated lifecycle runtime state is authorized by this classification.

44. No workflow consumption is authorized by this classification.

45. No database schema change is authorized by this classification.

46. Phase 1 Response Composition remains closed.

47. Conversation Engine Generation Stability remains deferred and separate.

48. The representation preserves:

    one user message
    -> one workflow
    -> one Ollama invocation.

49. The representation preserves Matilda as Interpretation Authority.

Smallest next unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READINESS

Determine from repository evidence:

1. The exact current structured response type and schema surfaces that would
   require extension.

2. The smallest TypeScript type for the optional bounded
   investigationLifecycle artifact.

3. The smallest structured-output schema extension capable of enforcing the
   lifecycleEvent vocabulary.

4. How null investigationLifecycle is represented and validated.

5. How lifecycleDetermination conditional requirements can fail closed.

6. What prior lifecycle context would eventually be required for deterministic
   continuity validation without runtime semantic inference.

7. Whether continuity validation belongs in parse/contract validation or a
   later workflow-owned validation seam.

8. Whether initial implementation can safely author and validate the artifact
   without persisting or consuming it downstream.

9. Exact unit and guard tests required before implementation authorization.

10. Exact rollback surface.

Do not implement yet.

Do not change database schema.

Do not extend IEL.

Do not add dedicated Investigation Lifecycle persistence.

Do not create dedicated Investigation Lifecycle runtime state.

Do not add workflow consumption.

Do not parse lifecycle facts from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer lifecycle state from evidenceSufficient.

Do not infer lifecycle state from selectedContextSegments.

Do not reopen Phase 1.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into Phase 2.

Do not add retries.

Do not add another model invocation.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.

CLASSIFICATION

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during representation classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-semantic-fact-representation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_ARTIFACT_READY"
echo "REPRESENTATION=OPTIONAL_BOUNDED_INVESTIGATION_LIFECYCLE_ARTIFACT"
echo "ORDINARY_CONVERSATION=investigationLifecycle:null"
echo "PERSISTENCE_NOT_AUTHORIZED"
echo "IEL_EXTENSION_NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READINESS"

git add scripts/classify-investigation-lifecycle-semantic-fact-representation.sh
git commit -m "Classify Investigation Lifecycle semantic representation"
git push
