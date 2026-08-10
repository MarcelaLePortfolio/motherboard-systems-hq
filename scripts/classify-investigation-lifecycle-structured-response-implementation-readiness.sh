#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE STRUCTURED RESPONSE IMPLEMENTATION READINESS ==="

REQUIRED_ANCESTOR="deec16ce"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain implementation-readiness investigation checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-structured-response-implementation-readiness\.sh$|^ M scripts/classify-investigation-lifecycle-structured-response-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_CLASSIFICATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --pretty=%s)"

echo
echo "=== VERIFY REPRESENTATION CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_ARTIFACT_READY|REPRESENTATION=OPTIONAL_BOUNDED_INVESTIGATION_LIFECYCLE_ARTIFACT|ORDINARY_CONVERSATION=investigationLifecycle:null' \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh

echo
echo "=== VERIFY IMPLEMENTATION-READINESS INVESTIGATION ==="
grep -n \
  'INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READINESS_EVIDENCE_COLLECTED' \
  scripts/investigate-investigation-lifecycle-structured-response-implementation-readiness.sh

echo
echo "=== VERIFY CURRENT RESPONSE CONTRACT SURFACE ==="
grep -n -C 6 -E \
  'OllamaChatResult|durableInterpretation|explanationStatus|evidenceSufficient|selectedContextSegments|supportReferences' \
  scripts/utils/ollamaChat.ts | head -n 400 || true

echo
echo "=== VERIFY CURRENT SCHEMA AND PARSER SURFACE ==="
grep -n -C 8 -E \
  'schema|properties|required|additionalProperties|parseStructuredResponse|JSON\.parse|throw new Error' \
  scripts/utils/ollamaChat.ts | head -n 500 || true

cat <<'CLASSIFICATION'

Classification:

INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READY

Repository-supported determination:

1. The repository already has one established structured semantic-generation
   seam in scripts/utils/ollamaChat.ts.

2. That seam already returns multiple semantically distinct values from one
   Ollama invocation.

3. Therefore Investigation Lifecycle does not require a second invocation,
   second semantic author, or separate generation pipeline.

4. The previously established minimum representation remains:

   investigationLifecycle: {
     investigationIdentity,
     governingQuestion,
     lifecycleEvent,
     lifecycleDetermination
   } | null

5. The safest initial response-contract shape is a structurally required but
   nullable investigationLifecycle property.

6. This preserves the repository's existing fail-closed structured-response
   doctrine better than silently permitting the property to be omitted.

7. Ordinary non-investigative conversation must therefore explicitly return:

   investigationLifecycle: null

8. An investigative response must return one complete bounded artifact.

9. The bounded artifact must require:

   investigationIdentity
   governingQuestion
   lifecycleEvent
   lifecycleDetermination

10. lifecycleDetermination itself may be null when permitted by lifecycleEvent.

11. lifecycleEvent must remain schema-bounded to:

    entered
    continued
    advanced
    resolved
    superseded
    abandoned

12. Schema validation can constrain the lifecycleEvent vocabulary and the
    structural shape of the artifact.

13. Conditional lifecycleDetermination semantics require deterministic
    post-parse contract validation.

14. Post-parse validation is appropriate because it validates Matilda-authored
    semantic output without authoring, rewriting, repairing, or inferring that
    output.

15. For:

    advanced
    resolved

    lifecycleDetermination must be a non-empty string.

16. For:

    entered
    continued
    superseded
    abandoned

    lifecycleDetermination may be null or a non-empty string according to the
    previously established semantic contract.

17. investigationIdentity must be a non-empty Matilda-authored semantic
    identity whenever investigationLifecycle is non-null.

18. governingQuestion must be a non-empty Matilda-authored semantic question
    whenever investigationLifecycle is non-null.

19. Runtime must reject malformed lifecycle artifacts rather than repairing
    them.

20. Runtime must not derive investigationIdentity from conversation_id or
    interpretation_entry_id.

21. Runtime must not derive governingQuestion from durableInterpretation,
    selected history, unresolved questions, or evidence.

22. Runtime must not derive lifecycleEvent from chronology, evidence sufficiency,
    supersession status, or selected-context behavior.

23. Runtime must not derive lifecycleDetermination from reply,
    durableInterpretation, evidence, or any other response field.

24. The current workflow does not need to consume or persist the new artifact
    for the first response-contract implementation.

25. Initial implementation may safely stop at:

    model authors artifact
    -> structured schema constrains artifact
    -> parser validates artifact
    -> typed Ollama result exposes artifact

26. Downstream workflow consumption remains a later corridor.

27. Investigation Lifecycle persistence remains a later corridor.

28. IEL extension remains a later corridor.

29. Database changes remain unauthorized.

30. Continuity validation for continued or advanced investigations requires
    prior Investigation Lifecycle semantic context, not merely existing
    conversation or IEL storage identity.

31. The repository currently exposes conversation history and interpretation
    lifecycle information, but those are not equivalent to the new semantic
    Investigation Lifecycle artifact.

32. Therefore cross-turn investigationIdentity continuity validation must not be
    fabricated during the first response-contract implementation.

33. Continuity validation remains a successor implementation corridor after a
    legitimate prior-lifecycle-context transport seam is established.

34. Deferring cross-turn continuity validation does not block the bounded
    response-contract implementation itself.

35. The first implementation must validate only the current generated artifact
    against the current response contract.

