#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — PROMPT + SELECTED SEGMENTS SEAM DETERMINATION ==="

if [[ "$(git rev-parse --short HEAD)" != "06c6f468" ]]; then
  echo "STOP: HEAD no longer matches inspected prompt/selection seam checkpoint 06c6f468."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-prompt-selected-seams-determination\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_PROMPT_SELECTED_SEAMS_READY

Repository-supported determination:

1. The exact production implementation seam is confined to
   scripts/utils/ollamaChat.ts.

2. projectContextSegmentCandidates already reaches OllamaChatContext but is not
   serialized into the prompt.

3. The structured semantic response currently contains:

   reply
   explanationStatus
   supportSourceReferences
   evidence
   durableInterpretation

4. selectedContextSegments can be added to the same structured response without
   introducing another invocation.

5. The minimum selectedContextSegments item identity is:

   relativePath
   sourceStartLine
   sourceEndLine

6. selectedContextSegments should be required and always represented as an
   array.

7. [] is valid.

8. [] may mean:

   - no project-context candidates were supplied;
   - no supplied candidate was materially relevant;
   - conversation context alone was sufficient;
   - the current request did not require repository context.

9. selectedContextSegments must not be nullable.

10. selectedContextSegments must not contain source text.

11. selectedContextSegments must not contain parentRelativePath or
    parentLineNumber.

12. Parent identity remains deterministic runtime metadata used only for
    validation.

13. projectContextSegmentCandidates should be serialized into a distinct prompt
    section separate from the existing bounded parent project-context evidence.

14. The child candidate prompt representation should contain:

    Segment source: relativePath:start-end
    Authority status: candidate_evidence_not_authority
    text

15. Explicit provenance repetition is not necessary because the prompt can state
    once that all child candidates are deterministic subdivisions of supplied
    git-tracked project-context evidence.

16. Parent excerpts and child candidates have different responsibilities:

    parent excerpts:
      support provenance and Evidence Composition universe;

    child candidates:
      semantic-materiality selection universe.

17. Both can coexist in one invocation provided the prompt states this
    distinction explicitly.

18. Parent excerpts must remain supplied because existing:

    supportSourceReferences
    Evidence Composition
    explicit evidence requests

    depend on their established relativePath + lineNumber identity.

19. Child candidates must not replace the parent evidence section.

20. Matilda should be instructed to place in selectedContextSegments exactly the
    supplied child candidates whose project-context content materially affects
    the immediate reply.

21. Matilda should be instructed not to select a child merely because it was
    supplied.

22. Matilda may independently use conversation history.

23. Conversation history does not require selectedContextSegments membership.

24. parseStructuredResponse should validate selectedContextSegments as a
    syntactically well-formed array of exact identities.

25. Malformed selectedContextSegments must fail closed.

26. Invalid item conditions include:

    - item is not an object;
    - relativePath is missing or empty;
    - sourceStartLine is not a positive integer;
    - sourceEndLine is not a positive integer;
    - sourceEndLine is less than sourceStartLine.

27. Semantic membership validation cannot occur inside parseStructuredResponse
    because supplied projectContextSegmentCandidates are invocation context, not
    raw structured-output syntax.

28. Exact supplied-candidate membership should therefore be validated after
    parseStructuredResponse returns and before the final OllamaChatResult is
    returned.

29. Exact candidate identity key:

    relativePath:sourceStartLine:sourceEndLine

30. A selected identity not present in the supplied candidate universe must fail
    closed.

31. When no candidates were supplied, only [] is valid.

32. Exact duplicate selected identities should be deterministically
    deduplicated.

33. Deduplication is structural normalization and does not alter semantic
    authorship.

34. Project-context support consistency should be validated after both:

    selectedContextSegments membership validation;
    supportSourceReferences membership validation.

