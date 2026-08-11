#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE CROSS-TURN TRANSITION VALIDATION IMPLEMENTATION READINESS ==="

REQUIRED_ANCESTOR="700d4784"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: cross-turn transition-validation classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness\.sh$|^ M scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING CURRENT-STATE CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_CURRENT_STATE_CLASSIFIED|CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=ABSENT|PRIOR_LIFECYCLE_CONTEXT_PREREQUISITE=SATISFIED|SUPPORTED_DETERMINISTIC_CONTINUITY_SCOPE=CONTINUED_AND_ADVANCED_IDENTITY|CONTINUITY_VIOLATION_BEHAVIOR=FAIL_CLOSED|CANDIDATE_VALIDATION_OWNER=OLLAMA_POST_PARSE_PRE_WORKFLOW_RETURN|NEXT_UNIT=CLASSIFY_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS' \
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-current-state.sh

echo
echo "=== VERIFY IDENTITY CONTINUITY AUTHORITY ==="
grep -nE \
  'investigationIdentity must remain stable across turns belonging to the same|CONTINUATION can be represented by the stable investigationIdentity' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

grep -nE \
  'For continuation or advancement, prior lifecycle context may supply the|Matilda must preserve that identity when the same investigation continues|Deterministic runtime may validate identity continuity|A continuity violation must fail closed' \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh

echo
echo "=== VERIFY GOVERNING QUESTION RULE DOES NOT ESTABLISH EXACT STRING EQUALITY ==="
exact_governing_question_rule="$(
  grep -RInE \
    'exact governingQuestion|string equality.*governingQuestion|governingQuestion.*string equality|governingQuestion must exactly|exactly match.*governingQuestion' \
    docs scripts server db \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.js' \
    --exclude='*.map' \
    --exclude='classify-investigation-lifecycle-cross-turn-transition-validation-current-state.sh' \
    --exclude='classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh' \
    2>/dev/null ||
  true
)"

if [[ -n "$exact_governing_question_rule" ]]; then
  echo "STOP: repository now contains a possible exact governingQuestion equality rule requiring reclassification:"
  printf '%s\n' "$exact_governing_question_rule"
  exit 2
fi

echo "EXACT_GOVERNING_QUESTION_STRING_EQUALITY_NOT_ESTABLISHED"

echo
echo "=== VERIFY PRIOR LIFECYCLE INPUT EXISTS ==="
grep -nE \
  'priorInvestigationLifecycle' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY CURRENT RESULT PARSED BEFORE DOWNSTREAM PROCESSING ==="
grep -nE \
  'const result =|parseStructuredResponse\(rawResponse\)' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY CURRENT LIFECYCLE RETURN ==="
grep -nE -C 5 \
  'investigationLifecycle:[[:space:]]*$|result\.investigationLifecycle' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY WORKFLOW RECEIVES OLLAMA RESULT BEFORE IEL PERSISTENCE ==="
grep -nE \
  'const ollamaResult =|await ollamaChat|createInterpretationEvidenceLedgerEntry|investigation_lifecycle:' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY EXISTING LIFECYCLE CONTRACT TEST SURFACE ==="
test -f scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
grep -nE \
  'Investigation Lifecycle|continued|advanced|investigation identity|governing question' \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY RESPONSE CONTRACT GUARD SURFACE ==="
test -f scripts/guard-ollama-response-contract.sh
grep -nE \
  'GUARD INVESTIGATION LIFECYCLE RESPONSE CONTRACT|investigationLifecycle|MatildaInvestigationLifecycleArtifact|continued|advanced|fail-closed lifecycle validation' \
  scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Cross-turn Investigation Lifecycle transition-validation implementation readiness:

Established prerequisite state:

PRIOR_LIFECYCLE_CONTEXT_TRANSPORT=IMPLEMENTED
SEMANTIC_GENERATION_PRIOR_LIFECYCLE_INPUT=IMPLEMENTED
CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION=ABSENT

Repository-supported deterministic invariant:

1. investigationIdentity must remain stable across turns belonging to the same
   investigation.

2. Prior lifecycle context supplies an already-authored investigationIdentity.

3. Matilda remains responsible for determining whether the current turn
   continues or advances the same investigation.

4. For lifecycleEvent=continued or lifecycleEvent=advanced, deterministic
   runtime may validate that Matilda preserved the prior investigationIdentity.

5. Runtime must not invent, substitute, rewrite, or repair investigationIdentity.

6. A supported identity-continuity violation must fail closed.

Bounded implementation scope:

7. The smallest safe implementation is one dedicated deterministic cross-turn
   lifecycle validator.

8. Its inputs are:

   priorInvestigationLifecycle:
     MatildaInvestigationLifecycleArtifact | null

   currentInvestigationLifecycle:
     MatildaInvestigationLifecycleArtifact | null

9. If either artifact is null, this bounded validator has no established
   identity-continuity violation to enforce.

10. If current lifecycleEvent is neither continued nor advanced, this bounded
    validator has no established identity-continuity rule to enforce.

