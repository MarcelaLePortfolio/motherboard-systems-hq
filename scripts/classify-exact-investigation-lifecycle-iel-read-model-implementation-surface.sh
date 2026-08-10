#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY EXACT INVESTIGATION LIFECYCLE IEL READ MODEL IMPLEMENTATION SURFACE ==="

REQUIRED_ANCESTOR="4141fc1f"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: exact IEL read-model investigation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/classify-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$|^ M scripts/classify-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY DEFINING INVESTIGATION CHECKPOINT ==="
grep -nE \
  'EXACT_INVESTIGATION_LIFECYCLE_IEL_READ_MODEL_IMPLEMENTATION_SURFACE_EVIDENCE_COLLECTED|RECONSTRUCTION_IMPLEMENTATION_NOT_STARTED|PARALLEL_IEL_READ_PATH_NOT_ADDED|NEXT_ACTION=CLASSIFY_EXACT_INVESTIGATION_LIFECYCLE_IEL_READ_MODEL_IMPLEMENTATION_SURFACE' \
  scripts/investigate-exact-investigation-lifecycle-iel-read-model-implementation-surface.sh

echo
echo "=== VERIFY EXACT EXISTING IEL READER ==="
grep -n -A45 -B5 \
  'export function listInterpretationEvidenceLedgerEntries' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY EXISTING IEL SELECT OMITS LIFECYCLE JSON ==="
reader="$(
  sed -n '/export function listInterpretationEvidenceLedgerEntries/,/^}/p' \
    db/matilda-interpretation-runtime.ts
)"

printf '%s\n' "$reader"

if printf '%s\n' "$reader" | grep -q 'investigation_lifecycle_json'; then
  echo "STOP: existing IEL reader now projects lifecycle JSON; classification evidence is stale."
  exit 2
fi

echo "EXISTING_IEL_READER_LIFECYCLE_PROJECTION=ABSENT"

echo
echo "=== VERIFY IEL STORAGE FIELD EXISTS ==="
grep -nE \
  'investigation_lifecycle_json TEXT|ADD COLUMN investigation_lifecycle_json TEXT|@investigation_lifecycle_json' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY SINGLE SEMANTIC LIFECYCLE CONTRACT ==="
type_locations="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.sh' \
    -E 'export (interface|type) MatildaInvestigationLifecycleArtifact|interface MatildaInvestigationLifecycleArtifact|type MatildaInvestigationLifecycleArtifact' \
    scripts server db 2>/dev/null ||
  true
)"

printf '%s\n' "$type_locations"

type_count="$(
  printf '%s\n' "$type_locations" |
  grep -c 'MatildaInvestigationLifecycleArtifact' ||
  true
)"

if [[ "$type_count" -ne 1 ]]; then
  echo "STOP: expected exactly one semantic lifecycle artifact definition; found $type_count."
  exit 2
fi

echo "SEMANTIC_LIFECYCLE_SCHEMA=SINGLE_EXISTING_CONTRACT"

echo
echo "=== VERIFY EXACT CONTRACT ==="
grep -n -A12 -B5 \
  'export interface MatildaInvestigationLifecycleArtifact' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY VALIDATION REMAINS PARSER-COUPLED ==="
grep -n -A115 -B8 \
  'if (!("investigationLifecycle" in parsed))' \
  scripts/utils/ollamaChat.ts |
head -n 150

echo
echo "=== VERIFY NO REUSABLE LIFECYCLE VALIDATOR EXISTS ==="
validator_refs="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    -E \
    '(parse|validate|assert)[A-Za-z0-9_]*InvestigationLifecycle|InvestigationLifecycle[A-Za-z0-9_]*(Parser|Validator|Validation)' \
    scripts server db 2>/dev/null ||
  true
)"

if [[ -n "$validator_refs" ]]; then
  echo "STOP: reusable lifecycle validator evidence now exists and requires re-investigation:"
  printf '%s\n' "$validator_refs"
  exit 2
fi

echo "REUSABLE_LIFECYCLE_VALIDATOR=ABSENT"

echo
echo "=== VERIFY NO PERSISTED LIFECYCLE RECONSTRUCTION EXISTS ==="
reconstruction="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    -E \
    'JSON\.parse\(.*investigation_lifecycle_json|investigation_lifecycle_json.*JSON\.parse|parse[A-Za-z0-9_]*InvestigationLifecycle' \
    db server scripts 2>/dev/null ||
  true
)"

if [[ -n "$reconstruction" ]]; then
  echo "STOP: persisted lifecycle reconstruction now exists:"
  printf '%s\n' "$reconstruction"
  exit 2
fi

