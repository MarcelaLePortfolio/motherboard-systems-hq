#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SEMANTIC ADMISSION DETERMINATION ==="

if [[ "$(git rev-parse --short HEAD)" != "3cb90a68" ]]; then
  echo "STOP: HEAD no longer matches semantic-admission investigation checkpoint 3cb90a68."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-semantic-admission-determination\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_INVESTIGATION_READY

Repository-supported determination:

1. Deterministic project-context segmentation is implemented and validated, but
   segmented candidates remain inert.

2. The remaining decision is semantic materiality:

   which structurally valid candidate segments materially affect the user's
   immediate response.

3. Deterministic workflow code must not own that decision.

   Determining whether arbitrary repository content materially affects the
   user's requested answer is semantic interpretation rather than provenance,
   membership, ordering, or structural validation.

4. Assigning that decision to deterministic workflow code would therefore risk
   moving Interpretation Authority away from Matilda.

5. Existing project-context retrieval and ranking do not own this decision.

   They determine whether repository material is sufficiently relevant to
   retrieve as project context.

   They do not determine which semantic details inside retrieved evidence should
   participate in the final response.

6. Extending retrieval ranking into response-level semantic materiality would
   collapse retrieval relevance and response composition into one responsibility.

7. Conversation Context Runtime also does not currently own semantic evaluation.

   It composes existing read models and passes project evidence through.

8. Adding semantic materiality judgment there would introduce a new semantic
   evaluator into a deterministic composition layer.

9. A second model invocation is unnecessary and violates the established:

   one user message -> one workflow -> one Ollama invocation

   architecture.

10. Post-model semantic filtering is also unsafe.

    Removing Matilda-authored natural-language content after generation would
    require semantic judgment and could alter Matilda-authored meaning.

11. Therefore Matilda inside the existing semantic invocation is the only
    identified owner consistent with the current authority and invocation
    architecture.

12. This preserves:

    User = Intent Authority
    Matilda = Interpretation Authority

13. However, simply exposing all deterministic segments to Matilda without a
    bounded admission contract does not by itself establish a reliable Adaptive
    Detail Selection architecture.

14. The Boundary Composition mixed-excerpt failure already demonstrated that
    semantically irrelevant colocated material can be surfaced even when the
    reply contract instructs Matilda to omit immaterial boundaries.

15. Segmentation improves the granularity of candidate context.

    It does not itself establish which segmented candidates Matilda considered
    materially relevant.

16. Existing supportSourceReferences must not be repurposed to own semantic
    admission.

17. The current response contract explicitly defines supportSourceReferences as:

    support provenance only.

18. It identifies supplied sources that explicitly support the conclusion,
    recommendation, or assessment expressed in the completed reply.

19. That is distinct from the pre-reply question:

    which candidate context details should participate in response composition.

20. Reusing supportSourceReferences for admission would therefore overload its
    established semantics and reopen the closed Evidence Composition corridor.

21. evidence cannot own semantic admission because it is a deterministic
    Source-Excerpt presentation artifact derived from validated project-context
    support.

22. evidenceSufficient cannot own semantic admission because it represents
    sufficiency of validated support provenance, not response-detail selection.

23. explanationStatus cannot own semantic admission because it classifies
    whether supporting reasoning is Optional or Recommended.

24. durableInterpretation cannot own semantic admission because it records the
    durable interpretation of user meaning, intent, decisions, constraints, and
    unresolved questions.

25. Repurposing durableInterpretation for ephemeral context selection would
    collapse durable semantic interpretation and per-invocation response
    composition.

26. Therefore no existing structured response artifact has an established
    ownership contract appropriate for segment-level semantic admission.

27. Repository evidence supports investigation of a distinct internal structured
    admission artifact.

28. That artifact must not yet be assumed necessary in final form.

    Its exact contract, ownership, lifecycle, validation rules, and relationship
    to reply generation still require bounded investigation before
    implementation.

29. The strongest candidate architecture is a model-authored internal selection
    artifact produced inside the existing Ollama invocation.

30. Such an artifact could contain only identities of deterministic segment
    candidates actually supplied to that invocation.

31. Matilda would own the semantic decision about materiality.

32. Runtime code could then validate only deterministic properties:

    - the selected identity was supplied;
    - its source path matches;
    - its source range matches;
    - duplicates are removed deterministically;
    - malformed or invented identities fail closed.

33. That validation would not determine relevance and therefore would not
    transfer Interpretation Authority to deterministic code.

34. A candidate artifact must remain distinct from supportSourceReferences.

35. Semantic admission asks:

    "Which supplied context details are materially relevant to composing this
    response?"

36. Support provenance asks:

    "Which supplied sources explicitly support the conclusion,
    recommendation, or assessment that Matilda actually expressed?"

37. Those responsibilities may overlap in individual cases but are not
    semantically identical.

38. The artifact should remain internal to response composition unless a later
    investigation establishes a reason to expose or persist it.

39. No current evidence justifies persistence.

40. No current evidence justifies modifying IEL, conversation-turn persistence,
    API, client, Living Draft, Approval, Delegation, Envelope, or Execution
    architecture.

41. The architecture can continue to preserve:

    one user message
      -> one workflow
      -> one Ollama invocation
      -> independently authored reply
      -> independently authored durableInterpretation

42. Semantic reply authorship remains entirely Matilda-owned.

43. Deterministic segmentation remains structural only.

44. Deterministic validation remains provenance/membership validation only.

45. Evidence Composition remains closed.

46. Boundary Composition remains closed at its documented context-selection
    dependency and must not be reopened during this investigation.

47. The next unit must therefore investigate the smallest structured semantic
    admission artifact contract before exposing segments to the live Ollama
    path.

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_CONTRACT

That investigation must determine:

- artifact name and semantic definition;
- exact segment identity shape;
- whether the field belongs in OllamaStructuredResponse;
- whether it belongs in OllamaChatResult;
- whether it remains internal to ollamaChat;
- deterministic validation and fail-closed behavior;
- whether zero selected segments is valid;
- relationship between selected segments and reply authorship;
- relationship to supportSourceReferences;
- relationship to Evidence Composition;
- whether candidate segments can be supplied without changing the public
  MatildaProjectContextExcerpt contract;
- whether the artifact needs any persistence;
- the smallest testable implementation seam.

Do not implement the artifact yet.

Do not expose segment candidates to Ollama yet.

Do not modify project-context retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

Do not modify MatildaProjectContextExcerpt.

Do not redefine supportSourceReferences.

Do not redefine evidenceSufficient.

Do not modify Evidence Composition.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.

Preserve one user message -> one workflow -> one Ollama invocation.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_INVESTIGATION_READY"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_CONTRACT"
