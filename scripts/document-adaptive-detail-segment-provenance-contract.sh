#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENT PROVENANCE CONTRACT ==="

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_INTERNAL_SEGMENT_IDENTITY_READY

Repository-supported determination:

1. The current MatildaProjectContextExcerpt identity is operationally:

   relativePath + lineNumber

2. lineNumber is the original git-grep matched line carried forward from the
   selected retrieval candidate.

3. lineNumber is not:

   - the first line of the bounded excerpt;
   - the last line of the bounded excerpt;
   - an exact source range for the excerpt.

4. readBoundedExcerpt(...) expands around that matched line using:

   start = lineNumber - 3
   end   = lineNumber + 2

   subject to file bounds, trim(), and MAX_EXCERPT_CHARACTERS truncation.

5. Therefore relativePath + lineNumber currently identifies the admitted
   project-context excerpt by its matched-line anchor.

6. That identity is already semantically and operationally coupled to the
   existing support provenance contract.

7. The structured Ollama response schema requires project-context support
   references to contain:

   type: project_context_excerpt
   relativePath
   lineNumber

8. The semantic prompt explicitly instructs Matilda to return the exact
   relativePath and lineNumber supplied in bounded project-context evidence.

9. Runtime support-reference membership validation constructs the supplied
   project-context source set using:

   relativePath + lineNumber

10. Runtime deterministic support-reference deduplication uses:

    project_context_excerpt + relativePath + lineNumber

11. Runtime exact excerpt lookup constructs:

    suppliedProjectContextExcerptBySource

    using:

    relativePath + lineNumber -> excerpt text

12. Evidence Composition uses that same identity to recover the exact supplied
    excerpt for support-driven Source-Excerpt evidence.

13. Explicit evidence requests also expose project-context evidence using the
    same:

    relativePath + lineNumber

    reference.

14. Therefore relativePath + lineNumber currently participates in:

    - model-visible source identity;
    - support-reference membership validation;
    - deterministic support-reference deduplication;
    - exact supplied-excerpt lookup;
    - Source-Excerpt evidence construction;
    - explicit evidence presentation.

15. Multiple finer segments derived from one existing bounded excerpt cannot
    safely share the same relativePath + lineNumber identity if they are exposed
    as independently selectable project-context units.

16. Shared identity would make multiple segments indistinguishable to the
    existing map and set operations.

17. In particular, multiple segments sharing one source key would make exact
    segment lookup ambiguous because:

    suppliedProjectContextExcerptBySource

    currently maps one source key to one excerpt string.

18. Existing support-reference deduplication would also collapse multiple
    independently supported segments carrying the same relativePath +
    lineNumber.

19. Therefore candidate contract A:

    {
      relativePath,
      lineNumber
    }

    is insufficient for independently identifiable segmented candidates.

20. Candidate contract B:

    {
      relativePath,
      startLineNumber,
      endLineNumber
    }

    provides an unambiguous deterministic source-range identity when segments
    occupy distinct source ranges.

21. Candidate B can support multiple segments from one original excerpt and
    exact source-range attribution.

22. However, candidate B does not independently preserve the original
    git-grep matched-line lineage.

23. Candidate contract C:

    {
      relativePath,
      matchedLineNumber,
      startLineNumber,
      endLineNumber
    }

    preserves both:

    - original retrieval lineage through matchedLineNumber;
    - exact segmented source provenance through startLineNumber and
      endLineNumber.

24. Candidate C therefore contains the smallest complete deterministic metadata
    identified by this investigation for an internal segmented candidate.

25. Candidate contract D adds:

    deterministicUnitId

26. No current repository evidence establishes that deterministicUnitId is
    necessary if the segmented unit corresponds to a unique contiguous source
    range.

27. For contiguous deterministic source segments:

    relativePath + startLineNumber + endLineNumber

    is sufficient to derive stable identity.

28. matchedLineNumber should remain metadata for retrieval lineage rather than
    become necessary to distinguish otherwise identical source ranges.

