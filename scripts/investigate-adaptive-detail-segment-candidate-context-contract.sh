#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SEGMENT CANDIDATE CONTEXT CONTRACT INVESTIGATION ==="

if [[ "$(git rev-parse --short HEAD)" != "b8b932b1" ]]; then
  echo "STOP: HEAD no longer matches candidate-context investigation baseline b8b932b1."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-segment-candidate-context-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== RETRIEVAL TYPES / SEGMENTATION ==="
grep -n -A220 -B30 \
  -E 'MatildaProjectContextExcerpt|BoundedExcerpt|Segment|segment|readBoundedExcerpt|projectContextExcerpts|excerpts.push' \
  server/matilda-project-context-retrieval.ts \
  | head -n 700

echo
echo "=== SEGMENTATION CONTRACT TEST ==="
sed -n '1,360p' \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== RANGE METADATA CONTRACT TEST ==="
sed -n '1,320p' \
  server/matilda-project-context-retrieval.range-metadata.test.ts

echo
echo "=== CONVERSATION CONTEXT CONTRACT ==="
grep -n -A220 -B40 \
  -E 'MatildaConversationContext|projectContextExcerpts|composeMatildaConversationContext|projectContextRetrieval' \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-conversation-context-runtime.test.ts \
  | head -n 700

echo
echo "=== WORKFLOW RETRIEVAL / CONTEXT / OLLAMA FLOW ==="
grep -n -A180 -B80 \
  -E 'projectContextRetrieval|composeMatildaConversationContext|projectContextExcerpts|ollamaChat' \
  server/matilda-chat-workflow.ts \
  | head -n 600

echo
echo "=== OLLAMA CONTEXT CONTRACT ==="
grep -n -A100 -B20 \
  -E 'OllamaChatContext|OllamaChatProjectContextExcerpt|projectContextExcerpts|projectContextEvidence' \
  scripts/utils/ollamaChat.ts \
  | head -n 500

echo
echo "=== RELEVANT CALL SITES ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'composeMatildaConversationContext\(|ollamaChat\(|projectContextExcerpts:' \
  server scripts db \
  | head -n 500

echo
echo "=== INVESTIGATION QUESTIONS ==="

cat <<'QUESTIONS'
Established constraints:

1. Deterministic segment candidates already exist internally.

2. Segmentation does not decide semantic relevance.

3. selectedContextSegments is the supported semantic-admission artifact name,
   but it must not be implemented until an authoritative supplied candidate
   universe exists.

4. The minimum selected segment identity is:

   relativePath
   sourceStartLine
   sourceEndLine

5. Model-authored selectedContextSegments must not contain reconstructed source
   text.

6. Candidate context must contain exact text because Matilda requires semantic
   content to judge materiality.

7. MatildaProjectContextExcerpt must remain unchanged.

8. supportSourceReferences remains excerpt-level support provenance.

9. Evidence Composition remains closed.

10. Matilda remains semantic and Interpretation Authority.

Investigate and determine:

1. What is the most precise name for the optional OllamaChatContext field that
   supplies deterministic segments for semantic admission?

Evaluate at least:

   projectContextSegmentCandidates
   contextSegmentCandidates
   adaptiveDetailCandidates

Choose according to architectural ownership, not wording preference.

2. Determine the minimum TypeScript shape for one supplied candidate.

Evaluate:

   relativePath
   sourceStartLine
   sourceEndLine
   excerpt

Determine whether "excerpt", "text", or another existing repository term is the
least ambiguous name for exact segment content.

3. Determine whether provenance must be explicitly carried on every segment or
   may be deterministically inherited from its parent MatildaProjectContextExcerpt.

4. Determine whether authorityStatus must be explicitly carried or may be
   deterministically inherited from the parent excerpt.

5. Determine whether inheritance is safe when every current segment candidate is
   deterministically derived from one supplied git-tracked project-context
   excerpt.

6. Determine whether candidate identity requires association with the parent
   excerpt's original lineNumber.

7. Determine whether parent association is necessary for:

   - validation;
   - provenance;
   - supportSourceReferences;
   - Evidence Composition;
   - deterministic reconstruction;
   - debugging.

