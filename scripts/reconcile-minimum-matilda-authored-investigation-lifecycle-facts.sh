#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE MINIMUM MATILDA-AUTHORED INVESTIGATION LIFECYCLE FACTS ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY PRIOR TRANSITION-SEMANTICS CLASSIFICATION ==="
grep -n \
  'INVESTIGATION_TRANSITION_SEMANTICS_PARTIALLY_DEFINED_REQUIRE_NARROW_RECONCILIATION' \
  scripts/classify-investigation-lifecycle-transition-semantics.sh

echo
echo "=== VERIFY EXISTING DURABLE SEMANTIC ARTIFACT ==="
grep -n -A8 -B8 \
  'durableInterpretation' \
  scripts/utils/ollamaChat.ts | head -n 160

echo
echo "=== VERIFY IEL SEMANTIC FIELDS ==="
grep -nE \
  'interpretation_event|minimum_sufficient_context|supporting_raw_evidence|matilda_observation|unresolved_questions|lineage_references|supersession_status' \
  db/matilda-interpretation-runtime.ts | head -n 180

echo
echo "=== VERIFY CURRENT WORKFLOW PERSISTENCE ==="
grep -n -A60 -B10 \
  'createInterpretationEvidenceLedgerEntry' \
  server/matilda-chat-workflow.ts | tail -n 100

cat <<'FINDINGS'

Repository-supported reconciliation target:

1. Investigation Lifecycle requires semantic facts that are distinct from
   storage state and distinct from deterministic runtime bookkeeping.

2. Matilda remains Interpretation Authority.

3. Therefore the minimum contract must identify only the semantic facts Matilda
   must author before runtime may deterministically persist, correlate, or
   transition investigation lifecycle state.

4. Ordinary conversation remains the default.

5. No lifecycle fact may be inferred merely from:

   - a user question;
   - conversation identity;
   - chronological adjacency;
   - retrieved project context;
   - evidenceSufficient;
   - selectedContextSegments;
   - Explanation Status;
   - unresolved_questions;
   - supersession_status.

6. The minimum semantic fact set should be evaluated against five required
   lifecycle transitions:

   ENTRY
   CONTINUATION
   ADVANCEMENT
   RESOLUTION
   SUPERSESSION_OR_ABANDONMENT

7. ENTRY requires a semantic determination that the current exchange has a
   governing unresolved question or determination whose answer requires
   deliberate evidence evaluation or uncertainty reduction.

8. Runtime cannot safely derive ENTRY from message form alone.

9. Therefore ENTRY requires a Matilda-authored semantic fact.

10. CONTINUATION requires a semantic determination that the current exchange
    still belongs to the same governing investigation rather than merely the
    same conversation.

11. Runtime may correlate an already-established investigation identifier, but
    it cannot invent semantic continuity.

12. Therefore CONTINUATION requires a Matilda-authored relationship to the
    existing investigation unless continuity is already made explicit by a
    prior durable semantic fact and the current semantic artifact preserves it.

13. ADVANCEMENT requires a semantic determination that something materially
    changed in the investigation:

    - uncertainty was reduced;
    - a material hypothesis was supported or falsified;
    - a sub-question was resolved;
    - a material boundary was established;
    - or another substantive investigative determination occurred.

14. Additional retrieved evidence alone is not advancement.

15. Therefore ADVANCEMENT requires a Matilda-authored semantic fact describing
    the material change.

16. RESOLUTION requires a semantic determination that the governing
    investigative question has been sufficiently answered or determined.

17. evidenceSufficient cannot substitute for that determination.

18. A reply being produced cannot substitute for that determination.

19. Therefore RESOLUTION requires a Matilda-authored semantic fact.

20. SUPERSESSION_OR_ABANDONMENT requires a semantic determination that the
    active investigation should cease governing attention because:

    - the user replaced its governing objective;
    - the user abandoned it;
    - a new investigation superseded it;
    - or later semantic evidence invalidated the investigative objective.

21. Interpretation supersession is not equivalent to investigation
    supersession.

22. Therefore SUPERSESSION_OR_ABANDONMENT requires a Matilda-authored semantic
    fact.

23. The smallest candidate semantic contract is therefore not a generic
    lifecycle-state label alone.

24. A bare state such as "active" or "resolved" would omit the semantic identity
    necessary to distinguish one investigation from another across turns.

25. The minimum useful semantic facts are:

    A. investigationIdentity

       A durable semantic identity for the governing investigation, distinct
       from conversation_id and interpretation_entry_id.

    B. governingQuestion

       A concise durable statement of the question or determination currently
       governing investigative attention.

    C. lifecycleEvent

       Exactly one semantic event describing what the current turn means to the
       investigation lifecycle.

