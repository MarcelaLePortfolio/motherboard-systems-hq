#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — STRUCTURED ADMISSION ARTIFACT CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "b1a09575" ]]; then
  echo "STOP: HEAD no longer matches structured-admission investigation checkpoint b1a09575."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-structured-admission-artifact-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_NEEDS_CONTEXT_CONTRACT

Repository-supported determination:

1. The existing structured semantic response contains:

   - reply;
   - explanationStatus;
   - supportSourceReferences;
   - evidence;
   - durableInterpretation.

2. None of those fields currently represents semantic admission of
   project-context detail before or during reply composition.

3. supportSourceReferences cannot own this responsibility.

   Its prompt contract explicitly defines it as support provenance for a
   conclusion, recommendation, or assessment expressed in the completed reply.

4. Semantic admission is a different decision:

   which supplied project-context candidate units Matilda considers materially
   relevant to composing the immediate response.

5. An admitted context segment may legitimately influence response composition
   without becoming explicit support provenance for a conclusion.

6. Conversely, existing support provenance remains excerpt-level and must not be
   silently redefined as segment-level admission provenance.

7. Evidence Composition therefore does not require modification for semantic
   admission.

8. evidenceSufficient also remains unchanged because it represents sufficiency
   of validated support provenance, not context admission.

9. explanationStatus remains unchanged because it represents whether supporting
   explanation is Optional or Recommended.

10. durableInterpretation remains unchanged because ephemeral response-context
    admission is not durable user meaning, intent, decision, constraint, or
    unresolved question.

11. Repository evidence therefore continues to justify a distinct semantic
    admission artifact rather than reuse of an existing artifact.

12. Of the investigated names, selectedContextSegments is the more precise
    candidate contract name.

13. admittedDetailReferences is less precise because "detail" does not identify
    the actual deterministic unit being selected and "references" risks
    confusion with supportSourceReferences.

14. selectedContextSegments directly expresses the intended responsibility:

    Matilda selected particular supplied deterministic context segments as
    materially relevant to composing the immediate response.

15. The minimum deterministic identity for one selected segment is:

    relativePath
    sourceStartLine
    sourceEndLine

16. lineNumber should not be part of the semantic-admission identity.

17. lineNumber identifies the original retrieval match associated with the
    parent project-context excerpt.

18. A deterministic segment is instead identified by its exact source range.

19. Including lineNumber would unnecessarily couple segment identity to the
    parent retrieval match rather than the segment itself.

20. No additional opaque identifier is currently justified.

21. relativePath + sourceStartLine + sourceEndLine is sufficient to validate
    exact membership against deterministic candidates derived from the supplied
    repository context.

22. Excerpt text should not appear in the model-authored
    selectedContextSegments artifact.

23. Matilda should select identities of deterministic candidates supplied by
    runtime code rather than reproduce or reconstruct repository text inside the
    selection artifact.

24. This keeps semantic judgment and deterministic provenance separate:

    Matilda:
      decides which candidate segments are materially relevant.

    Runtime:
      validates that selected identities exactly match candidates actually
      supplied.

25. selectedContextSegments conceptually belongs in the structured response
    returned by the existing single Ollama invocation.

26. A single structured response can legitimately contain:

    - selectedContextSegments;
    - reply;
    - durableInterpretation;

    without implying multiple model invocations.

27. Those fields represent distinct semantic products authored during one
    semantic invocation.

28. reply remains the user-facing conversational response.

29. durableInterpretation remains the independently authored durable account of
    user meaning and intent.

30. selectedContextSegments remains ephemeral response-composition metadata.

31. No repository evidence supports persisting selectedContextSegments.

32. No repository evidence supports exposing it through the API, client, IEL,
    Living Draft, Approval, Delegation, Envelope, or Execution architecture.

33. The current workflow has no consumer requiring the artifact outside the
    semantic-response boundary.

34. Therefore the preferred eventual architecture is for the artifact to remain
    internal to ollamaChat unless a later implementation investigation
    identifies a necessary deterministic consumer outside that boundary.

35. Exact deterministic validation should fail closed when:

    - selectedContextSegments is not an array;
    - an entry is not an object;
    - relativePath is missing, empty, or malformed;
    - sourceStartLine is not a positive integer;
    - sourceEndLine is not a positive integer;
    - sourceEndLine is less than sourceStartLine;
    - the relativePath was not supplied as a segment candidate;
    - the exact sourceStartLine/sourceEndLine pair was not supplied;
    - only part of a supplied segment range matches;
    - a selected identity is invented;
    - a non-empty selection is returned when no segment candidates were
      supplied.

36. Duplicate otherwise-valid identities should be deterministically
    deduplicated rather than treated as a semantic failure.

37. Deduplication changes no semantic meaning because repeated selection of the
    exact same deterministic candidate does not create an additional material
    context unit.

