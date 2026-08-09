#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — DETERMINE SEGMENT CANDIDATE CONTEXT CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "f7277421" ]]; then
  echo "STOP: HEAD no longer matches investigated baseline f7277421."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/determine-adaptive-detail-segment-candidate-context-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
=== REPOSITORY-SUPPORTED CONTRACT DETERMINATION ===

Classification:

ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT_READY

Determination:

1. The candidate-context field should be named:

   projectContextSegmentCandidates

2. This name is preferred because the candidates are deterministic subdivisions
   of project context specifically.

3. contextSegmentCandidates is unnecessarily broad.

4. adaptiveDetailCandidates describes the consuming capability rather than the
   provenance and nature of the supplied context.

5. The minimum candidate shape should be conceptually:

   {
     relativePath: string;
     sourceStartLine: number;
     sourceEndLine: number;
     text: string;
   }

6. "text" is preferred over "excerpt" for the child candidate.

7. "excerpt" already names the established parent
   MatildaProjectContextExcerpt surface.

8. Reusing that term for both parent bounded evidence and deterministic child
   segments would blur two distinct contracts.

9. The deterministic semantic-selection identity remains:

   relativePath
   sourceStartLine
   sourceEndLine

10. Parent lineNumber is not part of segment identity.

11. The original lineNumber belongs to retrieval/excerpt identity and remains
    necessary for existing excerpt-level supportSourceReferences and Evidence
    Composition.

12. Segment identity must not silently redefine that established identity.

13. No opaque segment ID is justified.

14. provenance does not need to be independently model-authored or independently
    discovered for each child segment.

15. Every current segment candidate is deterministically derived from a bounded
    git-tracked project-context excerpt.

16. Its provenance can therefore be inherited deterministically from the parent.

17. authorityStatus can likewise be inherited from the parent.

18. A child segment cannot become more authoritative than the parent evidence
    from which it was deterministically derived.

19. The semantic invocation should nevertheless be told that segment candidates
    retain the same candidate-evidence-not-authority semantics.

20. The model does not need provenance or authorityStatus as part of the
    selectedContextSegments identity.

21. Retrieval is the correct owner of deterministic candidate derivation.

22. Retrieval already owns:

    - repository access;
    - matched source lines;
    - bounded source extraction;
    - exact source-range metadata;
    - the inert deterministic segmentation primitive.

23. Moving derivation into conversation-context composition, workflow, or
    ollamaChat would duplicate retrieval-owned source logic or require those
    layers to reconstruct information retrieval already possesses.

24. Therefore retrieval should eventually expose segment candidates as a
    separate additive result field.

25. Existing projectContextRetrieval.excerpts must remain unchanged.

26. This is an internal server read-model extension, not a redefinition of
    MatildaProjectContextExcerpt.

27. Conversation-context composition should pass the candidate collection
    through without semantic filtering or mutation.

28. Workflow should only orchestrate passage of that deterministic collection
    into ollamaChat.

29. ollamaChat should own serialization of supplied candidates into the semantic
    invocation because it already owns the semantic prompt contract.

30. Candidate order must be deterministic.

31. Preserve retrieved excerpt order first.

32. Preserve source order of segments inside each parent excerpt second.

33. Exact duplicate range identities should be deterministically deduplicated.

34. Current blank-line segmentation of a single bounded source sequence should
    not create overlapping ranges.

35. If future candidate derivation produces conflicting duplicate identities
    with different text, that condition must fail closed rather than silently
    choose one.

36. No project context should produce an empty candidate array.

37. A parent excerpt producing no non-empty deterministic segment should
    contribute no candidate.

38. Segmentation unavailability must not be silently represented as semantic
    rejection.

39. If deterministic candidate derivation cannot be completed where the contract
    requires it, runtime code should fail closed or preserve the pre-Adaptive
    Detail path according to the implementation unit's explicitly established
    compatibility contract.

40. That fallback behavior must be established by implementation tests rather
    than invented here.

41. Segment candidates must not expose source content beyond the existing
    admitted bounded project-context excerpt.

42. The retrieval implementation internally retains pre-truncation bounded
    source lines.

43. Using those lines wholesale for child candidates could expose content beyond
    MAX_EXCERPT_CHARACTERS when the parent public excerpt was truncated.

44. That would silently broaden the semantic context available to Matilda.

