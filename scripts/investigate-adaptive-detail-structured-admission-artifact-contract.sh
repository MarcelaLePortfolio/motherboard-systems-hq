#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — STRUCTURED ADMISSION ARTIFACT CONTRACT INVESTIGATION ==="

if [[ "$(git rev-parse --short HEAD)" != "adc0066a" ]]; then
  echo "STOP: HEAD no longer matches semantic-admission determination checkpoint adc0066a."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-structured-admission-artifact-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== SEGMENT CANDIDATE CONTRACT ==="
grep -n -B 15 -A 90 \
  -E 'MatildaProjectContextSegmentCandidate|segmentProjectContext|segment.*Candidate|sourceStartLine|sourceEndLine' \
  server/matilda-project-context-retrieval.ts \
  | head -n 260 || true

echo
echo "=== SEGMENTATION TEST CONTRACT ==="
sed -n '1,260p' \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== OLLAMA STRUCTURED RESPONSE CONTRACT ==="
sed -n '1,390p' scripts/utils/ollamaChat.ts

echo
echo "=== OLLAMA PROMPT / INVOCATION SEAM ==="
sed -n '390,620p' scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW OLLAMA BOUNDARY ==="
sed -n '150,230p' server/matilda-chat-workflow.ts

echo
echo "=== EXISTING STRUCTURED CONTRACT TESTS ==="
find scripts/utils server \
  -type f \
  \( -name '*ollamaChat*test.ts' -o -name '*conversation-context*test.ts' \) \
  -print \
  | sort

echo
echo "=== SUPPORT REFERENCE VALIDATION ==="
grep -n -B 15 -A 100 \
  -E 'rawSupportSourceReferences|supportSourceReferences|supplied.*reference|deduplic' \
  scripts/utils/ollamaChat.ts \
  | head -n 340 || true

echo
echo "=== RESULT CONSUMERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'ollamaResult\.(reply|durableInterpretation|supportSourceReferences|evidence|evidenceSufficient|explanationStatus)' \
  server scripts db \
  | head -n 260 || true

echo
echo "=== INVESTIGATION QUESTIONS ==="
cat <<'QUESTIONS'

Established architectural constraints:

1. Matilda owns semantic materiality inside the existing Ollama invocation.

2. Deterministic code may validate candidate identity, membership, provenance,
   ranges, duplication, and schema correctness.

3. Deterministic code must not decide semantic relevance.

4. Deterministic segment candidates already exist but remain inert.

5. supportSourceReferences is post-semantic support provenance only.

6. Evidence Composition is closed.

7. No second semantic invocation is permitted.

8. No post-model semantic filtering is permitted.

9. Boundary Composition remains closed.

Investigate and determine:

1. What is the smallest semantic-admission artifact that can represent Matilda's
   selection of supplied deterministic segment candidates?

2. Determine the most precise artifact name.

Evaluate at least:

   selectedContextSegments
   admittedDetailReferences

Do not choose based on wording preference alone. Choose the name whose semantics
most precisely express the architectural responsibility.

3. Determine the minimum identity required for one selected segment.

Evaluate whether identity requires:

   - relativePath;
   - sourceStartLine;
   - sourceEndLine;

and whether any additional identifier is necessary.

4. Determine whether lineNumber should be excluded because segment identity is
   now an exact range rather than the original retrieval match identity.

5. Determine whether excerpt text must be absent from the model-authored
   selection artifact so Matilda selects deterministic identities rather than
   reconstructing source content.

6. Determine whether the artifact belongs in OllamaStructuredResponse.

7. Determine whether it belongs in OllamaChatResult or should be consumed and
   validated internally inside ollamaChat.

8. Determine whether keeping it internal to ollamaChat is compatible with later
   deterministic validation and response-composition use.

9. Determine whether the artifact must be available outside ollamaChat for any
   repository-supported consumer.

10. Determine exact fail-closed behavior for:

    - malformed artifact;
    - malformed identity;
    - invented relativePath;
    - invented source range;
    - partially matching range;
    - duplicate identity;
    - selection of a segment that was not supplied.

11. Determine whether duplicate valid identities should fail closed or be
    deterministically deduplicated.

Compare this with existing supportSourceReferences behavior without assuming the
same policy must apply.

12. Determine whether an empty selection is valid.

Consider requests where:

    - no project context is materially relevant;
    - conversation history alone is sufficient;
    - the user asks a social or conversational question;
    - retrieved candidates are all immaterial.

13. Determine whether absence of supplied segment candidates requires an empty
    artifact.

14. Determine whether a non-empty selection when no candidates were supplied
    must fail closed.

15. Determine how deterministic segment candidates could eventually be supplied
    to the existing invocation without changing MatildaProjectContextExcerpt.

16. Determine whether a separate optional Ollama context field is the smallest
    safe seam.

17. Determine whether that context field should contain:

    - deterministic identity;
    - exact excerpt text;
    - provenance;
    - authority status;

or only the minimum required candidate information.

18. Determine whether semantic admission must occur before reply authorship in
    conceptual semantics even though both are returned from the same model
    invocation.

19. Determine whether one structured model response can legitimately represent:

    - Matilda's semantic admission decision;
    - reply;
    - durableInterpretation;

without implying multiple semantic invocations.

20. Determine whether reply and durableInterpretation remain independently
    authored under that contract.

21. Determine whether selected/admitted segment identities are ephemeral
    response-composition metadata rather than durable interpretation.

22. Determine whether repository evidence supports persistence anywhere.

23. Determine the exact relationship to supportSourceReferences:

    semantic admission:
      candidate context Matilda considered materially relevant for composing the
      immediate response;

    support provenance:
      supplied sources that explicitly support a conclusion, recommendation, or
      assessment actually expressed in reply.

Confirm whether this distinction is architecturally stable.

24. Determine whether one admitted segment may legitimately produce no
    supportSourceReference.

25. Determine whether one supportSourceReference may correspond to an admitted
    segment while retaining excerpt-level provenance semantics.

26. Determine whether introducing the admission artifact requires any change to
    Evidence Composition.

27. Determine the smallest testable implementation seam if the artifact contract
    is supported.

28. Identify exactly one next unit.

Return exactly one classification:

ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_CONTRACT_READY
ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_NEEDS_CONTEXT_CONTRACT
ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_NEEDS_PROVENANCE_RECONCILIATION
ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_NOT_JUSTIFIED
ADAPTIVE_DETAIL_SEMANTIC_ADMISSION_NOT_READY

Do not implement the artifact.

Do not expose segments to Ollama.

Do not modify the structured response schema.

Do not modify OllamaChatResult.

Do not modify MatildaProjectContextExcerpt.

Do not modify supportSourceReferences.

Do not modify evidenceSufficient.

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
echo "ADAPTIVE_DETAIL_STRUCTURED_ADMISSION_ARTIFACT_CONTRACT_INVESTIGATION_COMPLETE"
echo "IMPLEMENTATION_NOT_STARTED"