36. Required tests for the first implementation are:

    - investigationLifecycle:null accepted;
    - valid entered artifact accepted;
    - valid continued artifact accepted;
    - valid advanced artifact accepted with determination;
    - valid resolved artifact accepted with determination;
    - valid superseded artifact accepted;
    - valid abandoned artifact accepted;
    - invalid lifecycleEvent rejected;
    - missing investigationIdentity rejected;
    - empty investigationIdentity rejected;
    - missing governingQuestion rejected;
    - empty governingQuestion rejected;
    - advanced with null determination rejected;
    - advanced with empty determination rejected;
    - resolved with null determination rejected;
    - resolved with empty determination rejected;
    - malformed lifecycle artifact rejected;
    - omitted investigationLifecycle rejected;
    - existing response semantics preserved;
    - one Ollama invocation preserved.

37. The response-contract guard must be extended to verify:

    - bounded Investigation Lifecycle structured contract;
    - nullable ordinary-conversation representation;
    - lifecycleEvent bounded vocabulary;
    - fail-closed lifecycle validation;
    - one typed response object remains;
    - one model invocation remains.

38. Prompt changes must be minimal and contract-specific.

39. The prompt must tell Matilda:

    - return investigationLifecycle:null when the current response does not
      semantically enter, continue, advance, resolve, supersede, or abandon an
      investigation;
    - otherwise author the bounded lifecycle artifact;
    - preserve Investigation Lifecycle semantic authorship;
    - never use conversation_id or interpretation_entry_id as
      investigationIdentity merely because those identifiers exist;
    - never invent lifecycle progress unsupported by the conversation.

40. The smallest implementation surface is expected to be:

    scripts/utils/ollamaChat.ts
    structured-response contract tests
    scripts/guard-ollama-response-contract.sh

41. server/matilda-chat-workflow.ts should remain unchanged during the first
    implementation unless repository evidence produced during implementation
    proves that the additional typed field cannot safely remain unconsumed.

42. If such contradictory evidence appears, implementation must stop rather
    than expanding scope speculatively.

43. Rollback is therefore bounded to the response-contract implementation
    commit and its associated tests/guard changes.

44. Phase 1 Response Composition remains closed.

45. Conversation Engine Generation Stability remains deferred and separate.

46. The implementation must preserve:

    one user message
    -> one workflow
    -> one Ollama invocation.

47. Matilda remains Interpretation Authority.

48. This classification authorizes only the smallest bounded structured-response
    contract implementation.

49. It does not authorize persistence, IEL extension, workflow consumption,
    lifecycle-context transport, continuity validation, dedicated lifecycle
    runtime state, or database changes.

Smallest next unit:

IMPLEMENT_INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_RESPONSE_CONTRACT

Authorized surface:

- scripts/utils/ollamaChat.ts
- directly associated structured-response contract tests
- scripts/guard-ollama-response-contract.sh

Required implementation behavior:

1. Add the typed bounded investigationLifecycle artifact.

2. Add investigationLifecycle to the existing structured-output schema as a
   required nullable field.

3. Bound lifecycleEvent to the established six-event vocabulary.

4. Validate the complete non-null artifact fail-closed.

5. Enforce non-empty investigationIdentity.

6. Enforce non-empty governingQuestion.

7. Enforce required non-empty lifecycleDetermination for advanced and resolved.

8. Preserve nullable lifecycleDetermination where permitted.

9. Add minimal prompt contract instructions.

10. Preserve all existing response fields and semantics.

11. Preserve one invocation.

12. Do not add downstream consumption.

Implementation stop conditions:

- server/matilda-chat-workflow.ts appears to require semantic modification;
- persistence appears necessary;
- IEL modification appears necessary;
- database modification appears necessary;
- a second model invocation appears necessary;
- runtime would need to invent semantic lifecycle facts;
- current response semantics would need to be weakened;
- cross-turn continuity must be fabricated without prior lifecycle context;
- contradictory repository evidence invalidates this classification.

Do not change database schema.

Do not extend IEL.

Do not add persistence.

Do not create dedicated Investigation Lifecycle runtime state.

Do not add workflow consumption.

Do not add continuity validation yet.

Do not parse lifecycle facts from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer lifecycle semantics from evidenceSufficient.

Do not infer lifecycle semantics from selectedContextSegments.

Do not reopen Phase 1.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into Phase 2.

Do not add retries.

Do not add another model invocation.

CLASSIFICATION

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during readiness classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-structured-response-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READY"
echo "INITIAL_CONTRACT=REQUIRED_NULLABLE_INVESTIGATION_LIFECYCLE"
echo "CONDITIONAL_VALIDATION=POST_PARSE_FAIL_CLOSED"
echo "CONTINUITY_VALIDATION=DEFERRED_UNTIL_PRIOR_LIFECYCLE_CONTEXT_EXISTS"
echo "WORKFLOW_CONSUMPTION_NOT_AUTHORIZED"
echo "PERSISTENCE_NOT_AUTHORIZED"
echo "IEL_EXTENSION_NOT_AUTHORIZED"
echo "DATABASE_CHANGE_NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_UNIT=IMPLEMENT_INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_RESPONSE_CONTRACT"

git add scripts/classify-investigation-lifecycle-structured-response-implementation-readiness.sh
git commit -m "Classify Investigation Lifecycle response implementation readiness"
git push
