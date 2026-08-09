#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — PROMPT + SELECTED CONTEXT SEGMENTS CONTRACT INVESTIGATION ==="

if [[ "$(git rev-parse --short HEAD)" != "acc4c7db" ]]; then
  echo "STOP: HEAD no longer matches validated candidate-context checkpoint acc4c7db."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-prompt-and-selection-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CURRENT CANDIDATE CONTEXT TYPES ==="
grep -n -A80 -B20 \
  -E 'MatildaProjectContextSegmentCandidate|projectContextSegmentCandidates|OllamaChatProjectContextSegmentCandidate' \
  server/matilda-project-context-retrieval.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT OLLAMA RESPONSE SCHEMA ==="
sed -n '1,220p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT PROMPT SERIALIZATION ==="
sed -n '410,555p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT RESPONSE VALIDATION ==="
sed -n '175,405p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SUPPORT PROVENANCE VALIDATION ==="
sed -n '555,735p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED CONTRACT TEST SURFACE ==="
find scripts/utils \
  -type f \
  -name 'ollamaChat*.test.ts' \
  -print | sort

cat <<'QUESTIONS'

Established state:

1. projectContextSegmentCandidates now travels deterministically through:

   retrieval
   -> Conversation Context
   -> workflow
   -> OllamaChatContext

2. It is not serialized into the prompt.

3. It is not part of the structured output schema.

4. selectedContextSegments is not implemented.

5. Parent projectContextExcerpts remain the established support-provenance and
   Evidence Composition universe.

6. Child segment candidates are ephemeral and non-persistent.

7. Matilda must remain the sole semantic materiality authority.

Investigate and determine:

1. What is the smallest prompt representation for
   projectContextSegmentCandidates?

2. Determine whether candidate serialization should include exactly:

   Segment source: relativePath:start-end
   Authority status: candidate_evidence_not_authority
   text

3. Determine whether provenance must also be repeated in the prompt.

4. Determine whether parent projectContextExcerpts and child segment candidates
   can both be serialized without creating harmful semantic duplication.

5. Determine whether the prompt should explicitly distinguish:

   parent excerpts:
     support-provenance evidence universe

   child segment candidates:
     semantic-materiality selection universe

6. Determine whether Matilda should be instructed to use child candidate text
   for response-detail materiality while retaining parent excerpts only for
   existing supportSourceReferences identity.

7. Determine whether this division is understandable enough for one invocation
   without introducing contradictory instructions.

8. Determine the exact structured output field:

   selectedContextSegments

9. Determine the minimum schema for one selection:

   {
     relativePath: string;
     sourceStartLine: integer >= 1;
     sourceEndLine: integer >= 1;
   }

10. Confirm that selectedContextSegments should be a required array rather than
    optional or nullable.

11. Confirm that [] is valid when:

    - no candidates were supplied;
    - all candidates are immaterial;
    - project context is unnecessary.

12. Determine whether malformed selectedContextSegments should fail closed.

13. Determine whether a selected range not exactly present in supplied candidate
    identities should fail closed.

14. Determine whether duplicate valid identities should be deterministically
    deduplicated.

15. Determine whether selectedContextSegments should remain internal to
    ollamaChat or become part of OllamaChatResult.

16. Identify whether any current workflow consumer needs selectedContextSegments.

17. If no current consumer needs it, determine whether ollamaChat should validate
    it and then discard it after reply composition.

18. Determine whether discarding it would prevent later behavioral validation of
    Adaptive Detail Selection.

19. Determine whether temporarily returning it in OllamaChatResult for tests
    would unnecessarily widen the runtime contract.

20. Determine the smallest observable seam needed to verify that Matilda selected
    a candidate during live behavioral validation.

21. Determine whether semantic admission and reply must be contractually related
    by prompt language such as:

    Compose reply using only project-context segment candidates you identify as
    materially relevant in selectedContextSegments.

22. Determine whether Matilda may use conversation history independently of
    selectedContextSegments.

23. Determine whether parent projectContextExcerpts can still support
    supportSourceReferences even when their child segment is not selected.

24. Determine whether that would contradict semantic admission.

25. Determine whether supportSourceReferences for project context should be
    constrained to parent excerpts containing at least one selected child
    segment.

26. If such a constraint would alter Evidence Composition semantics, do not
    adopt it without a separate reconciliation.

27. Determine whether selectedContextSegments requires persistence.

28. Determine whether selectedContextSegments should appear in IEL evidence
    traces.

29. Determine whether introducing the field changes:

    - one model invocation;
    - reply authorship;
    - durableInterpretation authorship;
    - support provenance;
    - evidenceSufficient;
    - Evidence Composition.

30. Identify the smallest implementation-ready unit.

Return exactly one classification:

ADAPTIVE_DETAIL_PROMPT_AND_SELECTION_CONTRACT_READY
ADAPTIVE_DETAIL_PROMPT_NEEDS_DUPLICATION_RECONCILIATION
ADAPTIVE_DETAIL_SELECTION_NEEDS_SUPPORT_RECONCILIATION
ADAPTIVE_DETAIL_SELECTION_NEEDS_OBSERVABILITY_CONTRACT
ADAPTIVE_DETAIL_PROMPT_AND_SELECTION_NOT_READY

Then identify exactly one next unit.

Do not implement prompt serialization.

Do not modify the structured response schema.

Do not implement selectedContextSegments.

Do not modify OllamaChatResult.

Do not modify supportSourceReferences.

Do not modify evidenceSufficient.

Do not modify Evidence Composition.

Do not persist segment selection.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.

Preserve one user message -> one workflow -> one Ollama invocation.
QUESTIONS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PROMPT_AND_SELECTION_CONTRACT_INVESTIGATION_COMPLETE"
echo "IMPLEMENTATION_NOT_STARTED"