29. A deterministicUnitId would therefore duplicate derivable identity unless a
    future segmentation design permits:

    - multiple distinct candidate units over the exact same source range; or
    - non-contiguous source units.

30. Neither requirement is currently established.

31. Candidate C is therefore the smallest safe internal provenance contract:

    {
      relativePath,
      matchedLineNumber,
      startLineNumber,
      endLineNumber
    }

32. This contract should initially belong only to an internal segmented-candidate
    representation.

33. It should not replace or redefine MatildaProjectContextExcerpt.

34. It should not alter MatildaSupportSourceReference.

35. It should not alter the structured Ollama response schema.

36. It should not alter Evidence Composition.

37. It should not alter existing supportSourceReferences semantics.

38. This separation preserves the current external project-context excerpt as
    the admitted evidence object while allowing a successor investigation to
    reason precisely about finer deterministic candidate units.

39. Establishing the internal provenance contract does not itself authorize
    segmentation.

40. Establishing the internal provenance contract does not determine which
    segmented units are materially relevant.

41. Semantic admission/detail selection remains a separate unresolved
    responsibility.

42. Project-context retrieval behavior remains unchanged.

43. Ranking and MAX_MATCHES remain unchanged.

44. Boundary Composition remains closed and blocked at its established
    context-selection dependency.

45. The architecture remains:

    retrieval
      -> bounded source evidence
      -> deterministic candidate segmentation
      -> semantic admission/detail selection
      -> single semantic reply composition

    but only the metadata contract required for the future deterministic
    candidate-segmentation seam is ready.

Candidate evaluation:

A. relativePath + lineNumber

   Identity:
   insufficient for multiple segments derived from one admitted excerpt.

   Matched-line lineage:
   preserved.

   Exact range:
   not represented.

   Multiple segments:
   ambiguous.

   Existing support semantics:
   already established; must remain unchanged.

B. relativePath + startLineNumber + endLineNumber

   Identity:
   sufficient for distinct contiguous source ranges.

   Matched-line lineage:
   not independently preserved.

   Exact range:
   represented.

   Multiple segments:
   supported when ranges differ.

   Existing support semantics:
   would require change if exposed externally; therefore keep internal only.

C. relativePath + matchedLineNumber + startLineNumber + endLineNumber

   Identity:
   sufficient.

   Matched-line lineage:
   preserved.

   Exact range:
   represented.

   Multiple segments:
   supported when ranges differ.

   Existing support semantics:
   need not change when contract remains internal.

D. Candidate C + deterministicUnitId

   Identity:
   sufficient but currently redundant.

   Matched-line lineage:
   preserved.

   Exact range:
   represented.

   Multiple segments:
   supported.

   Existing support semantics:
   need not change when internal.

   Additional identifier:
   not justified by current evidence.

Smallest safe contract:

INTERNAL_SEGMENT_PROVENANCE = {
  relativePath,
  matchedLineNumber,
  startLineNumber,
  endLineNumber
}

This is an architectural contract only.

It does not authorize implementation.

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_SEGMENTATION_ALGORITHM_CONTRACT

Purpose:

Determine the smallest deterministic segmentation algorithm capable of deriving
contiguous candidate units with exact source ranges from an already-retrieved
bounded project-context excerpt while preserving structural context and without
performing semantic relevance judgment.

That investigation must compare candidate deterministic segmentation strategies
against the newly established internal provenance contract before any
segmentation code is introduced.

Do not implement segmentation.

Do not implement semantic admission.

Do not modify project-context retrieval.

Do not change ranking or MAX_MATCHES.

Do not change supportSourceReferences.

Do not change Evidence Composition.

Do not change Ollama response schema.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not reopen Boundary Composition.

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
echo "ADAPTIVE_DETAIL_INTERNAL_SEGMENT_IDENTITY_READY"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_SEGMENTATION_ALGORITHM_CONTRACT"
