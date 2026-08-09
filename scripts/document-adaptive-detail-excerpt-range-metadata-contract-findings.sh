#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — EXCERPT RANGE METADATA CONTRACT FINDINGS ==="

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION_IMPLEMENTATION_READY

Repository-supported determination:

1. MatildaProjectContextExcerpt currently contains only:

   - projectId;
   - relativePath;
   - lineNumber;
   - excerpt;
   - provenance;
   - authorityStatus.

2. The existing lineNumber is the matched source line used by retrieval and
   remains the established project-context support identity together with
   relativePath.

3. readBoundedExcerpt(...) is the current single owner of bounded excerpt
   construction.

4. It already computes:

   start = Math.max(0, lineNumber - 3)
   end   = Math.min(lines.length, lineNumber + 2)

5. Because Array.slice(start, end) uses a zero-based inclusive start and
   exclusive end, the corresponding human-readable bounded source coordinates
   are:

   startLineNumber = start + 1
   endLineNumber   = end

6. Those coordinates are 1-based and inclusive.

7. No second source-file read or second range owner is required.

8. The bounded source window is subsequently materialized through:

   lines
     .slice(start, end)
     .join("\n")
     .trim()
     .slice(0, MAX_EXCERPT_CHARACTERS)

9. Therefore the original bounded source-line range and the final materialized
   excerpt are not always identical in textual extent.

10. trim() may remove boundary whitespace.

11. MAX_EXCERPT_CHARACTERS may truncate the materialized excerpt before all
    content from endLineNumber is represented.

12. Therefore endLineNumber may safely identify the end of the original bounded
    source window, but it must not mean that the complete ending source line is
    necessarily present in a character-truncated excerpt.

13. The smallest metadata necessary to preserve this distinction is:

    sourceRange: {
      startLineNumber: number;
      endLineNumber: number;
      excerptTruncated: boolean;
    }

14. excerptTruncated should indicate whether MAX_EXCERPT_CHARACTERS removed
    materialized content from the bounded source window.

15. Exact character offsets or represented ending columns are not justified by
    the current requirement.

16. No segmentation algorithm requiring character-level provenance has yet been
    selected.

17. Adding character offsets now would therefore expand the contract beyond the
    established prerequisite.

18. The safest initial representation is retrieval-internal metadata paired with
    the existing MatildaProjectContextExcerpt rather than widening
    MatildaProjectContextExcerpt itself.

19. Conceptually:

    {
      excerpt: MatildaProjectContextExcerpt;
      sourceRange: {
        startLineNumber: number;
        endLineNumber: number;
        excerptTruncated: boolean;
      };
    }

20. MatildaProjectContextExcerpt should remain unchanged in the first
    implementation unit.

21. MatildaProjectContextRetrievalResult.excerpts should also retain its existing
    behavior for current downstream consumers.

22. This prevents range metadata from leaking into:

    - MatildaConversationContext.projectContextExcerpts;
    - OllamaChatProjectContextExcerpt;
    - semantic prompt context;
    - supportSourceReferences;
    - Source-Excerpt Evidence Composition;
    - persisted evidence contracts.

23. Existing project-context support identity remains:

    relativePath + lineNumber

24. supportSourceReferences must retain that identity unchanged.

25. evidenceSufficient must retain its existing derivation from validated
    supportSourceReferences.

26. Source-Excerpt Evidence Composition must continue resolving exact supplied
    excerpts using relativePath + lineNumber.

27. The Ollama structured response schema does not require source-range metadata.

28. The semantic invocation does not require source-range metadata for this
    prerequisite.

29. Conversation-context composition does not need to consume the new metadata
    yet.

30. Persistence does not need to consume the new metadata yet.

31. The purpose of the metadata extension is only to preserve enough deterministic
    source provenance for a later segmentation investigation without requiring
    provenance reconstruction.

32. The extension can remain behaviorally inert if it:

    - computes metadata at the existing bounded-excerpt construction seam;
    - preserves the exact existing excerpt string;
    - preserves the existing excerpts array;
    - preserves candidate ranking;
    - preserves candidate admission;
    - preserves MAX_MATCHES;
    - preserves query extraction;
    - preserves relativePath + lineNumber identity;
    - does not alter downstream Ollama context.

33. Focused retrieval tests should establish:

    - existing excerpt text remains exactly unchanged;
    - startLineNumber is the correct 1-based inclusive bounded start;
    - endLineNumber is the correct 1-based inclusive bounded window end;
    - excerptTruncated is false when materialized content fits within the cap;
    - excerptTruncated is true when MAX_EXCERPT_CHARACTERS cuts content;
    - matched lineNumber remains unchanged;
    - existing excerpt ordering and count remain unchanged.

34. Existing downstream validation should protect:

    server/matilda-conversation-context-runtime.test.ts

    scripts/utils/ollamaChat.support-source-references.test.ts

    scripts/utils/ollamaChat.support-source-production.test.ts

    scripts/utils/ollamaChat.structured-evidence-object.test.ts

    scripts/utils/ollamaChat.test.ts

35. The Ollama response-contract guard must also remain green.

36. The implementation must preserve:

    one user message -> one workflow -> one Ollama invocation.

37. No repository evidence supports exposing range metadata to Matilda's semantic
    invocation at this stage.

38. No repository evidence supports changing persisted support provenance.

39. No repository evidence supports implementing segmentation in the same unit.

40. No repository evidence supports implementing semantic admission in the same
    unit.

41. Therefore the smallest safe implementation surface is:

    METADATA_ONLY_RETRIEVAL_INTERNAL_EXTENSION

Smallest next unit:

IMPLEMENT_ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION

Implementation boundary:

- retain bounded source-range metadata at the existing readBoundedExcerpt(...)
  seam;
- retain whether MAX_EXCERPT_CHARACTERS truncated materialized content;
- preserve existing excerpt text exactly;
- preserve MatildaProjectContextExcerpt;
- preserve MatildaProjectContextRetrievalResult.excerpts;
- keep new metadata internal to retrieval;
- add focused structural tests;
- rerun downstream provenance and Evidence Composition tests;
- rerun the response-contract guard.

Do not implement segmentation.

Do not implement semantic admission.

Do not change ranking or MAX_MATCHES.

Do not change query extraction.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not expose range metadata to Ollama.

Do not modify persistence, API, client, Living Draft, Approval, Delegation,
Envelope, or Execution architecture.

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
echo "ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION_IMPLEMENTATION_READY"
echo "NEXT_UNIT=IMPLEMENT_ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION"
echo "IMPLEMENTATION_NOT_STARTED"
