#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — PARENT SUPPORT IDENTITY DETERMINATION ==="

if [[ "$(git rev-parse --short HEAD)" != "a3797323" ]]; then
  echo "STOP: HEAD no longer matches investigation checkpoint a3797323."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-parent-support-identity-determination\.sh$|^\?\? scripts/run-adaptive-detail-mixed-content-live-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY_CONFIRMED

Repository-supported determination:

1. The existing prompt establishes two distinct identity forms:

   Parent support provenance:
     Source: relativePath:lineNumber

   Child semantic admission:
     Segment source: relativePath:sourceStartLine-sourceEndLine

2. The prompt states that project-context support must use the exact
   relativePath and lineNumber supplied in bounded project context evidence.

3. It also states that parent excerpts remain the support-provenance and
   Evidence Composition universe.

4. However, the prompt does not explicitly prohibit interpreting a child
   Segment source line as a project_context_excerpt lineNumber.

5. Child candidate serialization presents:

   Segment source: relativePath:start-end

   but does not serialize parentRelativePath or parentLineNumber.

6. The live diagnostic produced exactly the ambiguity this permits.

   Supplied parent support identity:

     docs/adaptive-detail-live-validation.md:20

   Supplied child identities:

     docs/adaptive-detail-live-validation.md:20-20
     docs/adaptive-detail-live-validation.md:22-22

   Model-authored project-context support references:

     docs/adaptive-detail-live-validation.md:20
     docs/adaptive-detail-live-validation.md:22

7. The line-22 support reference corresponds exactly to the second child
   segment's start line.

8. No parent excerpt with identity:

     docs/adaptive-detail-live-validation.md:22

   was supplied.

9. Runtime therefore correctly rejected the response under the existing
   fail-closed support validation contract.

10. This behavior is consistent with parent/child identity ambiguity in the
    semantic prompt.

11. It does not establish a support contract mismatch.

12. The deterministic runtime contract already distinguishes the identities
    correctly.

13. The supplied parent universe remains:

      relativePath + parent lineNumber

14. The supplied child universe remains:

      relativePath + sourceStartLine + sourceEndLine

15. supportSourceReferences remains parent-excerpt provenance.

16. selectedContextSegments remains child semantic admission.

17. Evidence Composition remains parent-excerpt based.

18. evidenceSufficient remains derived from validated support provenance.

19. No runtime redesign is supported by the current evidence.

20. No change to support validation is supported by the current evidence.

21. No change to selectedContextSegments identity is supported by the current
    evidence.

22. Adding parent identity to selectedContextSegments is unnecessary.

23. Adding another model invocation is unnecessary.

24. The smallest supported correction is a narrow prompt clarification at the
    existing semantic invocation.

25. The clarification should explicitly state:

    For project_context_excerpt support, use only a Source identity shown under
    Bounded project context evidence.

    Never use a Segment source line range, sourceStartLine, sourceEndLine, or
    child segment line number as a project_context_excerpt support identity.

26. This clarification does not decide semantic relevance.

27. Matilda remains responsible for deciding:

    - which child segments materially affect the immediate reply;
    - which supplied parent sources explicitly support the reply.

28. The runtime remains responsible only for deterministic contract
    validation.

29. This is the first observed live failure under the hypothesis:

    SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY

30. Therefore the three-failed-hypothesis threshold has not been approached.

31. The next implementation must be limited to the prompt identity
    clarification and its direct contract tests.

32. After that clarification passes regression validation, the same bounded
    mixed-content live validation should be rerun.

33. The live behavioral result must still not be inferred in advance.

Next unit:

CLARIFY_ADAPTIVE_DETAIL_PARENT_SUPPORT_IDENTITY_PROMPT

Scope:

- clarify the existing supportSourceReferences prompt contract;
- explicitly distinguish Source identities from Segment source identities;
- explicitly prohibit child line identities from being emitted as
  project_context_excerpt support;
- add a narrow prompt-contract regression test;
- preserve the existing response schema;
- preserve selectedContextSegments semantics;
- preserve supportSourceReferences semantics;
- preserve Evidence Composition;
- preserve evidenceSufficient;
- preserve the validation observers as validation-only seams;
- preserve one user message -> one workflow -> one Ollama invocation.

Do not change support validation.

Do not change selectedContextSegments identity.

Do not add parent identity to selectedContextSegments.

Do not change retrieval.

Do not change ranking.

Do not change query extraction.

Do not change MAX_MATCHES.

Do not change MAX_EXCERPT_CHARACTERS.

Do not persist selectedContextSegments.

Do not widen OllamaChatResult.

Do not add another model invocation.

Do not perform post-model semantic filtering.

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
echo "ADAPTIVE_DETAIL_SUPPORT_PARENT_CHILD_IDENTITY_AMBIGUITY_CONFIRMED"
echo "NEXT_UNIT=CLARIFY_ADAPTIVE_DETAIL_PARENT_SUPPORT_IDENTITY_PROMPT"