echo "PERSISTED_LIFECYCLE_RECONSTRUCTION=ABSENT"

echo
echo "=== VERIFY EXISTING IEL READER IS THE REPOSITORY READ SEAM ==="
iel_reader_refs="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    'listInterpretationEvidenceLedgerEntries' \
    server db scripts 2>/dev/null ||
  true
)"

printf '%s\n' "$iel_reader_refs"

echo
echo "=== VERIFY NO PARALLEL LIFECYCLE IEL QUERY EXISTS ==="
parallel_query="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    'FROM matilda_interpretation_evidence_ledger' \
    db server scripts 2>/dev/null |
  grep -v 'db/matilda-interpretation-runtime.ts' ||
  true
)"

if [[ -n "$parallel_query" ]]; then
  echo "STOP: additional production IEL query exists outside IEL owner runtime:"
  printf '%s\n' "$parallel_query"
  exit 2
fi

echo "PARALLEL_IEL_QUERY=ABSENT"

echo
echo "=== VERIFY CONTEXT RUNTIME REMAINS LIFECYCLE-INDEPENDENT ==="
context_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle_json|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_refs" ]]; then
  echo "STOP: Conversation Context Runtime now carries lifecycle semantic state:"
  printf '%s\n' "$context_refs"
  exit 2
fi

echo "CONVERSATION_CONTEXT_LIFECYCLE_STATE=ABSENT"

echo
echo "=== VERIFY CURRENT COMPLETED CONTRACTS ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

npx tsx --test \
  server/matilda-interpretation-context-runtime.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

cat <<'FINDINGS'

Exact Investigation Lifecycle IEL read-model implementation classification:

Repository evidence establishes the following exact implementation boundary.

1. The existing IEL repository read function is:

   listInterpretationEvidenceLedgerEntries()

2. It is owned by:

   db/matilda-interpretation-runtime.ts

3. The existing IEL table already stores:

   investigation_lifecycle_json TEXT NULL

4. The existing reader does not project investigation_lifecycle_json.

5. Therefore persisted lifecycle state is currently unavailable through the
   existing IEL read model.

6. A second or parallel IEL query is not justified.

7. The existing IEL reader should be extended rather than bypassed.

8. The repository has one established semantic lifecycle contract:

   MatildaInvestigationLifecycleArtifact

9. That semantic contract must remain single-source.

10. The bounded lifecycle validation rules currently live inside
    parseStructuredResponse() in scripts/utils/ollamaChat.ts.

11. Those rules are currently coupled to Ollama-response parsing.

12. Persisted lifecycle reconstruction requires the same semantic validation
    contract but must not invoke or imitate the complete Ollama response parser.

13. Therefore the first implementation responsibility is to extract a reusable
    deterministic bounded lifecycle artifact validator/parser from the existing
    response-parser logic.

14. The Ollama structured-response parser must then consume that shared
    validator without changing its existing fail-closed behavior.

15. The IEL read boundary must use the same shared validator when reconstructing
    non-null persisted lifecycle JSON.

16. SQL NULL must reconstruct as semantic null.

17. Valid persisted lifecycle JSON must reconstruct as the exact bounded
    MatildaInvestigationLifecycleArtifact.

18. Malformed non-null JSON must fail closed.

19. Valid JSON that violates lifecycle semantic constraints must fail closed.

20. No semantic field may be inferred or repaired during reconstruction.

21. The reconstruction path must not derive lifecycle facts from:
    durableInterpretation,
    reply,
    chronology,
    supersession_status,
    authority state,
    contamination state,
    conversation turns,
    or Living Draft state.

22. The existing IEL reader remains the repository read seam.

23. The IEL remains persistence owner.

24. The reusable validator owns semantic shape validation, not persistence.

25. The read boundary owns deterministic JSON deserialization and invocation of
    the shared semantic validator.

26. Conversation-turn persistence does not change.

27. Conversation Context Runtime does not change in this implementation unit.

28. selectedHistory does not change in this implementation unit.

29. Prior-lifecycle semantic-generation context does not change in this
    implementation unit.

30. Cross-turn transition validation remains deferred.

31. Current-turn lifecycle generation remains unchanged semantically.

32. Current-turn workflow transport remains unchanged.

33. Lifecycle persistence remains unchanged.

34. One model invocation remains sufficient.

Implementation classification:

EXISTING_IEL_READER=listInterpretationEvidenceLedgerEntries

IEL_READER_EXTENSION=REQUIRED

PARALLEL_IEL_QUERY=PROHIBITED

SEMANTIC_LIFECYCLE_SCHEMA=REUSE_MATILDA_INVESTIGATION_LIFECYCLE_ARTIFACT

REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=REQUIRED

