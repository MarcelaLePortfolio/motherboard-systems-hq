#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY MINIMUM MATILDA INVESTIGATION LIFECYCLE FACT CONTRACT ==="

REQUIRED_ANCESTOR="d4cdbffb"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain minimum lifecycle-fact reconciliation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract\.sh$|^ M scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== VERIFY PRIOR RECONCILIATION ==="
grep -n \
  'MINIMUM_MATILDA_AUTHORED_INVESTIGATION_LIFECYCLE_FACTS_RECONCILED' \
  scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts.sh

cat <<'FINDINGS'

Classification:

MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_ADDITIONAL_SEMANTIC_FIELD

Repository-supported determination:

1. The prior reconciliation identified three candidate minimum semantic facts:

   investigationIdentity
   governingQuestion
   lifecycleEvent

2. Those facts establish:

   - which investigation governs attention;
   - what question or determination governs that investigation;
   - what lifecycle meaning the current turn has.

3. investigationIdentity must remain stable across turns belonging to the same
   investigation.

4. investigationIdentity must remain distinct from:

   conversation_id
   interpretation_entry_id

5. conversation_id establishes conversational scope, not semantic investigation
   identity.

6. interpretation_entry_id identifies an individual interpretation event, not
   the durable investigation spanning multiple turns.

7. governingQuestion is required because lifecycleEvent alone cannot identify
   what unresolved determination is entering, continuing, advancing, resolving,
   superseding, or being abandoned.

8. lifecycleEvent can deterministically support mechanical runtime state:

   entered     -> active
   continued   -> active
   advanced    -> active
   resolved    -> closed/resolved
   superseded  -> closed/superseded
   abandoned   -> closed/abandoned

9. Runtime may derive those mechanical states only after Matilda authors and
   runtime validates the semantic lifecycle event.

10. Runtime must not independently infer the lifecycle event.

11. The three-field contract is sufficient for ENTRY.

12. ENTRY can be represented by:

    investigationIdentity
    governingQuestion
    lifecycleEvent=entered

13. The three-field contract is sufficient for CONTINUATION when no material
    investigative change occurred.

14. CONTINUATION can be represented by the stable investigationIdentity,
    preserved governingQuestion, and:

    lifecycleEvent=continued

15. The three-field contract is not fully sufficient for ADVANCEMENT.

16. lifecycleEvent=advanced establishes that material investigative progress
    occurred, but it does not durably state what materially changed.

17. That omission would force later runtime or downstream consumers to infer the
    substantive advancement from free-form durableInterpretation, raw evidence,
    chronology, or other artifacts.

18. Such inference would move semantic interpretation outside Matilda's
    authority.

19. ADVANCEMENT therefore requires an additional Matilda-authored semantic fact
    describing the material lifecycle determination produced by the current
    turn.

20. RESOLUTION has the same requirement.

21. lifecycleEvent=resolved establishes that the governing question is
    sufficiently determined, but without a durable semantic determination it
    does not state what was determined.

22. A later consumer should not have to reconstruct the resolution from reply,
    durableInterpretation, evidence, or ledger chronology.

23. The additional fact should therefore be general rather than creating
    separate progress and resolution fields.

24. The smallest sufficient additional semantic field is:

    lifecycleDetermination

25. lifecycleDetermination is a concise durable statement of the material
    investigative determination established by the current turn.

26. For lifecycleEvent=advanced, lifecycleDetermination records what materially
    changed.

27. For lifecycleEvent=resolved, lifecycleDetermination records the substantive
    resolution of the governing question.

28. For lifecycleEvent=entered or continued, lifecycleDetermination may be null
    when the turn establishes no separate material determination.

29. For lifecycleEvent=superseded, lifecycleDetermination may preserve the
    replacement determination when materially necessary.

30. Supersession does not require a universally mandatory successor identity.

31. A successor investigation may not yet have been formally entered when the
    prior investigation is determined to be superseded.

32. Therefore successor investigation identity should be represented only when
    applicable rather than becoming a mandatory core fact.

33. ABANDONMENT does not require a mandatory reason field.

34. lifecycleEvent=abandoned is semantically sufficient to establish that the
    investigation ceases governing attention without resolution.

35. A material abandonment reason may be preserved in
    lifecycleDetermination when it matters durably.

36. Therefore the minimum sufficient semantic contract is:

    investigationIdentity
    governingQuestion
    lifecycleEvent
    lifecycleDetermination

37. lifecycleDetermination is conditionally substantive:

    - optional/null for entered;
    - optional/null for continued;
    - required for advanced;
    - required for resolved;
    - available for superseded when needed;
    - available for abandoned when needed.

38. This field does not duplicate existing IEL authority semantics.

39. unresolved_questions cannot substitute for lifecycleDetermination because
    unresolved questions and established determinations are semantically
    distinct.

40. supersession_status cannot substitute for lifecycleEvent or
    lifecycleDetermination because interpretation supersession and
    investigation lifecycle supersession are distinct.

41. evidenceSufficient cannot substitute for lifecycleDetermination because
    evidentiary support and semantic investigative determination are distinct.

42. selectedContextSegments cannot substitute for lifecycleDetermination because
    context admission is not lifecycle progress.

43. Explanation Status cannot substitute for lifecycleDetermination because
    explanation necessity is not investigation state.

44. One active investigation per conversation remains a safe minimum constraint
    under current repository evidence.

45. Nothing in current evidence requires concurrent active investigations.

46. Concurrency remains deferred until a contradictory use case requires
    reopening that assumption.

47. The four semantic facts remain compatible with:

    one user message
    -> one workflow
    -> one Ollama invocation.

48. They preserve Matilda as Interpretation Authority because Matilda authors the
    semantic lifecycle facts while deterministic runtime may only validate,
    correlate, persist, and derive mechanical state.

49. This classification does not choose representation.

50. It does not establish whether those facts belong in:

    - the structured Ollama response;
    - a bounded Investigation Lifecycle artifact;
    - IEL extension;
    - dedicated persistence;
    - or another narrow representation.

51. Representation must be investigated separately before implementation.

Smallest next unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION

Determine from repository evidence:

1. The smallest representation capable of carrying:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

2. Whether the existing single structured Ollama response is the correct
   semantic-authorship seam.

3. Whether lifecycle facts should form one bounded structured artifact rather
   than independent top-level fields.

4. How ordinary non-investigative conversation represents absence of an active
   lifecycle artifact.

5. How stable investigationIdentity can be authored and correlated without
   allowing deterministic runtime to invent semantic identity.

6. How successor relationships are represented only when applicable.

7. Whether representation requires IEL schema changes or can initially remain
   within existing persistence boundaries.

8. Which transition-validation rules must exist before persistence is
   implemented.

Do not implement.

Do not change database schema.

Do not add lifecycle facts to production artifacts.

Do not extend IEL.

Do not create dedicated Investigation Lifecycle runtime state.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

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

FINDINGS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during lifecycle-fact classification."
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
  grep -vE '^scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract\.sh$' ||
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
echo "MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_ADDITIONAL_SEMANTIC_FIELD"
echo "MINIMUM_FACTS=investigationIdentity,governingQuestion,lifecycleEvent,lifecycleDetermination"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION"

git add scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh
git commit -m "Classify minimum Investigation Lifecycle fact contract"
git push