8. Determine whether exact range identity alone:

   relativePath + sourceStartLine + sourceEndLine

   is sufficient at the Ollama context boundary.

9. Determine which existing layer should own derivation of segment candidates:

   A. project-context retrieval;
   B. conversation-context composition;
   C. workflow composition;
   D. ollamaChat.

10. Apply the existing ownership boundaries:

    retrieval owns repository retrieval and deterministic source extraction;

    conversation-context composition owns assembly of read models;

    workflow owns orchestration;

    ollamaChat owns the semantic invocation contract.

11. Determine whether retrieval should expose deterministic segment candidates
    as a separate additive result field while preserving excerpts unchanged.

12. Determine whether exposing candidates from retrieval would constitute a
    public contract change and, if so, whether that change remains internal to
    the server architecture.

13. Determine whether conversation-context composition should pass candidates
    through unchanged in the same way it currently passes project evidence
    through unchanged.

14. Determine whether deriving candidates later than retrieval would duplicate
    source-range logic or lose access to retrieval-internal exact source lines.

15. Determine whether candidate order must preserve:

    - retrieved excerpt order;
    - source order within each excerpt.

16. Determine deterministic behavior for duplicate candidate identities.

17. Determine whether overlapping segment ranges are possible under the current
    blank-line segmentation primitive.

18. Determine whether overlapping ranges, if ever encountered, should fail
    closed or remain independently supplied candidates.

19. Determine representation when:

    - no project context was retrieved;
    - an excerpt produces no non-empty segment;
    - segmentation is unavailable;
    - an excerpt was truncated.

20. Determine whether truncated parent excerpts can safely produce segment
    candidates from the internally retained pre-truncation bounded source lines.

21. Determine whether doing so would expose semantic content to Matilda that was
    not present in the existing public projectContextExcerpt.

22. If yes, determine whether candidates must instead be bounded to content
    already represented by the current admitted excerpt.

23. Determine whether this affects the established MAX_EXCERPT_CHARACTERS
    boundary.

24. Determine how exact candidate text should eventually be serialized into the
    existing prompt.

25. Determine whether candidates need an explicit prompt statement that they are:

    - deterministic subdivisions of bounded project context;
    - candidate evidence, not authority;
    - available for semantic materiality selection.

26. Determine whether candidate serialization can coexist with the existing
    Bounded project context evidence section without duplicating the entire
    semantic context unnecessarily.

27. Determine whether the parent excerpts must continue to be supplied to Ollama
    after candidate context is introduced.

28. Do not assume they can be removed: supportSourceReferences and Evidence
    Composition currently validate against supplied projectContextExcerpts.

29. Determine whether supplying both parent excerpts and child candidates creates
    semantic duplication that must be addressed before implementation.

30. Determine whether Matilda can be instructed to use child candidates for
    materiality selection while retaining parent excerpts solely for established
    support-provenance identity.

31. Determine whether that distinction is sufficiently clear inside one prompt
    or whether the candidate-context contract needs another architectural step
    before implementation.

32. Determine whether candidate context is ephemeral and non-persistent.

33. Identify every repository-supported consumer that would need the candidate
    field before selectedContextSegments exists.

34. Determine the smallest testable implementation seam for the candidate
    context alone.

35. Identify exactly one next unit.

Return exactly one classification:

ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT_READY
ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_NEEDS_RETRIEVAL_CONTRACT
ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_NEEDS_PROMPT_RECONCILIATION
ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_NEEDS_PROVENANCE_RECONCILIATION
ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_NOT_JUSTIFIED

Do not implement the candidate context.

Do not expose segments to Ollama.

Do not implement selectedContextSegments.

Do not modify the structured response schema.

Do not modify OllamaChatResult.

Do not modify MatildaProjectContextExcerpt.

Do not redefine supportSourceReferences.

Do not redefine evidenceSufficient.

Do not modify Evidence Composition.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

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
echo "ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT_INVESTIGATION_COMPLETE"
echo "IMPLEMENTATION_NOT_STARTED"