38. This is consistent with existing deterministic normalization principles
    while remaining separate from supportSourceReferences semantics.

39. An empty selectedContextSegments array must be valid.

40. Valid reasons include:

    - no project context was supplied;
    - supplied repository context is immaterial to the immediate response;
    - conversation history alone is sufficient;
    - the current request does not require repository evidence;
    - all supplied segments are judged immaterial by Matilda.

41. When no deterministic segment candidates are supplied, the only valid
    semantic-admission result is an empty selectedContextSegments array.

42. A non-empty selection in that state must fail closed because Matilda would
    be referencing a candidate that did not exist in the invocation.

43. However, the repository does not yet contain an established context contract
    for supplying deterministic segment candidates to ollamaChat.

44. The current OllamaChatContext supplies projectContextExcerpts.

45. Those excerpts preserve the existing public excerpt identity:

    relativePath + lineNumber + excerpt + provenance + authorityStatus.

46. Deterministic segment candidates are currently retrieval-internal and inert.

47. Therefore selectedContextSegments cannot yet be safely added to the
    structured response contract because the corresponding supplied candidate
    universe does not yet exist at the Ollama boundary.

48. Implementing the response artifact first would create a selection contract
    without an authoritative deterministic candidate set against which selections
    could be validated.

49. The next architectural dependency is therefore the candidate context
    contract.

50. The smallest safe candidate-context seam is a separate optional Ollama
    context field rather than modification of MatildaProjectContextExcerpt.

51. That preserves the established project-context excerpt contract and keeps
    Adaptive Detail Selection additive.

52. The candidate field should represent deterministic context segments supplied
    specifically for semantic admission.

53. Each candidate will require at minimum:

    - relativePath;
    - sourceStartLine;
    - sourceEndLine;
    - exact segment text.

54. Exact segment text is required in the supplied candidate context because
    Matilda cannot judge materiality from provenance identity alone.

55. The model-authored selection artifact should nevertheless return only the
    deterministic identity, not the text.

56. Whether candidate context also needs provenance and authorityStatus has not
    yet been established.

57. The parent project-context excerpt already carries:

    provenance = git_tracked_project_file
    authorityStatus = candidate_evidence_not_authority

58. The next investigation must determine whether those semantics can safely be
    inherited by deterministic child segments or whether they must be explicitly
    repeated in the candidate context contract.

59. The next investigation must also determine where segment candidates are
    derived and passed forward without changing retrieval ranking or public
    MatildaProjectContextExcerpt semantics.

60. Semantic admission is conceptually prior to reply composition even though
    selection and reply are authored in one invocation.

61. The structured contract should express that Matilda composes the reply using
    only context it judges materially relevant.

62. This does not require a second invocation.

63. It does not authorize deterministic code to decide relevance.

64. It does not authorize post-model filtering.

65. It does not reopen Boundary Composition.

66. It does not modify Evidence Composition.

67. The distinction between semantic admission and support provenance is
    architecturally stable:

    semantic admission:
      which supplied context segments Matilda considers materially relevant to
      immediate response composition.

    support provenance:
      which supplied conversation turns or project-context excerpts explicitly
      support a conclusion, recommendation, or assessment actually expressed in
      reply.

68. One admitted segment may therefore produce no supportSourceReference.

69. Existing project-context support provenance may still refer to the parent
    project-context excerpt when that supplied excerpt explicitly supports the
    completed reply.

70. Segment admission must not silently alter that evidence identity.

71. The structured admission artifact contract is therefore semantically
    justified, but implementation is blocked on establishment of the supplied
    candidate context contract.

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT

Purpose:

Determine the smallest additive OllamaChatContext contract that can supply
deterministic project-context segment candidates to the existing single semantic
invocation while preserving the current public project-context excerpt,
retrieval, support provenance, and Evidence Composition contracts.

The investigation must determine:

- candidate field name;
- candidate TypeScript shape;
- whether provenance and authorityStatus are inherited or explicit;
- how candidates are derived from existing retrieval-internal segmentation;
- whether derivation occurs in retrieval, conversation-context composition, or
  workflow composition;
- whether candidate order must preserve source order;
- whether candidates remain associated with a parent excerpt;
- how exact candidate text is serialized into the prompt;
- how candidate identity is represented to Matilda;
- how absence of candidates is represented;
- whether introducing the context field requires any public contract change;
- the smallest testable implementation seam.

Do not implement selectedContextSegments yet.

Do not modify the structured response schema yet.

Do not modify OllamaChatResult yet.

Do not expose segments to Ollama yet.

Do not modify MatildaProjectContextExcerpt.

Do not redefine supportSourceReferences.

Do not redefine evidenceSufficient.

Do not modify Evidence Composition.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

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
echo "ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_NEEDS_CONTEXT_CONTRACT"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT"
