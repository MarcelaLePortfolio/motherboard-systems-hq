#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 REPEATED UNSEEDED VALIDATION RESULT ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-phase3-unseeded-stability.DhJJeS"
summary_file="$artifact_dir/summary.txt"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 3cc2f88c HEAD
test -d "$artifact_dir"
test -f "$summary_file"

total_runs="$(grep -c '^RUN=' "$summary_file")"
semantic_pass_runs="$(grep -c '^CLASSIFICATION=FIXTURE_SEMANTIC_PASS$' "$summary_file" || true)"
runtime_rejection_runs="$(grep -c '^CLASSIFICATION=FAIL_CLOSED_OR_RUNTIME_REJECTION$' "$summary_file" || true)"
semantic_failure_runs="$(grep -c '^CLASSIFICATION=FIXTURE_SEMANTIC_FAILURE$' "$summary_file" || true)"
unique_fingerprints="$(
  grep '^FINGERPRINT=' "$summary_file" |
  cut -d= -f2 |
  sort -u |
  wc -l |
  tr -d ' '
)"

test "$total_runs" -eq 10
test "$semantic_pass_runs" -eq 0
test "$runtime_rejection_runs" -eq 10
test "$semantic_failure_runs" -eq 0
test "$unique_fingerprints" -eq 1

failure_signatures="$(
  grep -hE \
    'Error:|Ollama returned .* not supplied in this invocation|ADAPTIVE_DETAIL.*FAIL|selected context|support reference' \
    "$artifact_dir"/run-*.stderr.txt \
    "$artifact_dir"/run-*.stdout.txt \
    2>/dev/null |
  sort -u || true
)"

printf '%s\n' "$failure_signatures" | grep -q \
  'Ollama returned a project-context support reference that was not supplied in this invocation.'

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=UNSEEDED_BEHAVIORAL_VALIDATION

PHASE_3_SAMPLE=
  TOTAL_RUNS=10
  FIXTURE_SEMANTIC_PASS_RUNS=0
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10
  FIXTURE_SEMANTIC_FAILURE_RUNS=0
  UNIQUE_EXACT_OUTPUT_FINGERPRINTS=1

STABLE_ACCEPTANCE_CRITERION=
  FAIL

UNQUALIFIED_STABLE=
  NO

PHASE_3_PRODUCTION_STABILITY_RESULT=
  UNSTABLE

FAIL_CLOSED_ENFORCEMENT_RESULT=
  PRESERVED_ON_ALL_10_OBSERVED_FAILURES

PRIMARY_DETERMINISTIC_REJECTION_SURFACE=
  UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE

INTERPRETATION=
  The current bounded Phase 3 sample does not establish production stability.

  Zero of ten ordinary unseeded runs satisfied the established semantic
  acceptance surface.

  All ten runs were rejected by the existing deterministic fail-closed
  boundary for the same invalid model-authored project-context support
  provenance condition.

  The current sample differs numerically from the earlier preserved Phase 1
  sample, but both establish material instability on the tested
  production-equivalent surface.

  Exact-output variance was not observed in this sample because all ten
  failures produced one exact fingerprint. That does not establish semantic
  stability.

DETERMINISTIC_VALIDATOR_STATUS=
  PRESERVE

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

PRODUCTION_POLICY_STATUS=
  DEFERRED_BY_PHASE_2

FIXED_SEED_EVIDENCE_STATUS=
  DIAGNOSTIC_ONLY
  DO_NOT_PROMOTE_FROM_THIS_RESULT

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_CHANGE=
  NONE

CORRIDOR_2_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  FAIL_CLOSED_CONTRACT_PRESERVATION

NEXT_ACTION=
  RUN_DR_BEFORE_CORRIDOR_3
MAP
