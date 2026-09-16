#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="2a3997fc7"

git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION OBSERVABILITY — CONTRACT INVESTIGATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "===== ESTABLISHED STARTING STATE ====="
echo "DURABLE_PREEXECUTION_STATE=YES"
echo "PREEXECUTION_TO_ATLAS_BRIDGE=NO"
echo "ATLAS_CURRENT_INPUT=ExecutionEvent[]"
echo "PRIMARY_MISSING_CAPABILITY=ATLAS_PREEXECUTION_READ_MODEL_BRIDGE"
echo "MATILDA_PERSISTENCE_REBUILD_REQUIRED=NO"
echo "REGRESSION=NOT_ESTABLISHED"

echo
echo "===== HISTORICAL ATLAS AUTHORITY / VISIBILITY CONTRACTS ====="
for FILE in \
  docs/governance/milestone-5-execution-lineage/atlas-authority-contract.md \
  docs/governance/milestone-5-execution-lineage/atlas-payload-access-contract.md \
  docs/governance/milestone-5-execution-lineage/atlas-visibility-contract.md \
  docs/governance/CANDIDATE_ATLAS_INTELLIGENCE_DERIVATION_CORRIDOR.md \
  docs/governance/CANDIDATE_ORGANIZATIONAL_EVENT_MODEL.md \
  docs/governance/CANDIDATE_ATLAS_KNOWLEDGE_SCOPE.md
do
  if [[ -f "$FILE" ]]; then
    echo
    echo "===== $FILE ====="
    grep -nEi -C 10 \
      'authority|observe|observation|visibility|read|consume|knowledge|event|intent|interpretation|decision|approval|authorization|package|execution|pre-execution|Matilda|Atlas' \
      "$FILE" || true
  fi
done

echo
echo "===== DURABLE PRE-EXECUTION READABLE FIELDS ====="
grep -nE -C 8 \
  'entry_id|project_id|conversation_id|durable_interpretation|investigation_lifecycle_json|package_semantics_json|created_at' \
  db/matilda-interpretation-runtime.ts | head -n 900 || true

grep -nE -C 8 \
  'draft_package_id|project_id|conversation_id|current_interpretation|evidence_entry_ids|status|created_at|updated_at' \
  db/matilda-living-draft-read-runtime.ts \
  db/package-read-repository.ts 2>/dev/null | head -n 900 || true

grep -nE -C 8 \
  'package_id|draft_package_id|draft_revision_id|lineage_id|approved|created_at' \
  db/matilda-canonical-package-runtime.ts | head -n 900 || true

echo
echo "===== CONTRACT QUESTIONS ====="
echo "Q1=WHICH_PREEXECUTION_FACT_CLASSES_MAY_ATLAS_OBSERVE"
echo "Q2=WHICH_FIELDS_ARE_DURABLE_FACTS_VERSUS_MATILDA_INTERPRETATION"
echo "Q3=HOW_MUST_ATLAS_PRESERVE_PROJECT_CONVERSATION_AND_LINEAGE_IDENTITY"
echo "Q4=HOW_MUST_ATLAS_DISTINGUISH_NONAUTHORITATIVE_DRAFT_FROM_APPROVED_CANONICAL_STATE"
echo "Q5=SHOULD_INVESTIGATION_LIFECYCLE_BE_VISIBLE_AS_AN_OBSERVED_FACT_WITHOUT_BECOMING_ATLAS_AUTHORITY"
echo "Q6=SHOULD_PREEXECUTION_OBSERVATIONS_JOIN_EXECUTION_EVENTS_OR_REMAIN_A_DISTINCT_INPUT_TYPE"
echo "Q7=WHAT_MINIMUM_FIELDS_ARE_REQUIRED_FOR_TRAJECTORY_AND_CAUSAL_REASONING"
echo "Q8=CAN_THE_BRIDGE_BE_READ_ONLY_WITH_ZERO_SOURCE_STATE_MUTATION"
echo "Q9=CAN_EXISTING_ATLAS_REASONING_CONSUME_THE_NEW_OBSERVATION_TYPE_WITHOUT_SEMANTICALLY_MISCLASSIFYING_IT_AS_EXECUTION"
echo "Q10=WHAT_REGRESSION_TESTS_ARE_REQUIRED_BEFORE_ANY_PRODUCTION_WIRING"

echo
echo "===== REQUIRED INVARIANTS ====="
echo "ATLAS_MAY_OBSERVE=YES"
echo "ATLAS_MAY_AUTHOR_MATILDA_INTERPRETATION=NO"
echo "ATLAS_MAY_APPROVE_PACKAGE=NO"
echo "ATLAS_MAY_CREATE_EXECUTION_AUTHORITY=NO"
echo "SOURCE_STATE_MUTATION=NO"
echo "PROJECT_IDENTITY=PRESERVE"
echo "CONVERSATION_IDENTITY=PRESERVE"
echo "LINEAGE=PRESERVE"
echo "AUTHORITY_STATE=PRESERVE"
echo "DRAFT_VS_CANONICAL_DISTINCTION=PRESERVE"
echo "EXECUTION_EVENT_SEMANTICS=PRESERVE"

echo
echo "===== STOP BOUNDARY ====="
echo "IMPLEMENTATION=NO"
echo "DATABASE_CHANGE=NO"
echo "PRODUCTION_POLICY_CHANGE=NO"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=ANSWER_Q1_THROUGH_Q10_AND_DEFINE_MINIMUM_ATLAS_PREEXECUTION_OBSERVATION_CONTRACT"

echo
echo "===== WORKTREE ====="
git status --short