11. If current lifecycleEvent is continued or advanced and prior lifecycle state
    exists, current investigationIdentity must equal prior investigationIdentity.

12. A mismatch in that bounded case must throw and fail closed.

13. The validator must not determine which lifecycleEvent Matilda should have
    authored.

14. The validator must not rewrite the current artifact.

15. The validator must not infer a successor investigation.

16. The validator must not infer a new investigation.

17. The validator must not infer terminal-state semantics.

18. The validator must not enforce a complete event transition matrix.

Governing-question boundary:

19. The repository establishes that CONTINUATION semantically uses a preserved
    governingQuestion.

20. Repository evidence does not establish that preservation means exact string
    equality.

21. Therefore the first bounded deterministic implementation must not enforce
    governingQuestion string equality.

22. Advanced governing-question equality is likewise not established.

23. Governing-question transition validation remains outside this bounded
    implementation unless separately governed by stronger evidence.

Ownership:

24. The existing single-artifact validator remains responsible for validating
    the internal shape and bounded semantics of one lifecycle artifact.

25. Cross-turn continuity validation requires two artifacts and should therefore
    remain a separate deterministic validator rather than expanding the
    single-artifact validator into historical-context ownership.

26. ollamaChat already owns both required comparison inputs:

    context.priorInvestigationLifecycle

    and

    result.investigationLifecycle

27. The smallest safe invocation seam is immediately after
    parseStructuredResponse(rawResponse) and before downstream result processing
    and workflow return.

28. This ensures invalid continuity fails before IEL persistence.

29. Workflow remains orchestration and persistence transport rather than
    semantic validator.

30. IEL persistence and reconstruction remain unchanged.

31. Prior-context selection and transport remain unchanged.

Validation path:

32. Extend the existing Investigation Lifecycle contract test surface with
    deterministic continuity cases covering at minimum:

    - null prior + null current => accepted;
    - null prior + entered => accepted;
    - prior + null current => accepted;
    - same identity + continued => accepted;
    - changed identity + continued => rejected;
    - same identity + advanced => accepted;
    - changed identity + advanced => rejected;
    - changed identity + entered => not rejected by this validator;
    - resolved => no new identity rule inferred;
    - superseded => no new identity rule inferred;
    - abandoned => no new identity rule inferred.

33. Extend the permanent response-contract guard only enough to assert that the
    dedicated cross-turn validator and its invocation remain present.

34. Run the existing Investigation Lifecycle contract test.

35. Run the Ollama response-contract guard.

36. Run targeted workflow/lifecycle regression tests already established by the
    repository.

37. Run git diff --check.

Rollback:

38. The rollback surface is bounded to:

    scripts/utils/ollamaChat.ts

    scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

    scripts/guard-ollama-response-contract.sh

39. No database rollback is required.

40. No IEL rollback is required.

41. No Conversation Context Runtime rollback is required.

42. No workflow persistence rollback is required.

Architectural preservation:

43. Matilda remains Investigation Lifecycle semantic author.

44. Runtime validates only an already-established identity-continuity invariant.

45. selectedHistory remains unchanged.

46. Conversation Context Runtime remains unchanged.

47. conversation-turn persistence remains unchanged.

48. IEL persistence remains unchanged.

49. IEL reconstruction remains unchanged.

50. prior lifecycle transport remains unchanged.

51. No retry is introduced.

52. No correction invocation is introduced.

53. No second model invocation is introduced.

54. Phase 1 Response Composition remains closed.

Implementation-readiness classification:

INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READY

IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY

VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER

VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING

FAILURE_BEHAVIOR=FAIL_CLOSED

GOVERNING_QUESTION_EXACT_EQUALITY=NOT_AUTHORIZED

FULL_TRANSITION_MATRIX=NOT_AUTHORIZED

TERMINAL_STATE_VALIDATION=NOT_AUTHORIZED

AUTOMATIC_REPAIR=NOT_AUTHORIZED

SECOND_MODEL_INVOCATION=NOT_REQUIRED

ROLLBACK_SURFACE=THREE_FILES

Implementation is not authorized by this classification unit.

Explicit user authorization remains required before production runtime changes.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READY"
echo "IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY"
echo "VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER"
echo "VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING"
echo "FAILURE_BEHAVIOR=FAIL_CLOSED"
echo "GOVERNING_QUESTION_EXACT_EQUALITY=NOT_AUTHORIZED"
echo "FULL_TRANSITION_MATRIX=NOT_AUTHORIZED"
echo "TERMINAL_STATE_VALIDATION=NOT_AUTHORIZED"
echo "AUTOMATIC_REPAIR=NOT_AUTHORIZED"
echo "SECOND_MODEL_INVOCATION=NOT_REQUIRED"
echo "ROLLBACK_SURFACE=THREE_FILES"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=REQUEST_EXPLICIT_IMPLEMENTATION_AUTHORIZATION"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during transition-validation implementation-readiness classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness\.sh$' ||
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

git add scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle transition validation implementation readiness"
git push
