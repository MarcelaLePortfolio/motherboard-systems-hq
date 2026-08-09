#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENTATION FINDINGS ==="

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_SEGMENTATION_NEEDS_METADATA_EXTENSION

Repository-supported determination:

1. Current project-context retrieval operates through four distinct units:

   - git grep produces matched source lines;
   - candidatesByPath collapses matches to one ranked candidate per file;
   - selectedCandidates selects up to MAX_MATCHES file-level candidates;
   - readBoundedExcerpt(...) expands each selected candidate around its matched
     line into a bounded multi-line excerpt.

2. The semantic invocation receives the bounded excerpt.

   It does not receive independently identified line, sentence, paragraph,
   block, or semantic-unit candidates.

3. Current retrieval preserves:

   - projectId;
   - relativePath;
   - matched lineNumber;
   - bounded excerpt text;
   - provenance;
   - authorityStatus.

4. The retained lineNumber identifies the original matched line.

   It does not identify the exact beginning and ending source lines represented
   by the bounded excerpt after:

   start = lineNumber - 3
   end   = lineNumber + 2

   nor after trim() and the MAX_EXCERPT_CHARACTERS truncation.

5. Therefore the current MatildaProjectContextExcerpt contract does not contain
   sufficient explicit metadata to represent finer segmented units with exact
   source-range provenance.

6. Deterministic segmentation is nevertheless technically possible without
   itself deciding semantic relevance.

7. Matched-line-only segmentation is deterministic and has precise provenance,
   but is potentially too lossy.

   Repository evidence can depend on surrounding lines, including:

   - multiline TypeScript expressions;
   - declarations whose meaning depends on adjacent fields;
   - markdown lists;
   - structured JSON;
   - SQL;
   - CSS;
   - explanatory documentation blocks.

8. Individual-line segmentation is also deterministic but has the same
   structural-context risk.

9. Sentence segmentation is not a safe repository-wide primitive.

   The admitted repository surface contains source code, markdown, JSON, SQL,
   CSS, and JavaScript/TypeScript.

   Punctuation does not provide a uniform structural boundary across those
   formats.

10. Syntax-aware segmentation could preserve meaningful structural units for
    particular languages, but would require format-specific parsing and a larger
    architectural surface than the currently established problem justifies.

11. Blank-line paragraph/block segmentation is deterministic and avoids direct
    semantic relevance judgment.

12. Blank-line segmentation may preserve more local structural context than
    matched-line-only or individual-line segmentation.

13. Blank-line segmentation is not itself sufficient to solve Adaptive Detail
    Selection.

    A deterministic segmenter can answer:

    "What smaller source units exist?"

    It cannot safely answer:

    "Which of these units materially affects the user's immediate answer?"

14. The latter question is semantic relevance selection.

15. Therefore segmentation and semantic admission must remain distinct
    responsibilities.

16. The repository currently contains no identified segmentation utility or
    finer project-context admission layer that already owns this responsibility.

17. A deterministic segmentation stage could conceptually exist after current
    retrieval and before conversation-context composition without changing:

    - query-term extraction;
    - candidate scoring;
    - ranked file selection;
    - MAX_MATCHES;
    - semantic relevance ownership.

18. However, implementing such a stage now would be premature because its
    provenance contract has not been established.

19. In particular, supportSourceReferences currently identify project evidence
    using:

    relativePath + lineNumber

    where lineNumber corresponds to the supplied project-context excerpt.

20. Evidence Composition also maps supplied project-context evidence through
    that same source identity.

21. Introducing multiple finer units derived from one current excerpt therefore
    raises an identity question:

    whether segmented candidates retain the matched lineNumber, acquire exact
    source-range metadata, or require another deterministic unit identity.

22. That identity/provenance question must be resolved before segmentation is
    implemented so that finer units do not weaken or ambiguously redefine:

    - supportSourceReferences;
    - Source-Excerpt evidence;
    - exact source provenance;
    - deterministic deduplication.

23. This investigation does not establish that deterministic segmentation alone
    can solve the mixed-excerpt problem.

24. Current evidence instead supports the following architecture:

    retrieval
      -> bounded source evidence
      -> deterministic candidate segmentation
      -> semantic admission/detail selection
      -> single semantic reply composition

    with segmentation and semantic admission remaining separate concerns.

25. The semantic admission/detail-selection owner remains unresolved and must
    not be designed inside this unit.

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_SEGMENT_PROVENANCE_CONTRACT

Purpose:

Determine the smallest deterministic metadata contract capable of representing
finer project-context candidate units with exact source provenance while
preserving existing Evidence Composition and supportSourceReferences semantics.

The investigation must determine whether the existing:

relativePath + lineNumber

identity can safely represent segmented candidates or whether exact range
metadata is required.

Do not implement segmentation yet.

Do not implement semantic admission.

Do not modify project-context retrieval.

Do not change ranking or MAX_MATCHES.

Do not change supportSourceReferences semantics.

Do not change Evidence Composition semantics.

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
echo "ADAPTIVE_DETAIL_SEGMENTATION_NEEDS_METADATA_EXTENSION"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_SEGMENT_PROVENANCE_CONTRACT"
