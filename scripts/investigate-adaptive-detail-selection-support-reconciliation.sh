#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — SELECTION / SUPPORT RECONCILIATION ==="

if [[ "$(git rev-parse --short HEAD)" != "7f77c22b" ]]; then
  echo "STOP: HEAD no longer matches prompt-and-selection investigation checkpoint 7f77c22b."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-adaptive-detail-selection-support-reconciliation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== CURRENT SUPPORT REFERENCE CONTRACT ==="
grep -n -A75 -B20 \
  -E 'MatildaSupportSourceReference|supportSourceReferences' \
  scripts/utils/ollamaChat.ts | head -n 260

echo
echo "=== CURRENT SEGMENT CANDIDATE CONTRACT ==="
grep -n -A45 -B15 \
  -E 'MatildaProjectContextSegmentCandidate|projectContextSegmentCandidates' \
  server/matilda-project-context-retrieval.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SUPPORT VALIDATION + EVIDENCE CONSTRUCTION ==="
sed -n '555,735p' scripts/utils/ollamaChat.ts

cat <<'FINDINGS'

Investigate the compatibility between these two established identities:

Parent project-context excerpt:
  relativePath + lineNumber

Child segment candidate:
  relativePath + sourceStartLine + sourceEndLine

Determine:

1. Whether supportSourceReferences means that a parent excerpt contains evidence
   supporting the reply, without implying every fragment inside it was material.

2. Whether selectedContextSegments can independently mean that these exact child
   segments were materially admitted for semantic response composition.

3. Whether a parent excerpt may remain a valid support source when at least one
   of its child segments was selected.

4. Whether a parent excerpt may remain a valid support source when none of its
   child segments was selected.

5. Whether allowing the latter would defeat Adaptive Detail semantic admission.

6. Whether preventing that case requires changing supportSourceReferences
   semantics or only deterministic consistency validation between structured
   artifacts.

7. Whether child-to-parent membership can be derived deterministically from
   current metadata.

8. Whether segment candidates instead need deterministic parent identity:

   parentRelativePath
   parentLineNumber

9. Whether adding parent identity would be metadata extension only and would
   preserve the existing parent support identity.

10. Whether parent identity should remain internal and absent from prompt
    serialization.

11. Whether supportSourceReferences should remain exactly:

    project_context_excerpt:
      relativePath + lineNumber

12. Whether Evidence Composition should remain parent-excerpt based.

13. Whether evidenceSufficient should remain derived from validated support
    references rather than selectedContextSegments.

14. Whether selectedContextSegments should therefore remain a semantic-admission
    artifact rather than evidence provenance.

15. Whether deterministic validation may require every project-context support
    reference to have at least one selected child belonging to that parent when
    segment candidates were supplied for that parent.

16. Whether this is post-model contract validation rather than prohibited
    post-model semantic filtering.

17. Whether inconsistency should fail closed rather than silently mutate either
    artifact.

18. Whether conversation-turn support remains independent from segment
    selection.

19. Whether explicit evidence requests require an exception because their
    existing deterministic evidence behavior intentionally includes supplied
    project-context excerpts independently of model-owned support selection.

20. Whether that exception can preserve existing explicit-evidence semantics
    without weakening ordinary Adaptive Detail admission.

21. Whether any proposed reconciliation changes supportSourceReferences,
    Evidence Composition, or evidenceSufficient semantics.

22. Determine whether the smallest safe implementation order is:

    a. establish deterministic child-to-parent identity;
    b. serialize segment candidates;
    c. add selectedContextSegments;
    d. validate exact supplied child identities;
    e. validate parent-support / child-selection consistency;
    f. behaviorally validate mixed excerpts.

Return exactly one classification:

ADAPTIVE_DETAIL_SELECTION_SUPPORT_CONTRACT_COMPATIBLE
ADAPTIVE_DETAIL_SELECTION_NEEDS_PARENT_IDENTITY
ADAPTIVE_DETAIL_SELECTION_REQUIRES_EVIDENCE_SEMANTICS_CHANGE
ADAPTIVE_DETAIL_SELECTION_SUPPORT_RECONCILIATION_NOT_READY

Then identify exactly one next unit.

Do not implement selectedContextSegments.
Do not serialize segment candidates into the prompt.
Do not modify supportSourceReferences.
Do not modify evidenceSufficient.
Do not modify Evidence Composition.
Do not change explicit-evidence behavior.
Do not add another model invocation.
Do not perform post-model semantic filtering.
Do not reopen Boundary Composition.

Preserve Matilda as Interpretation Authority.
Preserve one user message -> one workflow -> one Ollama invocation.
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
echo "ADAPTIVE_DETAIL_SELECTION_SUPPORT_RECONCILIATION_INVESTIGATED"
echo "IMPLEMENTATION_NOT_STARTED"
