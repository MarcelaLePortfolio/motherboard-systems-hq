#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY ADAPTIVE DETAIL — SELECTION / SUPPORT OWNERSHIP ==="

if [[ "$(git rev-parse --short HEAD)" != "7604729a" ]]; then
  echo "STOP: HEAD no longer matches selection/support investigation checkpoint 7604729a."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-adaptive-detail-selection-support-ownership\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_LIVE_VALIDATION_CRITERION_NEEDS_REVISION

Repository-supported determination:

1. selectedContextSegments and supportSourceReferences have deliberately
   different architectural meanings.

2. selectedContextSegments is semantic project-context admission metadata.

3. supportSourceReferences is support provenance for the conclusion,
   recommendation, or assessment expressed in reply.

4. evidenceSufficient remains derived from validated support provenance.

5. Evidence Composition remains parent-excerpt based.

6. The established reconciliation treats semantic admission and support
   provenance as distinct and compatible, not interchangeable.

7. Existing deterministic validation correctly enforces this direction:

   claimed parent project-context support
   -> at least one selected supplied child belonging to that parent

8. This prevents semantically rejected project context from re-entering the
   reply as claimed support.

9. Repository evidence does not establish the reverse rule:

   selected child
   -> mandatory parent supportSourceReference

10. Automatically synthesizing parent support from selected children would
    collapse semantic admission into provenance.

11. Therefore:

    selected project child
    supportSourceReferences = []
    evidenceSufficient = false

    is not by itself a deterministic contract violation.

12. The current live validation requirement:

    PARENT_SUPPORT_PRESENT=true

    is stronger than the established architecture and should not be required
    for Adaptive Detail Selection validation.

13. selectedContextSegments is defined as semantic admission, not as a
    post-composition transcript of only source fragments visibly surfaced in
    the final reply.

14. Semantic admission can therefore be broader than visible reply content.

15. A supplied child may participate in semantic composition without its detail
    appearing in the final bounded reply.

16. Therefore:

    IMMATERIAL_DETAIL_IN_REPLY=false

    does not establish that:

    IMMATERIAL_CHILD_SELECTED=false

    must also hold.

17. Requiring that narrower internal state would redefine the established
    selectedContextSegments lifecycle rather than validate it.

18. The latest live run demonstrated:

    relevant child selected = true
    immaterial child selected = true
    immaterial detail in reply = false
    parent support present = false

19. It also demonstrated that the earlier invalid child-derived parent support
    identity did not recur.

20. The original user-facing mixed-content objective was preventing unrelated
    colocated project context from contaminating the immediate reply.

21. That observable objective was satisfied:

    IMMATERIAL_DETAIL_IN_REPLY=false

22. The live validator should therefore be reconciled to the established
    architecture before another implementation hypothesis is opened.

Reconciled mixed-content success criteria:

A. Relevant project-context content remains semantically available.

B. Unrelated colocated content does not appear in the immediate reply.

C. Any authored project-context support reference must use a valid supplied
   parent Source identity.

D. Any authored parent project-context support must remain consistent with at
   least one selected supplied child belonging to that parent.

E. selectedContextSegments may contain only valid supplied child identities.

F. Runtime performs no semantic post-filtering.

G. No second model invocation occurs.

H. Evidence Composition and evidenceSufficient retain their existing
   support-driven semantics.

The criteria must not require:

- every admitted child to appear in the reply;
- every admitted child to produce parent support provenance;
- every reply using project context to produce evidenceSufficient=true;
- immaterial child omission from selectedContextSegments when the immaterial
  detail is absent from the reply.

Smallest next unit:

REVISE_ADAPTIVE_DETAIL_MIXED_CONTENT_VALIDATION_CRITERIA

Scope:

- change only validation expectations;
- preserve the same bounded live fixture;
- preserve selectedContextSegments observation;
- preserve supportSourceReferences observation;
- continue requiring relevant child selection;
- continue requiring immaterial reply omission;
- continue relying on existing runtime validation to reject invalid parent
  support identities;
- do not require immaterial child omission from selectedContextSegments;
- do not require parent support provenance when none is model-authored;
- preserve evidenceSufficient as support-driven;
- rerun the same live scenario;
- then evaluate Adaptive Detail Selection closure from reconciled criteria.

Do not change ollamaChat.ts.

Do not change selectedContextSegments semantics.

Do not change supportSourceReferences semantics.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not change validation observers.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

Do not add another prompt instruction.

Do not add another model invocation.

Do not perform semantic post-filtering.

Do not reopen Boundary Composition.

Preserve:

one user message -> one workflow -> one Ollama invocation.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_LIVE_VALIDATION_CRITERION_NEEDS_REVISION"
echo "NEXT_UNIT=REVISE_ADAPTIVE_DETAIL_MIXED_CONTENT_VALIDATION_CRITERIA"
echo "IMPLEMENTATION_NOT_STARTED"
