#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PRESERVED UNSEEDED ACCEPTANCE-BOUNDARY FAILURE ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-unseeded-variance.k8GDnQ"

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY OBSERVATION RUNNER CHECKPOINT ==="
required_runner_commit="ef7e6d21"

if ! git merge-base --is-ancestor \
  "$required_runner_commit" \
  HEAD
then
  echo "STOP: HEAD does not contain required bounded-observer checkpoint $required_runner_commit."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-preserved-unseeded-acceptance-boundary-failure\.sh$|^ M scripts/classify-preserved-unseeded-acceptance-boundary-failure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REQUIRED_OBSERVATION_RUNNER_ANCESTOR_PRESENT=$required_runner_commit"

echo
echo "=== VERIFY PRESERVED SAMPLE EXISTS ==="
if [[ ! -d "$artifact_dir" ]]; then
  echo "STOP: preserved sample directory is unavailable:"
  echo "$artifact_dir"
  exit 2
fi

if [[ ! -f "$artifact_dir/summary.tsv" ]]; then
  echo "STOP: preserved summary artifact is unavailable."
  exit 2
fi

echo "PRESERVED_SAMPLE_DIRECTORY=$artifact_dir"

echo
echo "=== PRESERVED SAMPLE SUMMARY ==="
cat "$artifact_dir/summary.tsv"

data_rows="$(
  tail -n +2 "$artifact_dir/summary.tsv" |
  wc -l |
  tr -d ' '
)"

pass_runs="$(
  awk -F '\t' \
    '$3 == "FIXTURE_SEMANTIC_PASS" { count++ } END { print count+0 }' \
    "$artifact_dir/summary.tsv"
)"

failure_runs="$(
  awk -F '\t' \
    '$3 == "FAIL_CLOSED_OR_RUNTIME_REJECTION" { count++ } END { print count+0 }' \
    "$artifact_dir/summary.tsv"
)"

semantic_fail_runs="$(
  awk -F '\t' \
    '$3 == "FIXTURE_SEMANTIC_FAIL" { count++ } END { print count+0 }' \
    "$artifact_dir/summary.tsv"
)"

unique_fingerprints="$(
  tail -n +2 "$artifact_dir/summary.tsv" |
  cut -f4 |
  sort -u |
  wc -l |
  tr -d ' '
)"

echo
echo "TOTAL_SAMPLE_ROWS=$data_rows"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$pass_runs"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$failure_runs"
echo "FIXTURE_SEMANTIC_FAIL_RUNS=$semantic_fail_runs"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"

if [[ "$data_rows" -ne 10 ]]; then
  echo "STOP: preserved sample is not the required ten-run sample."
  exit 2
fi

if [[ "$pass_runs" -ne 1 ]]; then
  echo "STOP: preserved sample does not contain exactly one semantic pass."
  exit 2
fi

if [[ "$failure_runs" -ne 9 ]]; then
  echo "STOP: preserved sample does not contain exactly nine fail-closed/runtime-rejection rows."
  exit 2
fi

if [[ "$semantic_fail_runs" -ne 0 ]]; then
  echo "STOP: preserved sample contains unexpected fixture-semantic-fail rows."
  exit 2
fi

echo "PRESERVED_SAMPLE_COUNTS=CONFIRMED"

echo
echo "=== VERIFY FAILURE SIGNATURE ==="

failure_signature='Ollama returned a project-context support reference that was not supplied in this invocation.'

signature_count="$(
  grep -lF \
    "$failure_signature" \
    "$artifact_dir"/run-*.stderr.txt |
  wc -l |
  tr -d ' '
)"

echo "FAILURE_SIGNATURE_ARTIFACT_COUNT=$signature_count"

if [[ "$signature_count" -ne 9 ]]; then
  echo "STOP: expected failure signature was not present in exactly nine stderr artifacts."
  exit 2
fi

echo "FAILURE_SIGNATURE=CONFIRMED"

echo
echo "=== VERIFY INVALID MODEL-AUTHORED SUPPORT IDENTITY ==="

line22_artifact_count="$(
  grep -l '"lineNumber": 22' \
    "$artifact_dir"/run-*.stdout.txt |
  wc -l |
  tr -d ' '
)"

echo "INVALID_LINE_22_SUPPORT_ARTIFACT_COUNT=$line22_artifact_count"

