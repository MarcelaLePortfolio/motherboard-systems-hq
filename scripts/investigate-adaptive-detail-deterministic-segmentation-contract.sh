#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — DETERMINISTIC SEGMENTATION CONTRACT INVESTIGATION ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "PROTECTED DR: 20260808_231729"

if [[ "$(git rev-parse --short HEAD)" != "9434d878" ]]; then
  echo "STOP: HEAD no longer matches validated range-metadata checkpoint 9434d878."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-deterministic-segmentation-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CURRENT BOUNDED EXCERPT IMPLEMENTATION ==="
sed -n '150,215p' server/matilda-project-context-retrieval.ts

echo
echo "=== CURRENT RETRIEVAL ASSEMBLY ==="
sed -n '325,375p' server/matilda-project-context-retrieval.ts

echo
echo "=== RANGE METADATA VALIDATION ==="
sed -n '1,180p' \
  server/matilda-project-context-retrieval.range-metadata.test.ts

echo
echo "=== EXISTING SEGMENTATION INVESTIGATION RECORD ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'blank-line|segmentation|segment|matched-line-only|fixed window|syntax-aware|sourceStartLine|sourceEndLine|excerptTruncated' \
  scripts/document-adaptive-detail-* \
  scripts/inspect-adaptive-detail-* \
  2>/dev/null | head -n 260 || true

echo
echo "=== REPOSITORY CONTENT SHAPES ==="
find server db scripts docs \
  -type f \
  \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' \
     -o -name '*.md' -o -name '*.json' -o -name '*.sql' \
     -o -name '*.css' \) \
  2>/dev/null | \
  sed 's/.*\.//' | \
  sort | uniq -c | sort -nr

echo
echo "=== CONTRACT QUESTIONS ==="
cat <<'QUESTIONS'
Determine from repository evidence only:

1. What is the smallest deterministic segmentation algorithm that can operate
   across the repository's mixed source formats without semantic judgment?

2. Reassess the previously strongest candidate:
   blank-line-delimited blocks.

3. Determine whether blank-line segmentation can preserve contiguous exact
   source provenance using the validated bounded source range metadata.

4. Determine how trim() affects blank-line boundaries at the beginning and end
   of the bounded source window.

5. Determine how excerptTruncated=true affects segmentation safety.

6. Specifically determine whether a character-truncated final block must:
   - be admitted as a candidate segment with truncation metadata;
   - be excluded from segmentation;
   - or require a later refinement before use.

7. Determine whether segmentation must operate on:
   - the materialized excerpt string;
   - the original bounded lines before trim/truncation;
   - or a deterministic internal representation retained by
     readBoundedExcerpt(...).

8. Determine whether exact segment provenance can be represented with the
   already-established internal contract:

   {
     relativePath,
     matchedLineNumber,
     startLineNumber,
     endLineNumber
   }

9. Determine whether a segment needs any additional identity beyond:
   relativePath + startLineNumber + endLineNumber.

10. Determine whether segmentation can remain entirely pre-semantic and
    deterministic, with no relevance/materiality decision.

11. Identify the exact boundary between:
    - deterministic candidate segmentation;
    - later semantic admission/detail selection.

12. Determine the smallest safe implementation surface if segmentation is
    repository-ready.

13. Identify tests that would prove:
    - no change to retrieval ranking;
    - no change to MAX_MATCHES;
    - no change to existing MatildaProjectContextExcerpt output;
    - deterministic segment ordering;
    - exact source range preservation;
    - no semantic filtering;
    - no Ollama schema or invocation changes.

Do not implement segmentation in this unit.

Do not implement semantic admission.

Do not modify query extraction, ranking, MAX_MATCHES, or candidate selection.

Do not modify MatildaProjectContextExcerpt.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not expose segmentation metadata to Ollama.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not reopen Boundary Composition.
QUESTIONS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_CONTRACT_INVESTIGATION_COMPLETE"
echo "NO_SEGMENTATION_IMPLEMENTATION_STARTED"