OLLAMA_RESPONSE_PARSER=CONSUME_SHARED_VALIDATOR

IEL_RECONSTRUCTION=JSON_PARSE_PLUS_SHARED_VALIDATOR

NULL_POLICY=SQL_NULL_TO_SEMANTIC_NULL

MALFORMED_JSON_POLICY=FAIL_CLOSED

INVALID_SEMANTIC_ARTIFACT_POLICY=FAIL_CLOSED

SEMANTIC_INFERENCE=PROHIBITED

HISTORICAL_BACKFILL=NOT_REQUIRED

CONVERSATION_TURN_CHANGE=NOT_REQUIRED

CONVERSATION_CONTEXT_CHANGE=NOT_AUTHORIZED

SELECTED_HISTORY_CHANGE=NOT_AUTHORIZED

PRIOR_LIFECYCLE_OLLAMA_CONTEXT=NOT_AUTHORIZED

CROSS_TURN_TRANSITION_VALIDATION=DEFERRED

PHASE_1_RESPONSE_COMPOSITION=CLOSED

Smallest safe implementation surface:

- scripts/utils/ollamaChat.ts
  Extract/reuse bounded Investigation Lifecycle artifact validation while
  preserving current structured-response behavior.

- db/matilda-interpretation-runtime.ts
  Extend the existing IEL reader projection and deterministically reconstruct
  persisted lifecycle JSON using the shared bounded semantic validator.

- targeted tests only
  Establish validator parity and IEL reconstruction behavior.

Required implementation tests:

1. Existing Ollama lifecycle contract tests continue passing unchanged in
   semantic meaning.

2. Shared validator accepts every currently valid bounded lifecycle artifact.

3. Shared validator rejects missing investigation identity.

4. Shared validator rejects missing governing question.

5. Shared validator rejects unsupported lifecycle events.

6. Shared validator rejects malformed lifecycle determination.

7. Shared validator requires determination for advanced.

8. Shared validator requires determination for resolved.

9. IEL SQL NULL reconstructs as null.

10. Valid persisted lifecycle JSON reconstructs exactly.

11. Malformed persisted JSON fails closed.

12. Structurally valid JSON with invalid lifecycle semantics fails closed.

13. IEL read ordering remains unchanged.

14. Existing non-lifecycle IEL fields remain unchanged.

15. No second IEL read query is introduced.

16. Conversation Context Runtime remains unchanged.

17. Conversation-turn persistence remains unchanged.

18. One Ollama invocation remains preserved.

Implementation may proceed only on this bounded surface.

Do not create a new lifecycle schema.

Do not create a parallel IEL reader.

Do not add lifecycle state to Conversation Context Runtime.

Do not add lifecycle state to selectedHistory.

Do not add prior lifecycle to the Ollama prompt.

Do not implement cross-turn validation.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Preserve:

Matilda
= Interpretation Authority and lifecycle semantic author

Workflow
= current-turn typed transport

IEL
= persistence owner and existing repository read boundary

Shared validator
= deterministic enforcement of the already-established semantic contract

Reconstruction
= recovery of already-authored semantic facts only

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

FINDINGS

echo
echo "EXACT_INVESTIGATION_LIFECYCLE_IEL_READ_MODEL_IMPLEMENTATION_SURFACE_CLASSIFIED"
echo "EXISTING_IEL_READER=listInterpretationEvidenceLedgerEntries"
echo "IEL_READER_EXTENSION=REQUIRED"
echo "PARALLEL_IEL_QUERY=PROHIBITED"
echo "REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=REQUIRED"
echo "IEL_RECONSTRUCTION=JSON_PARSE_PLUS_SHARED_VALIDATOR"
echo "NULL_POLICY=SQL_NULL_TO_SEMANTIC_NULL"
echo "MALFORMED_JSON_POLICY=FAIL_CLOSED"
echo "INVALID_SEMANTIC_ARTIFACT_POLICY=FAIL_CLOSED"
echo "SEMANTIC_INFERENCE=PROHIBITED"
echo "CONVERSATION_CONTEXT_CHANGE=NOT_AUTHORIZED"
echo "SELECTED_HISTORY_CHANGE=NOT_AUTHORIZED"
echo "PRIOR_LIFECYCLE_OLLAMA_CONTEXT=NOT_AUTHORIZED"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=IMPLEMENT_BOUNDED_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-exact-investigation-lifecycle-iel-read-model-implementation-surface\.sh$' ||
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

git add scripts/classify-exact-investigation-lifecycle-iel-read-model-implementation-surface.sh
git diff --cached --check
git commit -m "Classify Investigation Lifecycle IEL read model surface"
git push