if [[ "$line22_artifact_count" -ne 9 ]]; then
  echo "STOP: invalid line-22 support identity was not observed in exactly nine run artifacts."
  exit 2
fi

echo "INVALID_MODEL_AUTHORED_SUPPORT_IDENTITY=CONFIRMED"

echo
echo "=== VERIFY SUCCESSFUL RUN ==="
cat "$artifact_dir/run-8.stdout.txt"

if ! grep -q \
  'ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED' \
  "$artifact_dir/run-8.stdout.txt"
then
  echo "STOP: preserved successful run does not satisfy established fixture acceptance."
  exit 2
fi

if [[ -s "$artifact_dir/run-8.stderr.txt" ]]; then
  echo "STOP: preserved successful run contains stderr output."
  cat "$artifact_dir/run-8.stderr.txt"
  exit 2
fi

echo "SUCCESSFUL_UNSEEDED_RUN=CONFIRMED"

echo
echo "=== VERIFY DETERMINISTIC FAIL-CLOSED ENFORCEMENT ==="

grep -nE \
  'project-context support reference that was not supplied|supportSourceReferences|throw new Error' \
  scripts/utils/ollamaChat.ts |
  tail -40

if ! grep -q \
  'Ollama returned a project-context support reference that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: repository no longer contains the observed fail-closed enforcement signature."
  exit 2
fi

echo "DETERMINISTIC_FAIL_CLOSED_ENFORCEMENT=CONFIRMED"

echo
echo "=== FAILURE CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=UNSEEDED_SEMANTIC_VARIANCE_CHARACTERIZATION

BOUNDED_SAMPLE=
  10 identical ordinary unseeded ollamaChat invocations.

OBSERVED_RESULT=
  1 run satisfied the established mixed-content semantic acceptance criteria.

  9 runs produced the same invalid model-authored project-context support
  identity at line 22.

  Those 9 runs were rejected by the existing deterministic support-reference
  validation boundary.

  No retry converted those failures into accepted output.

FAILURE_SIGNATURE=
  Ollama returned a project-context support reference that was not supplied in
  this invocation.

SEMANTIC_FAILURE_CLASS=
  MODEL_AUTHORED_INVALID_SUPPORT_PROVENANCE

DETERMINISTIC_RUNTIME_RESULT=
  CORRECT_FAIL_CLOSED_ENFORCEMENT

RUNTIME_REGRESSION_CLASSIFICATION=
  NOT_ESTABLISHED

  The fixture labels the caught exception as
  ADAPTIVE_DETAIL_RUNTIME_REGRESSION_DETECTED, but repository evidence shows
  the deterministic runtime is enforcing the established support-identity
  contract by rejecting unsupplied provenance.

  Therefore the observed failure should not be classified as evidence that
  deterministic validation itself regressed.

VARIANCE_CLASS=
  ACCEPTANCE_BOUNDARY_FAILURE

  The ten-run sample demonstrates materially different outcomes under identical
  ordinary unseeded generation conditions:

  - one accepted semantic result;
  - nine model-authored invalid support-provenance results rejected fail-closed.

EXACT_OUTPUT_VARIANCE=
  PRESENT

  The sample contains two exact-output fingerprints.

PRODUCTION_STABILITY_SIGNIFICANCE=
  MATERIAL_WITHIN_THIS_BOUNDED_FIXTURE

  Nine of ten bounded identical unseeded invocations crossed an established
  acceptance boundary.

  This is sufficient to establish that the observed unseeded variance is not
  merely harmless wording variation for this fixture.

  This ten-run sample does not by itself establish a universal long-run failure
  rate for all production conversations.

PRODUCTION_POLICY_DECISION=
  NOT_YET_AUTHORIZED

  The sample establishes a generation-stability problem worth continued
  characterization.

  It does not by itself establish which generation-policy intervention, if any,
  is correct.

CORRIDOR_2_RESULT=
  UNSEEDED_ACCEPTANCE_BOUNDARY_VARIANCE_CONFIRMED

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_CORRIDOR=STRUCTURED_RESPONSE_RELIABILITY_CHARACTERIZATION
NEXT_ACTION=INVESTIGATE_STRUCTURED_RESPONSE_RELIABILITY_FAILURE_SURFACE
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-preserved-unseeded-acceptance-boundary-failure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-preserved-unseeded-acceptance-boundary-failure.sh
git diff --cached --check
git commit -m "Classify preserved unseeded acceptance failure"
git push
