#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY SCOPED MATILDA — GENERATION CONTROL CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "2bb73ed8" ]]; then
  echo "STOP: HEAD no longer matches scoped-generation-control investigation checkpoint 2bb73ed8."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-scoped-matilda-generation-control-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

MATILDA_VALIDATION_ONLY_GENERATION_CONTROL_READY

Repository-supported determination:

1. OllamaChatContext already functions as an additive per-invocation context
   surface.

2. The context currently carries both semantic inputs and optional
   validation-only observer callbacks.

3. Production matilda-chat-workflow.ts supplies semantic context but does not
   supply the validation observers.

4. Existing live validation scripts call ollamaChat(...) directly and already
   use validation-only context seams that are absent from the production
   workflow.

5. The repository therefore establishes a precedent for optional,
   per-invocation validation instrumentation at the existing ollamaChat seam
   without changing the normal production caller.

6. A request-scoped generation control supplied only by a validation harness
   would differ from the existing observer callbacks in one important respect:

   it would affect model sampling before the response exists rather than merely
   observe an already-produced artifact.

7. Therefore generation controls must not be classified as passive observers.

8. However, a validation-only optional control can still be scoped to direct
   validation invocations while remaining absent from the production workflow.

9. Such a validation invocation would preserve:

   one validation request
   -> one ollamaChat call
   -> one Ollama invocation.

10. No second semantic invocation is required.

11. A fixed seed can be used as a reproducibility control for a bounded
    validation fixture without assigning semantic decisions to deterministic
    repository logic.

12. Matilda remains Interpretation Authority because the model still authors:

    - reply;
    - durableInterpretation;
    - selectedContextSegments;
    - supportSourceReferences;
    - Explanation Status;
    - Summary Composition;
    - Reasoning Composition;
    - Boundary Composition.

13. A fixed seed does not establish that the resulting semantic output is
    correct.

14. A fixed seed does not establish that unseeded production behavior is stable.

15. Seeded validation can answer a narrower diagnostic question:

    whether repeated execution of the same bounded validation fixture can be
    made reproducible enough to distinguish sampling variance from other
    repository-controlled behavior.

16. Therefore validation-only seeded execution is useful diagnostic
    instrumentation, not evidence of production reliability.

17. The active production workflow currently passes no generation controls.

18. The active request payload currently supplies only:

    model;
    stream;
    format;
    prompt.

19. The local gemma3:4b model reports default sampling parameters including:

    temperature = 1;
    top_k = 64;
    top_p = 0.95.

20. Repository evidence does not establish a production generation policy for
    temperature, seed, top_p, or top_k.

21. Repository evidence does not establish that changing temperature, top_p, or
    top_k would preserve established semantic behavior.

22. Repository evidence therefore does not authorize production changes to
    temperature, top_p, or top_k.

23. A production-wide sampling change would affect the shared semantic
    generation seam and therefore extend beyond Adaptive Detail.

24. Any production-wide generation policy must be treated as a separate
    Conversation Engine corridor requiring behavioral revalidation across the
    semantic artifacts owned by ollamaChat.

25. The current Adaptive Detail corridor does not require that broader policy
    change in order to perform the narrower reproducibility experiment.

26. The intermittent :22 provenance behavior remains compatible with sampling
    variance, but the current evidence does not prove sampling variance is the
    sole cause.

27. The smallest justified next implementation surface is therefore
    validation-only request-scoped generation control.

28. That surface must remain absent from the production workflow.

29. The first justified control is a fixed seed only.

30. Temperature, top_p, and top_k must remain unchanged so that the validation
    experiment does not simultaneously alter the model's configured sampling
    distribution.

31. The validation-only seed must not become a production default.

32. The validation-only seed must not alter prompt content.

33. The validation-only seed must not alter response parsing.

34. The validation-only seed must not alter deterministic validation of
    selectedContextSegments or supportSourceReferences.

35. The validation-only seed must not alter evidenceSufficient.

36. The validation-only seed must not change Evidence Composition.

37. The validation-only seed must not change retrieval, segmentation, ranking,
    or Boundary Composition.

38. The validation-only seed must not add retries.

39. The validation-only seed must not add another model invocation.

40. The validation-only seed must preserve Matilda as Interpretation Authority.

Smallest next unit:

IMPLEMENT_MATILDA_VALIDATION_ONLY_SEED_CONTROL

Purpose:

Add the narrowest optional request-scoped seed control necessary for diagnostic
reproducibility while leaving production generation behavior unchanged.

Implementation boundary:

1. Add only the minimum optional typed validation control needed to pass a seed
   into the existing Ollama request.

2. The production workflow must not supply the control.

3. Existing callers that omit the control must produce the existing request
   shape and behavior.

4. The control must affect only the existing single /api/generate invocation.

5. Use seed only.

6. Do not introduce temperature.

7. Do not introduce top_p.

8. Do not introduce top_k.

9. Do not create a production default seed.

10. Add contract tests proving:

    - omission preserves the normal request behavior;
    - a supplied validation seed reaches the existing request options;
    - no second invocation occurs;
    - production workflow does not supply the validation control.

11. Re-run the structured response contract guard.

12. Re-run established OllamaChat tests relevant to the changed seam.

13. Do not claim seeded validation proves production stability.

14. After the seam is validated, use it only in the bounded Adaptive Detail live
    diagnostic to compare repeated identical seeded runs.

Do not implement in this classification unit.

Do not change ollamaChat.ts in this unit.

Do not change the production workflow.

Do not change model defaults.

Do not change temperature.

Do not change top_p.

Do not change top_k.

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
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts server/matilda-chat-workflow.ts; then
  echo "STOP: production runtime changed during classification."
  git diff -- scripts/utils/ollamaChat.ts server/matilda-chat-workflow.ts
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "MATILDA_VALIDATION_ONLY_GENERATION_CONTROL_READY"
echo "NEXT_UNIT=IMPLEMENT_MATILDA_VALIDATION_ONLY_SEED_CONTROL"
echo "PRODUCTION_GENERATION_POLICY_UNCHANGED"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/classify-scoped-matilda-generation-control-contract.sh
git commit -m "Classify validation-only Matilda generation control"
git push
