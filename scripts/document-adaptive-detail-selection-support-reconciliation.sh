#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — DOCUMENT SELECTION / SUPPORT RECONCILIATION ==="

if [[ "$(git rev-parse --short HEAD)" != "5788f823" ]]; then
  echo "STOP: HEAD no longer matches parent-identity checkpoint 5788f823."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-selection-support-reconciliation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_SELECTION_SUPPORT_CONTRACT_COMPATIBLE

Repository-supported determination:

1. supportSourceReferences remains parent-excerpt support provenance.

2. selectedContextSegments remains child-segment semantic admission.

3. These responsibilities are distinct and compatible.

4. A parent project-context excerpt may legitimately support the reply when at
   least one selected child segment deterministically belongs to that parent.

5. A project-context support reference should not be accepted when segment
   candidates were supplied for that parent but Matilda selected none of those
   children.

6. Allowing such a reference would permit semantically rejected project context
   to re-enter the reply as claimed support and would weaken Adaptive Detail
   admission.

7. Preventing that condition does not require redefining
   supportSourceReferences.

8. It requires only deterministic consistency validation between:

   - model-authored selectedContextSegments;
   - model-authored supportSourceReferences;
   - deterministic supplied segment candidates.

9. The newly established parent identity provides the required deterministic
   relationship:

   parentRelativePath
   parentLineNumber

10. Child semantic identity remains independently:

    relativePath
    sourceStartLine
    sourceEndLine

11. Parent identity is metadata lineage, not part of selectedContextSegments
    identity.

12. Parent identity does not need to appear in the model-authored selection
    artifact.

13. supportSourceReferences remains exactly:

    project_context_excerpt:
      relativePath + lineNumber

14. Evidence Composition remains parent-excerpt based.

15. evidenceSufficient remains derived from validated support provenance rather
    than selectedContextSegments.

16. selectedContextSegments therefore remains semantic-admission metadata and
    not evidence provenance.

17. Deterministic consistency validation may verify that a project-context
    support reference corresponds to the parent identity of at least one selected
    supplied segment.

18. This is contract validation, not semantic filtering.

19. Runtime does not decide which segment is relevant.

20. Runtime only verifies that Matilda's independently authored artifacts are
    mutually consistent with the deterministic candidate universe supplied in
    the invocation.

21. An inconsistent response should fail closed.

22. Runtime must not silently remove a support reference.

23. Runtime must not silently add or remove selected segments.

24. Conversation-turn support remains independent from project-context segment
    selection.

25. Explicit evidence-request behavior remains unchanged.

26. Explicit evidence requests may continue to deterministically present all
    supplied parent project-context excerpts according to the already-closed
    Evidence Composition contract.

27. That explicit presentation path does not grant those excerpts semantic
    admission into the ordinary reply.

28. No change to Evidence Composition semantics is required.

29. No change to supportSourceReferences semantics is required.

30. No change to evidenceSufficient semantics is required.

31. The safe implementation order is now:

    a. serialize deterministic child segment candidates into the existing
       invocation;
    b. introduce selectedContextSegments into the same structured response;
    c. validate exact selected identities against supplied candidates;
    d. deterministically deduplicate exact duplicate selections;
    e. validate project-context support references against selected child parent
       identities;
    f. behaviorally validate mixed-content omission;
    g. evaluate Adaptive Detail Selection closure.

32. The next implementation should remain one semantic invocation.

33. Matilda remains the sole semantic materiality authority.

34. No post-model semantic filtering is authorized.

35. Boundary Composition remains closed.

Smallest next unit:

IMPLEMENT_ADAPTIVE_DETAIL_PROMPT_AND_SELECTED_CONTEXT_SEGMENTS_CONTRACT

Scope:

- serialize projectContextSegmentCandidates into the existing prompt;
- clearly distinguish child semantic-admission candidates from parent
  support-provenance excerpts;
- add required selectedContextSegments to the structured response;
- selected identity:
    relativePath
    sourceStartLine
    sourceEndLine
- allow [];
- fail closed on malformed or unsupplied identities;
- deterministically deduplicate exact duplicate identities;
- validate project-context support references against selected child parent
  identities when supplied candidates exist for that parent;
- preserve conversation support independently;
- preserve explicit evidence behavior;
- preserve Evidence Composition;
- preserve evidenceSufficient;
- preserve durableInterpretation;
- preserve one model invocation.

Do not persist selectedContextSegments.

Do not add a second semantic invocation.

Do not perform semantic post-filtering.

Do not modify retrieval ranking.

Do not modify query extraction.

Do not modify MAX_MATCHES.

Do not expand MAX_EXCERPT_CHARACTERS.

Do not reopen Boundary Composition.
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SELECTION_SUPPORT_CONTRACT_COMPATIBLE"
echo "NEXT_UNIT=IMPLEMENT_ADAPTIVE_DETAIL_PROMPT_AND_SELECTED_CONTEXT_SEGMENTS_CONTRACT"
