#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY ADAPTIVE DETAIL — STABILITY FROM SEEDED EVIDENCE ==="

if [[ "$(git rev-parse --short HEAD)" != "827b5f1e" ]]; then
  echo "STOP: HEAD no longer matches seeded-reproducibility checkpoint 827b5f1e."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-adaptive-detail-stability-from-seeded-evidence\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_SEEDED_STABILITY_SUPPORTED_PRODUCTION_STABILITY_UNRESOLVED

Repository-supported determination:

1. The validation-only seed control is implemented and structurally validated.

2. Production matilda-chat-workflow.ts does not supply a seed.

3. The production generation policy therefore remains unchanged.

4. The bounded Adaptive Detail mixed-content fixture was executed three times
   with the same validation-only seed:

   424242

5. All three seeded runs produced:

   RELEVANT_CHILD_SELECTED=true
   IMMATERIAL_CHILD_SELECTED=false
   INVALID_PARENT_LINE_22=false
   IMMATERIAL_DETAIL_IN_REPLY=false

6. All three seeded runs produced exactly the same reply.

7. All three seeded runs produced exactly the same supportSourceReferences.

8. The only project-context support reference was the valid supplied parent:

   docs/adaptive-detail-live-validation.md:20

9. No seeded run emitted the invalid child-derived :22 parent identity.

10. Therefore:

    ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY_SUPPORTED

    is established for this bounded validation fixture.

11. The seeded result provides evidence that the current prompt, schema,
    structured artifacts, and deterministic validation are capable of producing
    the intended Adaptive Detail behavior under a reproducible sampling state.

12. This materially weakens hypotheses that the current contract is inherently
    incapable of expressing the desired behavior.

13. It also materially weakens hypotheses that the invalid :22 support identity
    is forced deterministically by:

    - the response schema;
    - child candidate identity;
    - parent support identity validation;
    - the current child presentation;
    - the bounded fixture itself.

14. The prior unseeded evidence remains:

    - at least one invocation emitted invalid :22 support and failed closed;
    - multiple other identical unseeded invocations succeeded.

15. Therefore ordinary unseeded model behavior remains variable.

16. Seeded reproducibility does not prove that ordinary production behavior is
    stable.

17. The validation-only seed must not be promoted into the production workflow
    merely because the bounded fixture becomes reproducible.

18. Doing so would create a production generation policy decision affecting the
    shared Conversation Engine semantic invocation.

19. That broader decision remains outside the current Adaptive Detail corridor
    unless separately authorized.

20. Runtime fail-closed validation remains correct and must remain unchanged.

21. No evidence supports:

    - weakening support-source validation;
    - silently deleting invalid references;
    - reconstructing support provenance;
    - semantic post-filtering;
    - retries;
    - another model invocation;
    - temperature/top_p/top_k changes;
    - reopening Boundary Composition.

22. The remaining question is now narrower:

    Does Adaptive Detail require ordinary unseeded semantic generation itself
    to be perfectly repeatable for corridor closure, or is fail-closed contract
    enforcement plus demonstrated capability under controlled reproducibility
    sufficient?

23. Repository doctrine does not permit silently redefining that acceptance
    threshold after observing model nondeterminism.

24. The acceptance threshold must therefore be reconciled explicitly before
    closure.

25. Adaptive Detail should not yet be declared closed solely from seeded
    validation.

26. A production seed should not yet be implemented solely from seeded
    validation.

27. The next unit should determine the corridor's stability acceptance contract
    from existing architectural and behavioral-validation doctrine.

Smallest next unit:

DETERMINE_ADAPTIVE_DETAIL_PRODUCTION_STABILITY_ACCEPTANCE_CONTRACT

Determine from repository evidence:

1. Whether semantic-generation corridors historically require identical output
   across repeated unseeded model invocations.

2. Whether behavioral validation instead requires:

   - valid bounded semantic behavior when produced;
   - deterministic runtime contract enforcement;
   - fail-closed rejection of invalid structured artifacts;
   - no corruption or silent repair.

3. Whether model nondeterminism is an accepted property when deterministic
   runtime boundaries remain intact.

4. Whether an intermittent fail-closed model response counts as:

   - an unresolved production reliability blocker;
   - an acceptable model-generation failure mode;
   - or a concern belonging to a separate generation-policy corridor.

5. Whether Adaptive Detail's original objective was:
   - deterministic model selection;
   - deterministic runtime validation;
   - user-facing omission of immaterial content;
   - or some combination.

6. Whether current evidence satisfies the original Adaptive Detail objective
   without requiring global generation-policy changes.

7. Whether seeded validation is admissible only as diagnostic evidence or may
   contribute to behavioral capability evidence.

8. Whether closure can preserve an explicit limitation:

   unseeded model-authored support provenance may occasionally fail closed.

9. Whether that limitation materially prevents normal use of the Conversation
   Engine.

10. Whether any unresolved generation-policy question should be deferred to a
    separate Conversation Engine stability corridor rather than blocking
    Adaptive Detail.

Required classification:

Exactly one of:

ADAPTIVE_DETAIL_PRODUCTION_STABILITY_ACCEPTANCE_SUPPORTED
ADAPTIVE_DETAIL_INTERMITTENT_FAIL_CLOSED_BEHAVIOR_BLOCKS_CLOSURE
ADAPTIVE_DETAIL_GENERATION_STABILITY_BELONGS_TO_SEPARATE_CORRIDOR
ADAPTIVE_DETAIL_STABILITY_ACCEPTANCE_REMAINS_UNRESOLVED

Do not implement.

Do not add a production seed.

Do not change model parameters.

Do not add retries.

Do not add another model invocation.

Do not change supportSourceReferences.

Do not change selectedContextSegments.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

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
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION WORKFLOW SEED ABSENT ==="
if grep -n 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow unexpectedly supplies validation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEEDED_STABILITY_SUPPORTED_PRODUCTION_STABILITY_UNRESOLVED"
echo "NEXT_UNIT=DETERMINE_ADAPTIVE_DETAIL_PRODUCTION_STABILITY_ACCEPTANCE_CONTRACT"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh
git commit -m "Classify Adaptive Detail stability from seeded evidence"
git push
