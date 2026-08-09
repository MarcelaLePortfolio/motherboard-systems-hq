#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — CONTEXT SELECTION BLOCK ==="

cat <<'FINDINGS'
Classification:

BOUNDARY_BLOCKED_BY_CONTEXT_SELECTION

Repository-supported determination:

1. Boundary Composition successfully preserves the tested material boundary
   classes:

   - material scope boundaries;
   - material unresolved uncertainty;
   - authorization boundaries;
   - unsupported capability boundaries.

2. Behavioral validation exposed one remaining failure:

   an immaterial deferred-work statement colocated inside an otherwise relevant
   project-context excerpt was surfaced in the reply.

3. A bounded prompt instruction explicitly requiring omission of immaterial
   boundaries and deferred work did not reliably prevent that disclosure.

4. Therefore the remaining problem is not absence of a Boundary Composition
   prompt instruction.

5. Adding synonymous prompt instructions would layer speculative fixes onto the
   same failed prompt-reliability hypothesis.

6. Deterministic post-model filtering is not a safe Boundary Composition
   solution because deciding whether arbitrary Matilda-authored natural-language
   content is materially relevant requires semantic judgment and could alter
   Matilda-authored meaning.

7. supportSourceReferences cannot safely serve as a pre-reply materiality
   signal.

   They identify support provenance for the resulting conclusion,
   recommendation, or assessment.

   They do not classify every semantic fragment contained inside a supplied
   project-context excerpt.

8. Project-context retrieval already performs bounded query-driven retrieval and
   scored candidate selection based on the current user message.

9. That retrieval operates at excerpt granularity.

10. readBoundedExcerpt(...) returns a bounded multi-line excerpt surrounding a
    matched line.

11. Therefore a retrieved excerpt may contain:

    - content relevant to the immediate request; and
    - colocated content that is not materially relevant to the requested answer.

12. composeMatildaConversationContext(...) does not perform another
    project-context relevance or admission pass.

13. It assigns:

    projectContextExcerpts:
      input.projectContextRetrieval.excerpts

    and therefore preserves retrieved project-context excerpts unchanged.

14. No repository evidence identified an existing runtime signal that
    distinguishes, before reply composition:

    - material content inside an admitted excerpt;
    - merely colocated content inside that same excerpt;
    - deferred or boundary content irrelevant to the immediate answer.

15. The failed immaterial-boundary scenario therefore exposes a granularity
    mismatch:

    project-context retrieval can determine that an excerpt is sufficiently
    relevant to admit, but the current runtime does not determine which semantic
    content inside that excerpt is necessary for the immediate response.

16. Solving that mismatch would require a new relevance, admission, selection,
    segmentation, or context-composition decision beyond the currently
    established Boundary Composition contract.

17. That responsibility overlaps the explicitly deferred Adaptive Detail
    Selection/context-selection problem.

18. Introducing that behavior inside Boundary Composition would improperly
    expand this corridor into a successor corridor before authorization.

19. No smaller existing Boundary Composition seam was identified that can
    reliably eliminate the immaterial content while preserving all of the
    following:

    - Matilda as semantic and Interpretation Authority;
    - one user message -> one workflow -> one Ollama invocation;
    - independently authored reply and durableInterpretation;
    - Summary Composition ownership;
    - Reasoning Composition ownership;
    - closed Evidence Composition behavior;
    - supportSourceReferences semantics;
    - evidenceSufficient semantics;
    - Explanation Status semantics;
    - no post-model semantic filtering;
    - no additional prompt layering;
    - unchanged project-context retrieval semantics.

20. Boundary Composition must therefore stop at this architectural boundary
    rather than absorb context-selection responsibility.

Smallest next unit:

DOCUMENT_BOUNDARY_COMPOSITION_DEFERRED_CONTEXT_SELECTION_DEPENDENCY

This unit records the unresolved dependency only.

It does not authorize Adaptive Detail Selection implementation.

Boundary Composition status:

MATERIAL_BOUNDARY_BEHAVIOR_SUPPORTED
IMMATERIAL_BOUNDARY_OMISSION_NOT_RELIABLY_SUPPORTED
PROMPT_ONLY_HYPOTHESIS_EXHAUSTED
NO_SAFE_EXISTING_BOUNDARY_SEAM_IDENTIFIED
BLOCKED_BY_CONTEXT_SELECTION

Successor dependency:

Adaptive Detail Selection must eventually investigate whether project-context
composition should distinguish material response context from merely colocated
retrieved context before semantic reply composition.

That successor investigation must determine ownership and architecture before
any retrieval, ranking, segmentation, admission, or context-composition behavior
is changed.

Do not:

- add another Boundary prompt instruction;
- add Boundary Status;
- add a structured Boundary artifact;
- perform post-model semantic filtering;
- add another model invocation;
- modify Evidence Composition;
- modify project-context retrieval in this unit;
- begin Adaptive Detail Selection implementation.

Preserve the current stable Boundary Composition contract until the successor
context-selection corridor is explicitly opened.
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
echo "BOUNDARY_COMPOSITION_BLOCKED_BY_CONTEXT_SELECTION"
echo "NEXT_UNIT=DOCUMENT_BOUNDARY_COMPOSITION_DEFERRED_CONTEXT_SELECTION_DEPENDENCY"
