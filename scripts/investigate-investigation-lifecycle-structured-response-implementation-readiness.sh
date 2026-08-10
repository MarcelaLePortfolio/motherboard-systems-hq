#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE STRUCTURED RESPONSE IMPLEMENTATION READINESS ==="

REQUIRED_ANCESTOR="0f931e9d"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain bounded-artifact classification checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-structured-response-implementation-readiness\.sh$|^ M scripts/investigate-investigation-lifecycle-structured-response-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_INVESTIGATION_SCRIPT_ONLY"

echo
echo "=== BASELINE ==="
git status --short
git branch --show-current
git log -1 --oneline

echo
echo "=== VERIFY BOUNDED ARTIFACT CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_ARTIFACT_READY|REPRESENTATION=OPTIONAL_BOUNDED_INVESTIGATION_LIFECYCLE_ARTIFACT|ORDINARY_CONVERSATION=investigationLifecycle:null' \
  scripts/classify-investigation-lifecycle-semantic-fact-representation.sh

echo
echo "=== INSPECT CURRENT STRUCTURED RESPONSE TYPE SURFACE ==="
grep -n -C 8 -E \
  'OllamaChatResult|OllamaChatResponse|durableInterpretation|explanationStatus|evidenceSufficient|selectedContextSegments|supportReferences' \
  scripts/utils/ollamaChat.ts | head -n 500 || true

echo
echo "=== INSPECT CURRENT STRUCTURED OUTPUT SCHEMA ==="
grep -n -C 12 -E \
  'format:|schema|properties|required|additionalProperties|enum|type.*object|type.*null' \
  scripts/utils/ollamaChat.ts | head -n 700 || true

echo
echo "=== INSPECT CURRENT PARSE AND FAIL-CLOSED VALIDATION ==="
grep -n -C 10 -E \
  'parseStructuredResponse|JSON\.parse|throw new Error|typeof parsed|durableInterpretation|explanationStatus|supportReferences|selectedContextSegments' \
  scripts/utils/ollamaChat.ts | head -n 700 || true

echo
echo "=== INSPECT PROMPT CONTRACT SURFACE ==="
grep -n -C 10 -E \
  'reply|durableInterpretation|Explanation Status|explanationStatus|structured|JSON|Do not invent|Interpretation Authority' \
  scripts/utils/ollamaChat.ts | head -n 700 || true

echo
echo "=== INSPECT WORKFLOW CONSUMPTION ==="
grep -n -C 10 -E \
  'ollamaChat|reply|durableInterpretation|explanationStatus|evidenceSufficient|selectedContextSegments|supportReferences' \
  server/matilda-chat-workflow.ts | head -n 700 || true

echo
echo "=== INSPECT STRUCTURED RESPONSE TEST SURFACE ==="
grep -R -n \
  --include='ollamaChat*.test.ts' \
  --include='*response*.test.ts' \
  --include='*contract*.test.ts' \
  -E \
  'durableInterpretation|explanationStatus|evidenceSufficient|selectedContextSegments|supportReferences|malformed|fails closed|schema|structured' \
  scripts server 2>/dev/null | head -n 900 || true

echo
echo "=== INSPECT RESPONSE CONTRACT GUARD ==="
sed -n '1,320p' scripts/guard-ollama-response-contract.sh

echo
echo "=== INSPECT NULLABLE / OPTIONAL STRUCTURED ARTIFACT PRECEDENT ==="
grep -R -n \
  --include='*.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  '([A-Za-z]+): .*null|anyOf.*null|type.*null|nullable|=== null|== null|\?\.|optional.*artifact|structured.*artifact' \
  scripts server db 2>/dev/null | head -n 700 || true

