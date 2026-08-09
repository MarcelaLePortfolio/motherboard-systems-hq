#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL SELECTION — INVESTIGATION OPEN ==="

echo
echo "=== PROTECTED BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "DR CHECKPOINT: 20260808_231729"

echo
echo "=== BOUNDARY COMPOSITION HANDOFF ==="
cat scripts/document-boundary-composition-context-selection-block.sh

echo
echo "=== PROJECT CONTEXT RETRIEVAL ==="
sed -n '1,320p' server/matilda-project-context-retrieval.ts

echo
echo "=== CONTEXT COMPOSITION ==="
sed -n '1,320p' server/matilda-conversation-context-runtime.ts

echo
echo "=== RESPONSE COMPOSITION CONTRACT ==="
sed -n '500,545p' scripts/utils/ollamaChat.ts

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Adaptive Detail Selection is now opened for investigation only.

Boundary Composition established the successor dependency:

A retrieved project-context excerpt can be relevant at excerpt granularity while
containing colocated semantic detail that is immaterial to the user's immediate
request.

Do not implement yet.

Investigate current repository behavior and determine:

1. What does Adaptive Detail Selection need to own?

2. Distinguish clearly between:
   - project-context retrieval;
   - excerpt ranking;
   - excerpt segmentation;
   - semantic admission;
   - response-detail selection;
   - prompt composition;
   - post-generation filtering.

3. Which of those capabilities already exist?

4. At what granularity does current project-context retrieval operate?

5. Does the repository preserve any line-level, sentence-level, block-level, or
   semantic-unit metadata that could support finer admission without inventing
   new semantic authority?

6. Is the mixed-excerpt problem fundamentally:
   a. retrieval-window granularity;
   b. excerpt segmentation;
   c. semantic relevance classification;
   d. response composition behavior;
   e. a combination?

7. Can a deterministic segmentation step safely reduce colocated material
   without deciding semantic relevance?

8. If segmentation alone is insufficient, what component must own the semantic
   relevance decision while preserving Matilda as Interpretation Authority?

9. Can that decision remain within the existing single Ollama invocation?

10. Would asking Matilda to select among pre-segmented candidate units inside the
    same structured invocation preserve:
    - one semantic author;
    - one invocation;
    - current support provenance;
    - Evidence Composition ownership?

11. Would using supportSourceReferences as post-hoc selection be architecturally
    circular because they are produced with the reply rather than before it?

12. What is the smallest safe next unit:
    - retrieval-granularity investigation;
    - deterministic segmentation investigation;
    - semantic admission contract investigation;
    - structured candidate-selection investigation;
    - or no implementation readiness yet?

Return exactly one classification:

ADAPTIVE_DETAIL_RETRIEVAL_GRANULARITY_INVESTIGATION_READY
ADAPTIVE_DETAIL_SEGMENTATION_INVESTIGATION_READY
ADAPTIVE_DETAIL_SEMANTIC_ADMISSION_INVESTIGATION_READY
ADAPTIVE_DETAIL_STRUCTURED_SELECTION_INVESTIGATION_READY
ADAPTIVE_DETAIL_NOT_READY

Then identify exactly one smallest next unit.

Do not implement.
Do not modify project-context retrieval.
Do not add another model invocation.
Do not perform post-model semantic filtering.
Do not alter Evidence Composition semantics.
Do not reopen Boundary Composition.
Preserve one user message -> one workflow -> one Ollama invocation.
QUESTION

echo
echo "=== DIFF CHECK ==="
git diff --check