35. For each project_context_excerpt support reference:

    if supplied child candidates exist whose:

      parentRelativePath === reference.relativePath
      parentLineNumber === reference.lineNumber

    then at least one validated selectedContextSegment must correspond to one of
    those child candidates.

36. If no child candidates exist for that parent, the existing support reference
    contract remains sufficient.

37. Inconsistency must fail closed.

38. Runtime must not silently remove:

    - a supportSourceReference;
    - a selectedContextSegment.

39. Conversation-turn support remains independent of selectedContextSegments.

40. Explicit evidence-request behavior remains unchanged.

41. Deterministic explicit-evidence Source-Excerpt presentation continues to use
    supplied parent projectContextExcerpts.

42. evidenceSufficient remains derived exclusively from validated
    supportSourceReferences.

43. Evidence Composition remains parent-excerpt based.

44. selectedContextSegments does not become evidence provenance.

45. selectedContextSegments does not become durable interpretation.

46. selectedContextSegments does not require persistence.

47. No workflow consumer currently requires selectedContextSegments after
    ollamaChat validation.

48. Therefore widening OllamaChatResult solely to expose the field is not
    required for runtime behavior.

49. However, behavioral validation must be able to observe the model-owned
    selection.

50. The smallest safe observability seam is a dedicated test-only or validation
    path that captures the structured model response at the ollamaChat boundary
    without changing persisted runtime architecture.

51. This observability requirement does not block the contract implementation.

52. The implementation remains:

    one user message
      -> one workflow
      -> one Ollama invocation
      -> one structured semantic response.

53. reply remains independently Matilda-authored.

54. durableInterpretation remains independently Matilda-authored.

55. selectedContextSegments is a third semantic artifact expressing ephemeral
    project-context admission.

56. Deterministic runtime code validates identity and consistency only.

57. Runtime does not decide semantic relevance.

58. No post-model semantic filtering is introduced.

59. No second model invocation is introduced.

60. Boundary Composition remains closed.

Smallest next implementation unit:

IMPLEMENT_ADAPTIVE_DETAIL_PROMPT_AND_SELECTED_CONTEXT_SEGMENTS_CONTRACT

Required implementation:

1. Add selectedContextSegments to OllamaStructuredResponse.

2. Add selectedContextSegments to OLLAMA_CHAT_OUTPUT_SCHEMA.required.

3. Add the exact selection item JSON schema.

4. Parse and syntactically validate selectedContextSegments.

5. Serialize projectContextSegmentCandidates into a distinct child-candidate
   prompt section.

6. Add semantic-admission prompt instructions.

7. Validate exact selected identities against supplied candidates.

8. Deterministically deduplicate exact duplicate selections.

9. Validate parent support / child selection consistency.

10. Preserve conversation support independently.

11. Preserve explicit evidence behavior.

12. Preserve Evidence Composition.

13. Preserve evidenceSufficient.

14. Preserve one invocation.

Required tests:

- candidate prompt serialization;
- parent/child prompt-role distinction;
- [] accepted;
- valid exact selection accepted;
- malformed selection fails closed;
- unsupplied selection fails closed;
- duplicate selection is deduplicated;
- project support with selected child accepted;
- project support without selected child fails closed when that parent has
  candidates;
- conversation support does not require child selection;
- explicit-evidence regression remains green;
- one invocation invariant remains green;
- response-contract guard remains green.

Do not persist selectedContextSegments.

Do not add selectedContextSegments to IEL.

Do not change supportSourceReferences semantics.

Do not change Evidence Composition semantics.

Do not change evidenceSufficient semantics.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

Do not expand MAX_EXCERPT_CHARACTERS.

Do not add another model invocation.

Do not perform semantic post-filtering.

Do not reopen Boundary Composition.
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PROMPT_SELECTED_SEAMS_READY"
echo "NEXT_UNIT=IMPLEMENT_ADAPTIVE_DETAIL_PROMPT_AND_SELECTED_CONTEXT_SEGMENTS_CONTRACT"