45. Therefore candidate text must remain bounded by the semantic content already
    admitted through the current excerpt boundary.

46. Adaptive Detail Selection does not authorize expansion of
    MAX_EXCERPT_CHARACTERS.

47. The candidate derivation implementation must explicitly reconcile exact
    source ranges with the existing character truncation boundary.

48. A candidate must never claim an exact source range containing source text
    that was not actually supplied in that candidate.

49. If truncation cuts through a deterministic structural segment, the
    implementation must not fabricate full-range provenance for partial text.

50. The smallest safe implementation must therefore derive only candidates whose
    exact text and exact range remain representable inside the currently admitted
    bounded excerpt surface.

51. If the current truncation mechanism prevents exact reconstruction of the
    final partial structural unit, that unit should not be exposed as an exact
    candidate until a deterministic partial-range representation is established.

52. This preserves the existing retrieval boundary rather than broadening it.

53. Parent projectContextExcerpts must continue to reach ollamaChat.

54. They remain the established universe for:

    - supportSourceReferences;
    - Evidence Composition;
    - explicit evidence requests;
    - excerpt-level provenance validation.

55. Child candidates cannot replace them in this corridor.

56. Supplying both parent excerpts and child candidates creates textual
    duplication if both full representations are serialized independently.

57. That duplication is material because it can increase prompt weight and blur
    the distinction between support evidence and semantic-admission candidates.

58. Therefore the eventual prompt contract must distinguish their roles
    explicitly.

59. Parent excerpts remain established support-provenance evidence.

60. Child candidates represent deterministic selectable subdivisions for
    immediate response materiality.

61. Matilda must not interpret candidate selection as authority, support
    provenance, evidence sufficiency, or durable interpretation.

62. However, this does not require another model invocation.

63. It also does not require removal of parent excerpts.

64. The smallest candidate-context implementation should establish the data
    contract and deterministic passage first.

65. It should not yet implement selectedContextSegments.

66. It should not yet require Matilda to perform semantic admission.

67. This allows the deterministic candidate universe to be validated before the
    structured semantic artifact depends upon it.

68. Candidate context is ephemeral.

69. It must not be persisted into:

    - IEL;
    - conversation turns;
    - Living Draft;
    - Approval;
    - Delegation;
    - Envelope;
    - Execution.

70. Before selectedContextSegments exists, the only required consumers are:

    retrieval:
      derives the deterministic candidates;

    conversation-context composition:
      passes candidates unchanged;

    workflow:
      passes candidates into the semantic context;

    OllamaChatContext:
      accepts the additive optional candidate field.

71. The first implementation unit should stop before prompt serialization.

72. This avoids exposing inert candidates to Matilda before the semantic
    selection contract exists.

73. The smallest testable implementation seam is therefore:

    retrieval
      -> additive projectContextSegmentCandidates read-model field
      -> conversation-context pass-through
      -> workflow pass-through
      -> optional OllamaChatContext.projectContextSegmentCandidates

74. Tests must establish:

    - existing excerpts remain byte-for-byte semantically unchanged;
    - candidate identity uses exact source ranges;
    - candidate text does not exceed the currently admitted excerpt boundary;
    - deterministic ordering;
    - deterministic deduplication;
    - provenance/authority inheritance does not redefine parent contracts;
    - no persistence;
    - no prompt serialization yet;
    - no structured-response change;
    - no second model invocation.

75. After that deterministic context contract is implemented and validated, a
    separate successor unit may investigate prompt serialization and the
    selectedContextSegments structured semantic contract together.

Smallest next unit:

IMPLEMENT_ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT

Scope:

Implement only the deterministic additive candidate-context data path:

retrieval
-> conversation-context composition
-> workflow
-> OllamaChatContext

Do not serialize candidates into the Ollama prompt yet.

Do not implement selectedContextSegments yet.

Do not modify the structured response schema.

Do not modify OllamaChatResult.

Do not modify MatildaProjectContextExcerpt.

Do not redefine supportSourceReferences.

Do not redefine evidenceSufficient.

Do not modify Evidence Composition.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

Do not expand MAX_EXCERPT_CHARACTERS.

Do not expose source content beyond the currently admitted bounded excerpt.

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
echo "ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT_READY"
echo "NEXT_UNIT=IMPLEMENT_ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT"