26. The minimum candidate lifecycleEvent vocabulary is:

    entered
    continued
    advanced
    resolved
    superseded
    abandoned

27. "continued" means the governing investigation remains active without a
    material advancement established by the current turn.

28. "advanced" means the governing investigation remains active and the current
    turn materially reduces uncertainty or establishes a substantive
    investigative determination.

29. "resolved" means the governing question is sufficiently determined.

30. "superseded" means another investigative objective replaces the current
    investigation.

31. "abandoned" means the investigation ceases to govern attention without
    being resolved or replaced by a semantically successor investigation.

32. These lifecycle events remain semantic facts authored by Matilda.

33. Once authored and validated, runtime may deterministically derive mechanical
    state consequences such as:

    entered     -> active
    continued   -> active
    advanced    -> active
    resolved    -> closed/resolved
    superseded  -> closed/superseded
    abandoned   -> closed/abandoned

34. Those derived runtime states must not become independent semantic authority.

35. Runtime may also deterministically correlate successive lifecycle facts by
    exact investigation identity.

36. Runtime may reject impossible or malformed transitions once the transition
    rules are explicitly established.

37. Runtime must not silently repair semantic lifecycle facts.

38. The minimum contract does not presently require concurrent investigations.

39. Preserve the bounded assumption:

    at most one active investigation per conversation.

40. This assumption reduces state complexity while remaining consistent with
    current repository evidence.

41. A future contradictory use case may reopen concurrency as a separate
    architectural question.

42. Existing IEL lineage appears capable of carrying correlation references,
    but existing lineage semantics do not themselves provide investigation
    identity.

43. Therefore investigationIdentity must not be silently encoded into existing
    lineage_references without an explicit representation decision.

44. durableInterpretation already owns durable semantic meaning authored by
    Matilda.

45. However, durableInterpretation is currently a free-form string.

46. Free-form text alone does not provide a deterministic runtime contract for
    extracting:

    - investigationIdentity;
    - governingQuestion;
    - lifecycleEvent.

47. Runtime parsing those facts heuristically from durableInterpretation would
    move semantic interpretation into deterministic infrastructure and is not
    justified.

48. Therefore durableInterpretation may continue to narratively preserve
    investigation meaning, but it is not by itself a sufficient deterministic
    lifecycle control seam.

49. The current structured response contract has one existing Ollama invocation
    and already returns multiple independently owned semantic artifacts.

50. A future structured Investigation Lifecycle semantic artifact is therefore
    architecturally plausible without requiring another model invocation.

51. That observation does not authorize extending the structured response
    contract in this unit.

52. Before representation is chosen, the candidate semantic facts must be
    classified as the minimum sufficient lifecycle contract.

Required classification:

Exactly one of:

MATILDA_INVESTIGATION_LIFECYCLE_FACTS_MINIMUM_CONTRACT_DEFINED
MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_ADDITIONAL_SEMANTIC_FIELD
MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_BROADER_ARCHITECTURAL_MODEL
MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REMAIN_UNRESOLVED

Classification criteria:

1. Determine whether:

   investigationIdentity
   governingQuestion
   lifecycleEvent

   are sufficient to represent all five required lifecycle transitions.

2. Determine whether ADVANCEMENT additionally requires a durable progress fact
   describing what materially changed.

3. Determine whether RESOLUTION additionally requires a durable resolution fact
   describing what was determined.

4. Determine whether supersession requires an explicit successor investigation
   identity or whether that relationship can be added only when applicable.

5. Determine whether abandonment requires a reason or whether lifecycleEvent is
   semantically sufficient.

6. Determine whether runtime can derive active/closed mechanical state entirely
   from the Matilda-authored lifecycle event.

7. Determine whether one active investigation per conversation remains a safe
   minimum constraint.

8. Determine whether investigationIdentity must be stable across turns and
   distinct from conversation_id and interpretation_entry_id.

9. Determine whether any candidate fact duplicates existing IEL authority
   semantics.

10. Determine the smallest semantic contract before investigating storage or
    structured-response representation.

No implementation is authorized.

Do not change database schema.

Do not add investigation states.

Do not add investigationIdentity to production artifacts.

Do not extend IEL.

Do not create a dedicated Investigation Lifecycle runtime.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not parse lifecycle state from durableInterpretation.

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
  echo "STOP: production runtime changed during lifecycle-fact reconciliation."
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
  grep -vE '^scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation-only reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "MINIMUM_MATILDA_AUTHORED_INVESTIGATION_LIFECYCLE_FACTS_RECONCILED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_MATILDA_INVESTIGATION_LIFECYCLE_FACT_CONTRACT"

git add scripts/reconcile-minimum-matilda-authored-investigation-lifecycle-facts.sh
git commit -m "Reconcile minimum Investigation Lifecycle semantic facts"
git push
