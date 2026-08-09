#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — SEGMENTATION SEAM INVESTIGATION ==="

echo
echo "=== CURRENT RETRIEVAL GRANULARITY ==="
rg -n -C 10 \
'readBoundedExcerpt|MAX_EXCERPT_CHARACTERS|lineNumber|selectedCandidates|excerpts' \
server/matilda-project-context-retrieval.ts

echo
echo "=== CURRENT CONTEXT SHAPE ==="
rg -n -C 8 \
'MatildaProjectContextExcerpt|projectContextExcerpts|projectContextEvidence' \
server/matilda-project-context-retrieval.ts \
server/matilda-conversation-context-runtime.ts \
scripts/utils/ollamaChat.ts

echo
echo "=== EXISTING SEGMENTATION / CHUNKING UTILITIES ==="
rg -n -C 6 \
'segment|segmentation|chunk|sentence|paragraph|block|split.*line|split.*paragraph|semantic unit|excerpt unit' \
server \
scripts \
src \
db \
--glob='*.ts' \
--glob='*.tsx' \
--glob='*.js' \
| head -n 420 || true

echo
echo "=== RETRIEVAL TEST COVERAGE ==="
cat server/matilda-project-context-retrieval.test.ts

echo
echo "=== ESTABLISHED ADAPTIVE DETAIL PROBLEM ==="
cat <<'PROBLEM'
Current repository state establishes:

1. Project-context retrieval is query-driven.

2. Candidate files/lines are scored and ranked before selection.

3. Each selected candidate retains an exact matched lineNumber.

4. readBoundedExcerpt(...) then expands that matched location into a bounded
   multi-line excerpt:

   start = lineNumber - 3
   end   = lineNumber + 2

5. Conversation Context preserves the resulting excerpt unchanged.

6. Ollama therefore receives the full bounded excerpt, not merely the matched
   line or a set of separately identified semantic units.

7. Boundary Composition behavioral validation demonstrated the consequence:
   an excerpt containing both:
     - a directly relevant test-verification statement; and
     - an unrelated deferred UI statement
   caused Matilda to surface both.

8. Prompt-only omission did not reliably solve that problem.

9. Boundary Composition correctly stopped rather than absorbing context-
   selection ownership.

Adaptive Detail Selection is now investigating the upstream granularity problem.
PROBLEM

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Investigate deterministic segmentation only.

Do not implement.

Determine from repository evidence:

1. What exact unit is currently selected by project-context retrieval?
   Distinguish:
   - matched line;
   - ranked candidate;
   - bounded excerpt;
   - file-level candidate.

2. Does the repository retain enough deterministic provenance to split a bounded
   excerpt into smaller candidate units while preserving:
   - relativePath;
   - exact source line numbers;
   - exact source text;
   - provenance;
   - authorityStatus?

3. Which deterministic segmentation strategies are technically possible without
   making a semantic relevance decision?

Evaluate at minimum:

A. matched-line-only units;
B. individual source-line units;
C. blank-line paragraph/block units;
D. syntax-aware units;
E. sentence units.

4. For each strategy, distinguish:
   - deterministic segmentation;
   - semantic interpretation;
   - provenance precision;
   - risk of destroying necessary context.

5. Would matched-line-only segmentation be too lossy for repository evidence
   whose meaning depends on nearby lines?

6. Would sentence segmentation be unsafe or ambiguous for source code, JSON,
   SQL, CSS, markdown lists, and multiline TypeScript constructs?

7. Would blank-line block segmentation preserve more structural context without
   requiring semantic judgment?

8. Is there already enough metadata to assign exact beginning/end line numbers
   to segmented units, or would the current MatildaProjectContextExcerpt shape
   need extension?

9. Could deterministic segmentation occur after retrieval but before
   composeMatildaConversationContext(...) without changing:
   - query extraction;
   - ranking;
   - MAX_MATCHES behavior;
   - semantic relevance ownership?

10. Would segmentation alone solve Adaptive Detail Selection?

11. Or would segmentation merely create finer candidate units that still require
    Matilda to decide which units are materially relevant?

12. If a later semantic selection decision is required, can segmentation be
    established as a separate deterministic prerequisite without prematurely
    designing that semantic contract?

Return exactly one classification:

ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_READY
ADAPTIVE_DETAIL_SEGMENTATION_NEEDS_METADATA_EXTENSION
ADAPTIVE_DETAIL_SEGMENTATION_INSUFFICIENT_WITHOUT_SEMANTIC_ADMISSION
ADAPTIVE_DETAIL_SEGMENTATION_NOT_SAFE
ADAPTIVE_DETAIL_NOT_READY

Then identify exactly one smallest next unit.

Do not implement.
Do not modify project-context retrieval.
Do not change MAX_MATCHES.
Do not change ranking.
Do not add semantic admission yet.
Do not add another model invocation.
Do not alter supportSourceReferences.
Do not alter Evidence Composition.
Do not perform post-model filtering.
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
