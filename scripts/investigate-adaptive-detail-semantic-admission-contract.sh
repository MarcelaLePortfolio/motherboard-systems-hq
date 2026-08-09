#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SEMANTIC ADMISSION CONTRACT INVESTIGATION ==="

if [[ "$(git rev-parse --short HEAD)" != "f157f8ba" ]]; then
  echo "STOP: HEAD no longer matches validated segmentation checkpoint f157f8ba."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-semantic-admission-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "PROTECTED DR: 20260808_231729"

echo
echo "=== SEGMENTATION PRIMITIVE ==="
grep -n -A90 -B12 \
  'function segmentBoundedProjectContextSource' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== PROJECT-CONTEXT PUBLIC CONTRACT ==="
sed -n '45,80p' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== RETRIEVAL ASSEMBLY ==="
grep -n -A65 -B20 \
  'excerpts.push' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== CONVERSATION CONTEXT OWNERSHIP ==="
sed -n '1,150p' \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== WORKFLOW COMPOSITION SEAM ==="
grep -n -A90 -B35 \
  'ollamaChat' \
  server/matilda-chat-workflow.ts

echo
echo "=== OLLAMA CONTEXT CONTRACT ==="
grep -n -A90 -B25 \
  'projectContextExcerpts' \
  scripts/utils/ollamaChat.ts | head -n 240

echo
echo "=== SUPPORT / EVIDENCE OWNERSHIP ==="
grep -n -A120 -B30 \
  'supportSourceReferences' \
  scripts/utils/ollamaChat.ts | head -n 320

echo
echo "=== EXISTING ADMISSION PRECEDENTS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'selectedHistory|evaluatedInterpretations|contaminationEvaluations|authorityStatus|eligible|admission' \
  server scripts db \
  | grep -vE \
    'document-|inspect-|investigate-|implement-|validate-' \
  | head -n 320 || true

cat <<'FINDINGS'

=== INVESTIGATION QUESTIONS ===

Established state:

1. Deterministic blank-line segmentation is implemented and validated.

2. Segment candidates preserve exact structural content and source ranges.

3. Segmentation performs no semantic relevance or materiality judgment.

4. Segment candidates remain inert.

5. MatildaConversationContext does not expose segment candidates.

6. Ollama does not receive segment candidates.

7. supportSourceReferences semantics remain unchanged.

8. Evidence Composition remains unchanged.

9. Boundary Composition remains blocked only by the unresolved context-selection
   dependency.

10. One user message -> one workflow -> one Ollama invocation remains preserved.

Investigate repository evidence and determine:

1. Which layer can legitimately decide whether a deterministic project-context
   segment materially affects the immediate response?

Evaluate separately:

   A. deterministic workflow code;
   B. project-context retrieval/ranking;
   C. Conversation Context Runtime;
   D. Matilda inside the existing Ollama invocation;
   E. a second semantic invocation;
   F. post-model semantic filtering.

2. Which candidates preserve:

   User = Intent Authority
   Matilda = Interpretation Authority

3. Can deterministic workflow code classify semantic materiality without
   becoming an interpretation authority?

4. Can existing retrieval ranking solve segment-level response materiality, or
   does it own only retrieval relevance?

5. Can Conversation Context Runtime own semantic admission without introducing
   a new semantic evaluator?

6. Can Matilda own segment-level materiality inside the existing single
   invocation while remaining the sole semantic author?

7. If Matilda owns admission, determine whether all deterministic segment
   candidates can be supplied as bounded candidate context while Matilda is
   instructed to use only materially relevant candidates.

8. Determine whether merely supplying all candidates would recreate the
   mixed-context problem unless admission is represented explicitly.

9. Evaluate whether any existing structured artifact can represent semantic
   admission without changing its established meaning:

   - supportSourceReferences;
   - evidence;
   - evidenceSufficient;
   - explanationStatus;
   - durableInterpretation.

10. Determine whether supportSourceReferences are strictly post-semantic support
    provenance rather than pre-reply context admission.

11. Determine whether reusing supportSourceReferences for segment admission
    would overload or redefine Evidence Composition.

12. If existing artifacts cannot own admission, determine whether a new internal
    structured artifact is architecturally justified.

13. Evaluate a possible model-authored artifact such as:

    selectedContextSegments
    or
    admittedDetailReferences

14. If such an artifact is justified, determine whether it should:

    - contain only deterministic segment identities;
    - be authored by Matilda in the existing invocation;
    - be validated deterministically against supplied candidates;
    - remain internal to response composition;
    - remain non-persistent unless separately authorized.

15. Determine whether deterministic validation of model-selected identities
    preserves Matilda's semantic authority because workflow code validates only
    provenance and membership, not relevance.

16. Determine whether this can preserve:

    one user message
      -> one workflow
      -> one Ollama invocation
      -> one reply
      -> one durableInterpretation

17. Determine whether reply and durableInterpretation remain independently
    Matilda-authored.

18. Determine the relationship between semantic admission and closed Evidence
    Composition.

19. Do not assume the Boundary Composition mixed-excerpt failure automatically
    proves a new artifact is necessary. Determine whether repository evidence
    supports that conclusion.

20. Identify the smallest safe successor unit.

Return exactly one classification:

ADAPTIVE_DETAIL_MODEL_OWNED_ADMISSION_CONTRACT_READY
ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_INVESTIGATION_READY
ADAPTIVE_DETAIL_EXISTING_SUPPORT_PROVENANCE_CAN_OWN_ADMISSION
ADAPTIVE_DETAIL_DETERMINISTIC_ADMISSION_READY
ADAPTIVE_DETAIL_SEMANTIC_ADMISSION_NOT_READY

Then identify exactly one smallest next unit.

Do not implement semantic admission.

Do not expose segments to Ollama in this investigation.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

Do not modify MatildaProjectContextExcerpt.

Do not modify supportSourceReferences.

Do not modify evidenceSufficient.

Do not modify Evidence Composition.

Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.

Preserve one user message -> one workflow -> one Ollama invocation.
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEMANTIC_ADMISSION_CONTRACT_INVESTIGATION_COMPLETE"
echo "SEMANTIC_ADMISSION_IMPLEMENTATION_NOT_STARTED"