echo
echo "=== INSPECT CONDITIONAL VALIDATION PRECEDENT ==="
grep -R -n \
  --include='*.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'if \(.*status|if \(.*type|if \(.*event|switch \(.*status|switch \(.*type|required.*when|must.*when|fails closed|fail.*closed' \
  scripts/utils server 2>/dev/null | head -n 700 || true

echo
echo "=== INSPECT PRIOR LIFECYCLE CONTEXT CARRIERS ==="
grep -R -n \
  --include='*.ts' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'selectedHistory|interpretationEntryId|interpretation_entry_id|conversationId|conversation_id|lifecycle|supersessionStatus|supersession_status' \
  server db scripts/utils 2>/dev/null | head -n 900 || true

cat <<'FINDINGS'

Investigation target:

Determine the smallest safe implementation surface for the already-classified
optional bounded Investigation Lifecycle semantic artifact.

Established artifact:

investigationLifecycle: {
  investigationIdentity,
  governingQuestion,
  lifecycleEvent,
  lifecycleDetermination
} | null

Established lifecycleEvent vocabulary:

entered
continued
advanced
resolved
superseded
abandoned

Established conditional determination requirements:

entered     -> optional/null
continued   -> optional/null
advanced    -> required
resolved    -> required
superseded  -> optional/null
abandoned   -> optional/null

Questions to resolve from repository evidence:

1. What exact TypeScript response type currently owns the single structured
   Ollama response?

2. What exact schema object currently constrains model output?

3. What exact parser validates the structured response after generation?

4. Can investigationLifecycle be represented as a nullable bounded object
   inside the existing response without introducing another semantic seam?

5. Does the existing schema mechanism support a nullable object directly?

6. Can lifecycleEvent vocabulary be constrained structurally at schema level?

7. Which semantic constraints cannot be expressed by the current schema and
   therefore require deterministic post-parse validation?

8. Can lifecycleDetermination conditional requirements be validated after parse
   without runtime authoring or modifying semantic content?

9. Can ordinary conversation safely require:

   investigationLifecycle: null

   as an explicit structured value?

10. Would making investigationLifecycle structurally required-but-nullable be
    safer than making the property itself optional, given the repository's
    fail-closed structured-response doctrine?

11. What prompt instructions are minimally necessary so Matilda knows when to
    return null versus author a lifecycle artifact?

12. Can initial implementation author and validate the artifact while
    server/matilda-chat-workflow.ts ignores it?

13. If the workflow ignores the artifact initially, does any existing parser,
    destructuring, spread, persistence, or response transport behavior drop or
    reject the additional field?

14. What exact prior lifecycle context would eventually be necessary to validate
    continued or advanced identity continuity?

15. Is that continuity context already available in selected history or IEL
    lifecycle context, or would supplying it require a later authorized seam?

16. Should continuity validation therefore be excluded from the first bounded
    response-contract implementation if prior lifecycle context is not yet
    supplied?

17. What exact tests must establish:

    - null lifecycle artifact accepted;
    - entered artifact accepted;
    - continued artifact accepted structurally;
    - advanced requires lifecycleDetermination;
    - resolved requires lifecycleDetermination;
    - invalid lifecycleEvent rejected;
    - missing investigationIdentity rejected;
    - missing governingQuestion rejected;
    - malformed lifecycle artifact rejected;
    - existing response fields remain unchanged;
    - one invocation remains preserved?

18. What exact guard assertions must be extended if implementation is later
    authorized?

19. What is the smallest rollback surface?

Required classification:

Exactly one of:

INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READY
INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_NEEDS_NULLABILITY_DECISION
INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_NEEDS_VALIDATION_SEAM_DECISION
INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_NEEDS_CONTEXT_CONTINUITY_SEAM
INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_NOT_READY

Do not implement.

Do not edit ollamaChat.ts.

Do not edit server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not change database schema.

Do not extend IEL.

Do not add persistence.

Do not create dedicated Investigation Lifecycle runtime state.

Do not add workflow consumption.

Do not parse lifecycle facts from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer lifecycle semantics from evidenceSufficient.

Do not infer lifecycle semantics from selectedContextSegments.

Do not reopen Phase 1.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into Phase 2.

Do not add retries.

Do not add another model invocation.

Preserve:

one user message
-> one workflow
-> one Ollama invocation.

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during implementation-readiness investigation."
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
  grep -vE '^scripts/investigate-investigation-lifecycle-structured-response-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READINESS_EVIDENCE_COLLECTED"
echo "BOUNDED_ARTIFACT_CLASSIFICATION_PRESERVED"
echo "PERSISTENCE_NOT_AUTHORIZED"
echo "IEL_EXTENSION_NOT_AUTHORIZED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READINESS"

git add scripts/investigate-investigation-lifecycle-structured-response-implementation-readiness.sh
git commit -m "Investigate Investigation Lifecycle response implementation readiness"
git push
