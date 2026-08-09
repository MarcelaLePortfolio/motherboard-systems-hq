#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — BEHAVIORAL OBSERVABILITY BLOCK ==="

if [[ "$(git rev-parse --short HEAD)" != "a5e0b0a0" ]]; then
  echo "STOP: HEAD no longer matches mixed-content validation inspection checkpoint a5e0b0a0."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-behavioral-observability-block\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_BEHAVIOR_VALIDATION_BLOCKED

Repository-supported determination:

1. The Adaptive Detail selected-context contract is structurally implemented.

2. Existing Ollama regression validation is green:

   31 tests passed
   0 tests failed

3. The structured response contract guard is green.

4. The current runtime preserves:

   one user message
     -> one workflow
     -> one Ollama invocation.

5. projectContextSegmentCandidates are serialized into the semantic invocation.

6. Matilda is required to author selectedContextSegments inside that same
   structured response.

7. selectedContextSegments is parsed and syntactically validated.

8. Exact selected identities are validated against the supplied deterministic
   candidate universe.

9. Duplicate exact selected identities are deterministically normalized.

10. Parent project-context support is checked for consistency with selected
    child segments.

11. Conversation-turn support remains independent.

12. Evidence Composition remains parent-excerpt based.

13. evidenceSufficient remains derived from validated support provenance.

14. selectedContextSegments remains non-persistent.

15. selectedContextSegments is intentionally omitted from OllamaChatResult.

16. Existing live validation scripts invoke ollamaChat(...) and observe only the
    public OllamaChatResult.

17. Therefore the existing live validation surface can observe:

    - reply;
    - explanationStatus;
    - supportSourceReferences;
    - evidence;
    - evidenceSufficient;
    - durableInterpretation.

18. It cannot observe the model-authored selectedContextSegments artifact after
    deterministic validation.

19. The mixed-content behavioral requirement includes proving both:

    A. the materially relevant child segment was selected;

    B. the immaterial child segment was not selected.

20. Reply-text inspection alone cannot establish those two facts.

21. A correct reply could coincidentally omit the immaterial detail without
    Matilda having produced the intended semantic-admission selection.

22. Conversely, inferring selectedContextSegments from supportSourceReferences
    would collapse semantic admission back into support provenance and violate
    the established separation.

23. Inferring selection from Evidence Composition would likewise be invalid
    because Evidence Composition remains parent-excerpt based.

24. Therefore no currently identified live validation seam can directly observe
    the semantic-admission artifact.

25. Running the raw Ollama endpoint independently would not be an equivalent
    validation of the production ollamaChat contract because it could duplicate
    or diverge from:

    - prompt assembly;
    - response schema;
    - parser behavior;
    - supplied-candidate validation;
    - support/selection consistency validation.

26. Reconstructing selectedContextSegments from natural-language reply output
    would be semantic guesswork.

27. Adding another model invocation solely to judge the first invocation is not
    authorized and would violate the one-invocation architecture under test.

28. Production behavior therefore must not be changed merely to force this
    validation through.

29. The smallest missing capability is validation-only observability at the
    existing ollamaChat boundary.

30. That observability must expose the already-authored and already-validated
    selectedContextSegments artifact without:

    - changing Matilda's semantic decision;
    - persisting the artifact;
    - exposing it through normal application APIs;
    - changing Evidence Composition;
    - changing supportSourceReferences;
    - changing evidenceSufficient;
    - adding another model invocation;
    - performing semantic post-filtering.

31. Repository evidence does not yet establish the exact safest observability
    mechanism.

32. Candidate mechanisms that require investigation include:

    A. a validation-only observer callback supplied through OllamaChatContext;

    B. a dedicated test-only wrapper around the existing parsed/validated
       structured response seam;

    C. a non-production diagnostic hook gated explicitly for validation;

    D. widening OllamaChatResult.

33. Widening OllamaChatResult should not be assumed safe because the prior
    contract determination intentionally kept selectedContextSegments internal
    when no runtime consumer required it.

34. Therefore behavioral validation must stop here rather than claim:

    ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED

35. No runtime regression has been identified.

36. Current state is instead:

    STRUCTURAL_CONTRACT_SUPPORTED
    REGRESSION_SUITE_SUPPORTED
    LIVE_SELECTION_OBSERVABILITY_MISSING
    MIXED_CONTENT_BEHAVIOR_NOT_YET_VALIDATED

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_VALIDATION_OBSERVABILITY_SEAM

Purpose:

Determine the smallest validation-only seam that exposes the already-validated
selectedContextSegments artifact for bounded live behavioral testing while
preserving the production contract.

The investigation must determine:

1. whether an observer callback can remain optional and validation-only;

2. whether the callback would run only after:
   - structured parsing;
   - exact candidate validation;
   - deterministic deduplication;
   - parent-support consistency validation;

3. whether it can receive only selectedContextSegments rather than the entire
   raw model response;

4. whether exposing the artifact through that callback changes any public
   runtime semantics;

5. whether the callback can remain non-persistent;

6. whether tests can prove the normal production path is unchanged when no
   observer is supplied;

7. whether live validation can then directly assert:
   - relevant child selected;
   - immaterial child omitted;
   - reply omits immaterial detail;
   - parent support remains valid;
   - one invocation preserved.

Do not implement the observability seam in this unit.

Do not widen OllamaChatResult yet.

Do not expose selectedContextSegments through API or persistence.

Do not change prompt behavior.

Do not change supportSourceReferences.

Do not change Evidence Composition.

Do not change evidenceSufficient.

Do not add another model invocation.

Do not perform semantic post-filtering.

Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_BEHAVIOR_VALIDATION_BLOCKED"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_VALIDATION_OBSERVABILITY_SEAM"
