#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENTATION ALGORITHM FINDINGS ==="

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_REQUIRED

Repository-supported determination:

1. Current bounded project-context retrieval reads the original source file into
   source lines and computes:

   start = Math.max(0, lineNumber - 3)
   end   = Math.min(lines.length, lineNumber + 2)

2. The retrieval layer therefore temporarily knows the exact source-line range
   from which each bounded excerpt is constructed.

3. That range information is discarded before the MatildaProjectContextExcerpt
   is returned.

4. The returned excerpt contains only:

   relativePath
   lineNumber
   excerpt
   provenance
   authorityStatus

5. The retained lineNumber is the original matched-line anchor.

6. It is not sufficient to reconstruct the exact bounded source range after the
   excerpt has been materialized.

7. The excerpt text itself is produced through:

   lines
     .slice(start, end)
     .join("\n")
     .trim()
     .slice(0, MAX_EXCERPT_CHARACTERS)

8. trim() destroys information about leading and trailing whitespace and blank
   lines that were present inside the original bounded source range.

9. MAX_EXCERPT_CHARACTERS truncation can remove complete trailing lines, part
   of a trailing line, blank-line boundaries, or closing structural context.

10. Therefore exact source provenance cannot safely be reconstructed from the
    already-materialized excerpt string alone.

11. A segmenter operating only on the excerpt string could deterministically
    split the string, but it could not reliably assign the established internal
    provenance contract:

    {
      relativePath,
      matchedLineNumber,
      startLineNumber,
      endLineNumber
    }

12. Re-reading the original source file using relativePath + matchedLineNumber
    would duplicate the existing bounded-range construction algorithm and create
    a second owner for that behavior.

13. The safer deterministic seam is for bounded excerpt construction to retain
    the exact source-range metadata it already computes.

14. This requires a metadata extension before segmentation can safely proceed.

Candidate strategy evaluation:

A. Matched-line-only unit

   Deterministic: yes.
   Exact provenance: yes for one source line.
   Structural context: weak.
   Semantic judgment: none.

   Determination:
   too lossy as the general repository-wide segmentation primitive.

B. Individual source-line units

   Deterministic: yes.
   Exact provenance: possible with retained source coordinates.
   Structural context: weak.
   Semantic judgment: none.

   Determination:
   risks separating multiline TypeScript/JavaScript expressions, Markdown
   structures, JSON objects, SQL statements, CSS rules, and other meaningful
   repository structures.

C. Blank-line-delimited contiguous blocks

   Deterministic: yes when exact bounded source lines are available.
   Exact provenance: yes when source coordinates are retained.
   Structural context: stronger than line-only segmentation.
   Semantic judgment: none.

   Current blocker:
   trim() and possible character truncation prevent exact original range and
   boundary reconstruction from the materialized excerpt alone.

   Determination:
   plausible successor strategy, but not ready under the current excerpt
   contract.

D. Fixed-size contiguous line windows

   Deterministic: yes.
   Exact provenance: possible with source-range metadata.
   Structural context: arbitrary.
   Semantic judgment: none.

   Determination:
   limited additional value because current retrieval already constructs a
   fixed bounded neighborhood around the matched line.

E. Syntax-aware units by file type

   Deterministic: potentially.
   Exact provenance: potentially strong.
   Structural context: strong.
   Semantic judgment: not inherently required.

   Determination:
   architecturally premature because it requires format-specific parsing and a
   substantially larger implementation surface.

F. Require exact bounded-excerpt range metadata before segmentation

   Deterministic: yes.
   Exact provenance: preserved.
   Semantic judgment: none.
   Implementation surface: metadata only at the bounded-excerpt construction
   seam.

   Determination:
   smallest prerequisite supported by current repository evidence.

15. Blank-line segmentation remains the strongest small repository-wide
    segmentation candidate identified so far, but its algorithm contract cannot
    yet be declared ready because exact range provenance is missing.

16. Fixed-size windows do not solve the mixed-content problem more cleanly than
    the current bounded retrieval window.

17. Syntax-aware segmentation is not justified before a smaller deterministic
    strategy has been investigated.

18. The segmenter should not operate solely on already-materialized excerpt
    text.

19. The segmenter should eventually operate on source content whose exact
    bounded source range is known.

20. readBoundedExcerpt(...) already computes the required start/end range before
    transforming the source into the public excerpt string.

21. Therefore the smallest prerequisite is to preserve that already-known range
    as internal metadata.

22. This metadata extension must preserve the existing public
    MatildaProjectContextExcerpt contract and existing retrieval behavior.

23. It must not alter:

    - query extraction;
    - git-grep matching;
    - candidate scoring;
    - candidatesByPath behavior;
    - selectedCandidates behavior;
    - MAX_MATCHES;
    - bounded excerpt text;
    - supportSourceReferences;
    - Evidence Composition;
    - Ollama response schema.

24. If the exact same excerpt text and retrieval candidates are returned and the
    only new information is internally retained source-range metadata, this is a
    metadata-only extension rather than a semantic retrieval behavior change.

25. That metadata contract must remain internal until a later corridor
    explicitly establishes whether and how segmented units participate in
    semantic admission.

26. No segmentation algorithm should be implemented before this prerequisite is
    validated.

27. Semantic admission remains unresolved and separate.

28. Boundary Composition remains closed at its established context-selection
    dependency.

29. The architectural sequence remains:

    retrieval
      -> bounded source evidence with exact internal range metadata
      -> deterministic candidate segmentation
      -> semantic admission/detail selection
      -> single semantic reply composition

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION

Purpose:

Determine the smallest metadata-only internal extension at the bounded-excerpt
construction seam that preserves the exact already-computed source range without
changing retrieval behavior or any external evidence/provenance contract.

The investigation must determine:

- where startLineNumber and endLineNumber should live;
- whether line numbers should be represented as inclusive source coordinates;
- how MAX_EXCERPT_CHARACTERS truncation must be represented if the final
  character slice ends inside a source line;
- whether exact range metadata alone is sufficient or whether truncation state
  is also required;
- how to prove the extension leaves current MatildaProjectContextExcerpt text,
  ranking, candidate admission, support provenance, and Evidence Composition
  unchanged.

Do not implement the metadata extension yet.
Do not implement segmentation.
Do not implement semantic admission.
Do not modify project-context retrieval behavior.
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
echo "ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_REQUIRED"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION"
