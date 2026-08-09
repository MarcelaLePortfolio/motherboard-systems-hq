#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENTATION ALGORITHM CONTRACT INVESTIGATION ==="

echo
echo "=== CURRENT PROJECT-CONTEXT CONTRACT ==="
sed -n '1,260p' server/matilda-project-context-retrieval.ts

echo
echo "=== CURRENT EXCERPT CONSTRUCTION ==="
grep -n -A45 -B10 \
  'function readBoundedExcerpt' \
  server/matilda-project-context-retrieval.ts || true

echo
echo "=== PROJECT-CONTEXT TYPES AND CONSUMERS ==="
grep -R -n -E \
  'MatildaProjectContextExcerpt|projectContextExcerpts|readBoundedExcerpt|MAX_EXCERPT_CHARACTERS|MAX_MATCHES' \
  server scripts \
  --exclude-dir=node_modules \
  --exclude='inspect-adaptive-detail-segmentation-algorithm-contract.sh' \
  | head -n 500 || true

echo
echo "=== REPOSITORY FILE-TYPE SURFACE ==="
git ls-files | \
  awk '
    {
      n=split($0,a,".");
      if (n > 1) {
        ext=a[n];
        count[ext]++;
      } else {
        count["[no-extension]"]++;
      }
    }
    END {
      for (ext in count) {
        print count[ext], ext;
      }
    }
  ' | sort -nr | head -n 80

echo
echo "=== BLANK-LINE / BLOCK STRUCTURE SAMPLES ==="
for file in \
  server/matilda-project-context-retrieval.ts \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
do
  echo
  echo "--- $file ---"
  sed -n '1,180p' "$file" | nl -ba | head -n 180
done

echo
echo "=== EXISTING SEGMENT / BLOCK / RANGE UTILITIES ==="
grep -R -n -E \
  'segment|segmentation|split.*block|split.*paragraph|startLineNumber|endLineNumber|matchedLineNumber|source range|sourceRange' \
  server scripts src \
  --exclude-dir=node_modules \
  --exclude='inspect-adaptive-detail-segmentation-algorithm-contract.sh' \
  | head -n 500 || true

echo
echo "=== ESTABLISHED PROVENANCE CONTRACT ==="
sed -n '1,430p' \
  scripts/document-adaptive-detail-segment-provenance-contract.sh

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'REQUEST'
Adaptive Detail Selection established:

ADAPTIVE_DETAIL_INTERNAL_SEGMENT_IDENTITY_READY

Established internal provenance contract:

{
  relativePath,
  matchedLineNumber,
  startLineNumber,
  endLineNumber
}

Investigate only the deterministic segmentation algorithm contract required
before segmentation can be implemented.

Do not implement.

Determine from repository evidence:

1. What exact source material is available to a deterministic segmentation
   stage after current bounded project-context retrieval?

2. Can exact source ranges be reconstructed from the current excerpt string
   alone?

3. How do trim() and MAX_EXCERPT_CHARACTERS truncation affect reconstruction of:
   - original start line;
   - original end line;
   - blank-line boundaries;
   - partial final lines?

4. Does a safe deterministic segmenter require access to:
   - the excerpt string only;
   - the original source file plus matchedLineNumber;
   - explicit range metadata produced during bounded excerpt construction;
   - some other deterministic input?

5. Evaluate these candidate segmentation strategies:

A. Matched-line-only unit.

B. Individual source-line units.

C. Blank-line-delimited contiguous blocks.

D. Fixed-size contiguous line windows.

E. Syntax-aware units by file type.

F. No segmentation until bounded excerpt construction itself exposes exact
   range metadata.

6. For each strategy determine:
   - deterministic behavior;
   - exact provenance capability;
   - preservation of local structural context;
   - behavior across TypeScript/JavaScript;
   - behavior across Markdown/text;
   - behavior across JSON;
   - behavior across SQL/CSS/other repository formats;
   - risk of splitting a meaningful structure;
   - whether semantic relevance judgment is introduced;
   - implementation surface required.

7. Determine whether blank-line-delimited blocks are sufficiently safe as the
   smallest repository-wide primitive, or whether current excerpt construction
   prevents exact provenance.

8. Determine whether fixed-size line windows add anything useful beyond the
   current bounded excerpt behavior.

9. Determine whether syntax-aware segmentation is justified by current evidence
   or is architecturally premature.

10. Determine whether the segmenter should operate:
    - on already-materialized excerpt text;
    - on source lines and exact bounded range metadata;
    - or at another deterministic seam.

11. Determine whether current readBoundedExcerpt(...) must eventually expose
    exact start/end range metadata before segmentation can safely proceed.

12. Determine whether doing so would constitute:
    - a metadata-only extension preserving retrieval semantics; or
    - a change to project-context retrieval behavior.

13. Preserve the established separation:

    retrieval
      -> bounded source evidence
      -> deterministic candidate segmentation
      -> semantic admission/detail selection
      -> single semantic reply composition

14. Do not design semantic admission in this investigation.

Return exactly one classification:

ADAPTIVE_DETAIL_BLANK_LINE_SEGMENTATION_CONTRACT_READY
ADAPTIVE_DETAIL_RANGE_AWARE_SEGMENTATION_CONTRACT_READY
ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_REQUIRED
ADAPTIVE_DETAIL_SEGMENTATION_ALGORITHM_NOT_READY

Then identify exactly one smallest next unit.

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
REQUEST

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
