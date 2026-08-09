#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — DETERMINISTIC SEGMENTATION CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "94885503" ]]; then
  echo "STOP: HEAD no longer matches segmentation-contract investigation checkpoint 94885503."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-deterministic-segmentation-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_CONTRACT_READY

Repository-supported determination:

1. The range-metadata prerequisite is now implemented and validated.

2. readBoundedExcerpt(...) deterministically retains, internally:

   - sourceStartLine;
   - sourceEndLine;
   - excerptTruncated.

3. Existing public MatildaProjectContextExcerpt behavior remains unchanged.

4. Current repository content is heterogeneous, including substantial Markdown,
   TypeScript, SQL, JavaScript, and JSON surfaces.

5. Therefore sentence segmentation is not a safe repository-wide primitive.

6. Matched-line-only and individual-line segmentation remain deterministic but
   are too lossy as general segmentation primitives because repository evidence
   frequently depends on adjacent structural context.

7. Syntax-aware segmentation would require format-specific parsing and is not
   justified by the currently established problem.

8. Blank-line-delimited contiguous blocks remain the smallest repository-wide
   deterministic segmentation candidate identified by the investigation.

9. Blank-line segmentation performs structural partitioning only.

   It does not determine:

   - relevance;
   - materiality;
   - authority;
   - semantic importance;
   - whether a segment should influence the reply.

10. Therefore blank-line segmentation can remain entirely pre-semantic.

11. Segmentation must not operate solely on the already-materialized public
    excerpt string.

12. The public excerpt has already undergone:

    - joining;
    - trim();
    - MAX_EXCERPT_CHARACTERS truncation.

13. Operating only on that string would weaken provenance because leading and
    trailing whitespace removal obscures whether blank boundaries existed at the
    bounded source edges.

14. Character truncation can additionally produce an incomplete final
    structural block.

15. Therefore deterministic segmentation should operate on an internal bounded
    source representation derived before trim() and character truncation.

16. The existing readBoundedExcerpt(...) seam is the smallest appropriate owner
    for retaining that representation because it already owns:

    - source-file reading;
    - bounded line selection;
    - exact bounded source range;
    - character-cap materialization.

17. This does not require changing query extraction, ranking, selectedCandidates,
    MAX_MATCHES, or the public MatildaProjectContextExcerpt contract.

18. A deterministic segment candidate requires:

    {
      relativePath,
      matchedLineNumber,
      startLineNumber,
      endLineNumber,
      content
    }

19. For a contiguous deterministic segment, the identity:

    relativePath + startLineNumber + endLineNumber

    is sufficient to distinguish multiple segments derived from one bounded
    excerpt.

20. matchedLineNumber should remain lineage metadata identifying the retrieval
    match that caused the bounded source to be admitted.

21. matchedLineNumber must not be treated as the segment identity because
    multiple segments may derive from one matched bounded source.

22. No additional opaque segment identifier is currently justified.

23. Segment ordering must preserve original source order.

24. Empty blank-line-delimited units must not become candidate segments.

25. Leading or trailing blank lines in the bounded source are structural
    separators only and must not produce empty candidates.

26. Because segmentation should operate before trim(), trim() no longer creates
    ambiguity for segment source ranges.

27. Each candidate segment can derive exact line provenance directly from its
    position inside the bounded source line array.

28. Character truncation must remain a presentation concern of the existing
    public excerpt and must not define the segmentation input.

29. Therefore an excerptTruncated=true public materialization does not require
    truncating the internal deterministic candidate segments at the same
    character boundary.

30. The segmenter must use the complete already-bounded source lines selected by
    readBoundedExcerpt(...), not the 900-character materialization.

31. This does not broaden repository retrieval.

    The same bounded source window has already been selected from the same file
    for the same retrieval candidate.

32. It only preserves the already-selected bounded source long enough to derive
    smaller deterministic structural candidates.

33. Consequently there is no special "truncated final segment" in the
    segmentation layer when segmentation occurs before character truncation.

34. excerptTruncated continues to describe only whether the existing public
    excerpt materialization lost characters.

35. Deterministic segmentation and semantic admission must remain separate
    responsibilities.

36. The segmentation boundary is:

    selected retrieval candidate
    -> bounded source lines
    -> deterministic blank-line candidate segmentation

37. The successor semantic boundary is:

    deterministic candidate segments
    -> semantic admission/detail selection
    -> single semantic reply composition

38. The deterministic segmenter may answer only:

    "What contiguous structural candidate units exist inside this already
    admitted bounded source?"

39. It must not answer:

    "Which candidate is relevant enough to send to Matilda?"

40. No segment should be exposed to Ollama merely because segmentation exists.

41. No semantic admission behavior is authorized by this contract.

42. The smallest safe implementation surface is therefore:

    a. extend the internal bounded-excerpt read result with the complete bounded
       source lines or equivalent internal deterministic representation;

    b. add a pure deterministic blank-line segmentation function operating on
       that internal representation;

    c. return internal segment candidates with exact contiguous line ranges;

    d. leave public MatildaProjectContextExcerpt assembly unchanged;

    e. do not yet consume the segment candidates in conversation-context
       composition or Ollama input.

43. This allows segmentation mechanics to be implemented and tested without
    changing runtime semantic behavior.

Required implementation validation:

1. Existing retrieval ranking is unchanged.

2. MAX_MATCHES is unchanged.

3. Query extraction is unchanged.

4. Candidate selection is unchanged.

5. MatildaProjectContextExcerpt output is unchanged.

6. Blank-line segmentation is deterministic.

7. Segment ordering matches source order.

8. Segment ranges are exact and contiguous.

9. Empty segments are omitted.

10. Multiple segments from one bounded excerpt have distinct deterministic
    source-range identities.

11. matchedLineNumber remains lineage metadata.

12. Character-truncated public excerpts do not truncate the internal bounded
    source used for segmentation.

13. No semantic relevance or materiality filtering occurs.

14. No segment candidates are supplied to Ollama.

15. supportSourceReferences semantics remain unchanged.

16. Evidence Composition semantics remain unchanged.

17. evidenceSufficient semantics remain unchanged.

18. One user message -> one workflow -> one Ollama invocation remains unchanged.

19. Existing response-contract guards remain green.

Smallest next implementation unit:

IMPLEMENT_ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_PRIMITIVE

Scope:

Implement and test the internal deterministic segmentation primitive only.

Do not:

- implement semantic admission;
- select segments for Matilda;
- expose segments through MatildaConversationContext;
- expose segments to Ollama;
- modify project-context ranking;
- modify MAX_MATCHES;
- modify query extraction;
- modify selectedCandidates;
- modify MatildaProjectContextExcerpt;
- change supportSourceReferences;
- change evidenceSufficient;
- change Evidence Composition;
- add another model invocation;
- perform post-model semantic filtering;
- reopen Boundary Composition.

Preserve:

one user message -> one workflow -> one Ollama invocation.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "PROTECTED DR: 20260808_231729"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_CONTRACT_READY"
echo "NEXT_UNIT=IMPLEMENT_ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_PRIMITIVE"
