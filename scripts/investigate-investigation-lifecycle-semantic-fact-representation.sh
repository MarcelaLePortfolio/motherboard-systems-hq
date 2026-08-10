#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE INVESTIGATION LIFECYCLE SEMANTIC FACT REPRESENTATION ==="

REQUIRED_ANCESTOR="c51c667a"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain lifecycle-fact classification checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-investigation-lifecycle-semantic-fact-representation\.sh$|^ M scripts/investigate-investigation-lifecycle-semantic-fact-representation\.sh$' ||
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
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY MINIMUM FACT CONTRACT ==="
grep -nE \
  'MATILDA_INVESTIGATION_LIFECYCLE_FACTS_REQUIRE_ADDITIONAL_SEMANTIC_FIELD|MINIMUM_FACTS=investigationIdentity,governingQuestion,lifecycleEvent,lifecycleDetermination' \
  scripts/classify-minimum-matilda-investigation-lifecycle-fact-contract.sh

echo
echo "=== INSPECT STRUCTURED OLLAMA RESPONSE CONTRACT ==="
grep -nE \
  'type OllamaChatResult|interface OllamaChatResult|reply:|durableInterpretation|explanationStatus|supportSourceReferences|selectedContextSegments|evidenceSufficient|format:|JSON|schema' \
  scripts/utils/ollamaChat.ts | head -n 260 || true

echo
echo "=== INSPECT RESPONSE PARSING AND VALIDATION ==="
grep -nE \
  'parseStructuredResponse|malformed|structured|JSON.parse|durableInterpretation|supportSourceReferences|selectedContextSegments|evidenceSufficient' \
  scripts/utils/ollamaChat.ts | head -n 320 || true

echo
echo "=== INSPECT WORKFLOW SEMANTIC OWNERSHIP ==="
grep -nE \
  'ollamaChat|durableInterpretation|interpretation|IEL|conversation|persist|insert|create|reply' \
  server/matilda-chat-workflow.ts | head -n 320 || true

echo
echo "=== INSPECT IEL REPRESENTATION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'interpretation_entry_id|unresolved_questions|supersession_status|durableInterpretation|InterpretationEntry|interpretation entry|IEL' \
  server db scripts docs 2>/dev/null | head -n 500 || true

echo
echo "=== INSPECT EXISTING OPTIONAL BOUNDED ARTIFACT PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'explanationStatus|supportSourceReferences|selectedContextSegments|evidenceSufficient|evidence:|summary|reasoning' \
  scripts/utils server 2>/dev/null | head -n 500 || true

echo
echo "=== INSPECT IDENTITY AND CORRELATION PATTERNS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'conversation_id|conversationId|interpretation_entry_id|interpretationEntryId|sourceTurnId|randomUUID|uuid|crypto\.randomUUID|correlation' \
  server db scripts 2>/dev/null | head -n 500 || true

echo
echo "=== INSPECT INVESTIGATION LIFECYCLE REPOSITORY EVIDENCE ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'Investigation Lifecycle|investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination|entered|continued|advanced|resolved|superseded|abandoned' \
  scripts docs server db 2>/dev/null | head -n 600 || true

cat <<'FINDINGS'

Investigation questions:

1. Is the existing single structured Ollama response the established
   Matilda-authored semantic artifact seam?

2. Does the repository already establish a pattern for optional bounded
   structured artifacts inside that one response?

3. Can Investigation Lifecycle be represented as one optional bounded artifact:

   investigationLifecycle: {
     investigationIdentity,
     governingQuestion,
     lifecycleEvent,
     lifecycleDetermination
   }

   without adding another semantic invocation?

4. Can ordinary non-investigative conversation safely represent:

   investigationLifecycle = null

   rather than requiring invented lifecycle semantics?

5. Can Matilda author investigationIdentity while deterministic runtime only
   validates continuity against prior supplied lifecycle context?

6. Can stable identity be preserved across continued and advanced turns without
   runtime inventing semantic identity?

7. Can successor relationships remain optional and outside the minimum artifact
   until a supersession use case requires them?

8. Does adding the semantic artifact necessarily require immediate IEL or
   database schema changes, or can semantic representation be established and
   validated before persistence is authorized?

9. Which transition rules can be validated deterministically without moving
   Interpretation Authority into runtime?

Required classification:

Exactly one of:

INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_ARTIFACT_READY
INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_SEAM_READY_REPRESENTATION_UNRESOLVED
INVESTIGATION_LIFECYCLE_REQUIRES_IEL_REPRESENTATION_CHANGE
INVESTIGATION_LIFECYCLE_REPRESENTATION_REQUIRES_DEDICATED_PERSISTENCE
INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION_UNRESOLVED

Do not implement.

Do not change database schema.

Do not add lifecycle facts to production artifacts.

Do not extend IEL.

Do not create dedicated Investigation Lifecycle runtime state.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change the structured response contract.

Do not parse lifecycle facts from durableInterpretation.

Do not repurpose unresolved_questions.

Do not repurpose supersession_status.

Do not infer lifecycle state from evidenceSufficient.

Do not infer lifecycle state from selectedContextSegments.

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
  echo "STOP: production runtime changed during representation investigation."
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
  grep -vE '^scripts/investigate-investigation-lifecycle-semantic-fact-representation\.sh$' ||
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
echo "INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION_EVIDENCE_COLLECTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_SEMANTIC_FACT_REPRESENTATION"

git add scripts/investigate-investigation-lifecycle-semantic-fact-representation.sh
git commit -m "Investigate Investigation Lifecycle semantic representation"
git push
