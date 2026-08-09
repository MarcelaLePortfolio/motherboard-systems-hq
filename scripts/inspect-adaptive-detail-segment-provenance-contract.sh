#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENT PROVENANCE CONTRACT ==="

echo
echo "=== CURRENT PROJECT CONTEXT TYPES ==="
sed -n '44,68p' server/matilda-project-context-retrieval.ts

echo
echo "=== CURRENT EXCERPT CONSTRUCTION ==="
sed -n '158,185p' server/matilda-project-context-retrieval.ts
sed -n '329,352p' server/matilda-project-context-retrieval.ts

echo
echo "=== SUPPORT SOURCE TYPES ==="
rg -n -C 8 \
'MatildaSupportSourceReference|project_context_excerpt|relativePath|lineNumber' \
scripts/utils/ollamaChat.ts \
server \
--glob='*.ts' \
| head -n 420

echo
echo "=== EVIDENCE SOURCE IDENTITY ==="
sed -n '570,705p' scripts/utils/ollamaChat.ts

echo
echo "=== EXISTING RANGE / LOCATION METADATA ==="
rg -n -C 5 \
'startLine|endLine|start_line|end_line|lineStart|lineEnd|range|sourceRange|sourceLocation|location' \
server \
scripts \
db \
src \
--glob='*.ts' \
--glob='*.tsx' \
| head -n 420 || true

echo
echo "=== ESTABLISHED SEGMENTATION FINDING ==="
cat scripts/document-adaptive-detail-segmentation-findings.sh

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Adaptive Detail Selection established:

ADAPTIVE_DETAIL_SEGMENTATION_NEEDS_METADATA_EXTENSION

Investigate only the deterministic provenance/identity contract required before
segmentation can be implemented.

Do not implement.

Determine from repository evidence:

1. What semantic meaning does the current project-context identity:

   relativePath + lineNumber

   actually carry?

2. Is lineNumber currently:
   - the git-grep matched line;
   - the first line of the bounded excerpt;
   - a general source anchor;
   - or something else?

3. Do supportSourceReferences require that identity to remain exactly stable?

4. Does Evidence Composition use the same identity for:
   - membership validation;
   - deduplication;
   - exact excerpt lookup;
   - Source-Excerpt presentation?

5. If one bounded excerpt is deterministically split into multiple candidate
   units, can those units safely share the same:

   relativePath + lineNumber

   identity?

6. Would shared identity make any of these ambiguous:
   - support-reference membership;
   - evidence lookup;
   - deduplication;
   - exact source attribution?

7. Evaluate candidate provenance contracts:

A.
{
  relativePath,
  lineNumber
}

B.
{
  relativePath,
  startLineNumber,
  endLineNumber
}

C.
{
  relativePath,
  matchedLineNumber,
  startLineNumber,
  endLineNumber
}

D.
{
  relativePath,
  matchedLineNumber,
  startLineNumber,
  endLineNumber,
  deterministicUnitId
}

8. For each candidate, determine:
   - whether source identity is unambiguous;
   - whether matched-line lineage is preserved;
   - whether exact source-range attribution is possible;
   - whether multiple segments from one original excerpt can coexist;
   - whether existing supportSourceReferences semantics would have to change.

9. Is a deterministicUnitId necessary, or can:

   relativePath + startLineNumber + endLineNumber

   provide sufficient deterministic identity?

10. Could exact range metadata be introduced on an internal segmented-candidate
    type while preserving the existing external/current
    MatildaProjectContextExcerpt contract until semantic admission is designed?

11. Would that separation allow segmentation investigation to proceed without
    changing:
    - supportSourceReferences;
    - Evidence Composition;
    - Ollama response schema;
    - project-context retrieval behavior?

12. What is the smallest safe contract to establish now?

Return exactly one classification:

ADAPTIVE_DETAIL_RANGE_PROVENANCE_CONTRACT_READY
ADAPTIVE_DETAIL_INTERNAL_SEGMENT_IDENTITY_READY
ADAPTIVE_DETAIL_SUPPORT_REFERENCE_EXTENSION_REQUIRED
ADAPTIVE_DETAIL_PROVENANCE_CONTRACT_NOT_READY

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
Preserve one user message -> one workflow -> one Ollama invocation.
QUESTION

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
