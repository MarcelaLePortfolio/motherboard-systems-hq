#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE TRANSITION SEMANTICS ==="

REQUIRED_ANCESTOR="cbab1dcd"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain transition-semantics evidence checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts\.sh$|^\?\? scripts/classify-investigation-lifecycle-transition-semantics\.sh$|^ M scripts/classify-investigation-lifecycle-transition-semantics\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_PLUS_NEXT_UNIT_SCRIPT_ONLY"

cat <<'FINDINGS'
Classification:

INVESTIGATION_TRANSITION_SEMANTICS_PARTIALLY_DEFINED_REQUIRE_NARROW_RECONCILIATION

Repository-supported determination:

1. Existing V3 evidence establishes Investigation Lifecycle as a genuine
   methodological responsibility.

2. Candidate V3 evidence identifies:

   - progressive uncertainty reduction across investigative sub-corridors;
   - investigation lifecycle management;
   - evidence evaluation;
   - uncertainty reduction;
   - falsification-oriented investigation closure.

3. These findings establish lifecycle concepts beyond ordinary conversation
   continuity.

4. They do not define a complete runtime-ready transition contract.

5. ENTRY is partially defined conceptually.

6. An investigation exists when work is organized around an unresolved
   determination whose uncertainty is deliberately reduced through evidence.

7. Repository evidence does not establish a sufficiently precise deterministic
   runtime condition for ENTRY.

8. ENTRY therefore requires a Matilda-authored semantic fact or another
   explicitly defined semantic signal.

9. CONTINUATION is partially defined conceptually.

10. V3 evidence supports preservation of an investigation while its governing
    question remains unresolved and uncertainty is progressively reduced.

11. Conversation identity and chronological adjacency alone are insufficient to
    establish semantic continuation.

12. Existing IEL lineage can provide correlation infrastructure, but lineage
    alone does not prove that a later interpretation continues the same
    investigation.

13. CONTINUATION therefore requires semantic continuity evidence.

14. ADVANCEMENT is meaningfully distinguishable from additional context.

15. V3 methodology treats progress as evidence or determination that materially:

    - reduces uncertainty;
    - resolves a sub-question;
    - supports or falsifies a material hypothesis;
    - establishes a meaningful boundary.

16. Retrieval of additional material alone is not advancement.

17. Whether a particular turn advances an investigation remains a semantic
    judgment owned by Matilda unless it follows deterministically from an
    already-authored semantic fact.

18. RESOLUTION is also meaningfully defined at the methodology level.

19. V3 evidence establishes falsification-oriented investigation closure and
    formal determination after evaluation of supporting and contradictory
    evidence.

20. Resolution therefore requires substantive determination of the governing
    investigative question.

21. A produced reply, successful retrieval, or evidenceSufficient=true cannot
    independently establish resolution.

22. The semantic determination of resolution belongs to Matilda as
    Interpretation Authority.

23. Runtime may deterministically persist or consume that resolution only after
    receiving an authorized semantic fact expressing it.

24. SUPERSESSION / ABANDONMENT is not sufficiently defined by current V3
    evidence.

25. Interpretation supersession cannot safely substitute for investigation
    supersession.

26. A superseded interpretation may belong to an investigation that remains
    active.

27. Likewise, an investigation may be abandoned or replaced without every
    interpretation inside it becoming superseded.

28. Therefore investigation supersession or abandonment requires narrow semantic
    reconciliation.

29. Existing lifecycle primitives are useful but insufficient by themselves.

30. durableInterpretation is the existing Matilda-authored durable semantic
    artifact and is a plausible carrier of investigation meaning.

31. However, it remains free-form text and currently provides no deterministic
    lifecycle-control contract.

32. supportSourceReferences and evidenceSufficient remain support-provenance
    artifacts.

33. selectedContextSegments remains Adaptive Detail semantic-admission metadata.

34. unresolved_questions must not be repurposed into lifecycle state.

35. supersession_status must remain interpretation-authority lifecycle metadata.

36. authority and contamination evaluations remain interpretation-history
    controls rather than Investigation Lifecycle controls.

37. Existing IEL lineage may support future lifecycle correlation without
    changing its existing authority semantics.

38. Current evidence does not establish that conversation_id itself is sufficient
    investigation identity because ordinary conversation may surround an
    investigation inside the same conversation.

39. interpretation_entry_id is insufficient because Investigation Lifecycle is
    cross-turn.

40. A durable investigation identity distinct from an individual
    interpretation_entry_id is therefore likely required if investigation
    lifecycle state is eventually persisted.

41. This does not authorize adding such an identifier yet.

42. Current repository evidence does not require concurrent active
    investigations within one conversation.

43. The minimum scope may therefore remain bounded to at most one active
    investigation per conversation unless contradictory evidence emerges.

44. The remaining semantic gap is narrow:

    define the minimum Matilda-authored lifecycle facts required for:

    - ENTRY;
    - CONTINUATION;
    - ADVANCEMENT;
    - RESOLUTION;
    - SUPERSESSION / ABANDONMENT;

    and determine which resulting mechanical transitions runtime may derive
    deterministically.

45. Representation remains undecided until that semantic contract is reconciled.

46. Therefore:

    INVESTIGATION_TRANSITION_SEMANTICS_PARTIALLY_DEFINED_REQUIRE_NARROW_RECONCILIATION

Smallest next unit:

RECONCILE_MINIMUM_MATILDA_AUTHORED_INVESTIGATION_LIFECYCLE_FACTS

No implementation is authorized.

Do not change database schema.

Do not add investigation states.

Do not add investigation identity yet.

Do not extend IEL.

Do not create dedicated Investigation Lifecycle runtime state.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not repurpose durableInterpretation yet.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer lifecycle state from evidenceSufficient.

Do not infer lifecycle state from selectedContextSegments.

Do not infer continuation from conversation identity alone.

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
echo "=== VERIFY V3 LIFECYCLE EVIDENCE ==="
grep -nE \
  'progressive uncertainty reduction|investigation lifecycle management|falsification-oriented investigation closure|uncertainty reduction' \
  docs/governance/CANDIDATE_V3_COLLABORATION_MODE_LINEAGE_INVESTIGATION.md || true

echo
echo "=== VERIFY EXISTING PRIMITIVES REMAIN DISTINCT ==="
grep -nE \
  'unresolved_questions|lineage_references|supersession_status' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during lifecycle-semantics classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-transition-semantics\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: tracked files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_TRACKED_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_TRANSITION_SEMANTICS_PARTIALLY_DEFINED_REQUIRE_NARROW_RECONCILIATION"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=RECONCILE_MINIMUM_MATILDA_AUTHORED_INVESTIGATION_LIFECYCLE_FACTS"

git add scripts/classify-investigation-lifecycle-transition-semantics.sh
git commit -m "Classify Investigation Lifecycle transition semantics"
git push
