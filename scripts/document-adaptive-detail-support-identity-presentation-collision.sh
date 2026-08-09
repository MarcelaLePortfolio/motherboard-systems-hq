#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SUPPORT IDENTITY PRESENTATION COLLISION DETERMINATION ==="

if [[ "$(git rev-parse --short HEAD)" != "f3071e8a" ]]; then
  echo "STOP: HEAD no longer matches investigation checkpoint f3071e8a."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-support-identity-presentation-collision\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_SUPPORT_IDENTITY_PRESENTATION_COLLISION_CONFIRMED

Repository-supported determination:

1. Parent support provenance and child semantic admission remain correctly
   distinct in the runtime contract.

2. Parent support identity is:

   relativePath + lineNumber

3. Child semantic identity is:

   relativePath + sourceStartLine + sourceEndLine

4. Runtime validation correctly enforces those distinct identity universes.

5. The live failure occurred before any evidence of a runtime identity-contract
   defect.

6. The prompt currently serializes parent identity as:

   Source: relativePath:lineNumber

7. The prompt currently serializes child identity as:

   Segment source: relativePath:sourceStartLine-sourceEndLine

8. These are visually and structurally similar source-shaped representations.

9. In the bounded live case, the supplied identities were:

   Parent:
     docs/adaptive-detail-live-validation.md:20

   Children:
     docs/adaptive-detail-live-validation.md:20-20
     docs/adaptive-detail-live-validation.md:22-22

10. The model authored project-context support references:

    docs/adaptive-detail-live-validation.md:20
    docs/adaptive-detail-live-validation.md:22

11. The second support identity exactly reused the second child segment's line
    number.

12. No parent Source identity ending in :22 was supplied.

13. Runtime correctly rejected that reference.

14. A narrow wording clarification was then added stating that:

    - project_context_excerpt support may use only Source identities shown under
      Bounded project context evidence;
    - Segment source ranges and child line numbers must never be used as parent
      project-context support identities.

15. The same bounded live validation was rerun after that clarification.

16. The model again authored the same invalid parent support identity ending in
    :22.

17. Therefore a wording-only prohibition did not resolve the observed collision.

18. There is no evidence supporting another wording-only prohibition as a
    confidently distinct fix.

19. Adding more natural-language warnings would risk speculative prompt
    layering.

20. The evidence instead supports a presentation-level identity collision:
    parent and child identities remain represented in sufficiently similar
    source notation that the child line number can be reused as parent support
    provenance.

21. This classification does not imply that Matilda's semantic selection
    authority is defective.

22. It does not imply that supportSourceReferences semantics are defective.

23. It does not imply that selectedContextSegments semantics are defective.

24. It does not imply that support validation should be weakened.

25. It does not support accepting child identities as parent support identities.

26. It does not support adding parent identity to selectedContextSegments.

27. It does not support changing Evidence Composition.

28. It does not support changing evidenceSufficient.

29. The safest next hypothesis is presentation-level namespace separation.

30. The child candidate representation should become unmistakably distinct from
    parent Source provenance while preserving all exact child identity values
    required by the structured selectedContextSegments contract.

31. A safe presentation must continue to provide Matilda with:

    relativePath
    sourceStartLine
    sourceEndLine

32. Those values need not be rendered as a colon-style source citation.

33. In particular, child identity may be represented as explicitly named fields
    rather than:

    Segment source: relativePath:start-end

34. Candidate example for investigation/implementation:

    Segment candidate:
      relativePath = docs/example.md
      sourceStartLine = 22
      sourceEndLine = 22

35. That representation preserves the exact structured child identity while
    removing the parent-like:

    path:line

    visual namespace.

36. Parent evidence may remain represented by its established:

    Source: relativePath:lineNumber

    provenance identity.

37. No semantic post-filtering is required.

38. No second model invocation is required.

39. No runtime identity redesign is required.

40. No persistence change is required.

41. No OllamaChatResult widening is required.

42. No support-validation change is required.

43. Matilda remains the sole Interpretation Authority deciding which supplied
    child segments materially affect the immediate reply.

44. Runtime remains responsible for deterministic validation only.

45. This is the first failed implementation attempt under the original
    SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY hypothesis.

46. The evidence now supports refining that hypothesis to the more specific:

    SUPPORT_IDENTITY_PRESENTATION_COLLISION

47. The next implementation must test that narrower hypothesis without layering
    additional speculative corrections.

Next unit:

SEPARATE_ADAPTIVE_DETAIL_CHILD_IDENTITY_PRESENTATION

Authorized scope for that next unit:

- change only child candidate prompt presentation;
- preserve exact relativePath;
- preserve exact sourceStartLine;
- preserve exact sourceEndLine;
- remove colon-style parent-like child source notation;
- make child identity fields structurally distinct from parent Source identity;
- add narrow prompt-contract validation;
- rerun the existing Ollama regression suite;
- rerun the same bounded mixed-content live validation;
- preserve existing validation observers as validation-only seams.

Do not change supportSourceReferences semantics.

Do not change selectedContextSegments runtime identity.

Do not add parent identity to selectedContextSegments.

Do not change support validation.

Do not change retrieval.

Do not change ranking.

Do not change query extraction.

Do not change MAX_MATCHES.

Do not change MAX_EXCERPT_CHARACTERS.

Do not persist selectedContextSegments.

Do not widen OllamaChatResult.

Do not add another model invocation.

Do not perform post-model semantic filtering.

Do not add another wording-only prohibition.

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
echo "ADAPTIVE_DETAIL_SUPPORT_IDENTITY_PRESENTATION_COLLISION_CONFIRMED"
echo "NEXT_UNIT=SEPARATE_ADAPTIVE_DETAIL_CHILD_IDENTITY_PRESENTATION"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/document-adaptive-detail-support-identity-presentation-collision.sh && \
git commit -m "Document Adaptive Detail support identity presentation collision" && \
git push
