#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY UNSEEDED VARIANCE CHARACTERIZATION FIXTURE AND RUNNER ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY EXPECTED CONTRACT CHECKPOINT ==="
if [[ "$(git rev-parse --short=8 HEAD)" != "a44a03d9" ]]; then
  echo "STOP: HEAD no longer matches unseeded variance contract checkpoint a44a03d9."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-unseeded-variance-characterization-fixture-and-runner\.sh$|^ M scripts/classify-unseeded-variance-characterization-fixture-and-runner\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_CONTRACT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CHARACTERIZATION CONTRACT ==="
grep -nE \
  'Initial bounded characterization sample: 10 identical unseeded invocations|validationGenerationSeed must remain absent|NEXT_ACTION=CLASSIFY_UNSEEDED_VARIANCE_CHARACTERIZATION_FIXTURE_AND_RUNNER' \
  scripts/define-bounded-unseeded-variance-characterization-contract.sh

echo "CHARACTERIZATION_CONTRACT=CONFIRMED"

echo
echo "=== INSPECT EXISTING MIXED-CONTENT LIVE FIXTURE ==="
sed -n '1,260p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== INSPECT EXISTING UNSEEDED LIVE RUNNER ==="
sed -n '1,340p' scripts/run-adaptive-detail-mixed-content-live-validation.sh

echo
echo "=== INSPECT SEEDED VARIANT FOR SEAM COMPARISON ONLY ==="
sed -n '1,180p' scripts/validate-adaptive-detail-mixed-content-seeded-live.ts

echo
echo "=== INSPECT ESTABLISHED ACCEPTANCE CRITERIA ==="
sed -n '1,260p' scripts/validate-adaptive-detail-mixed-content-criteria.test.ts

echo
echo "=== VERIFY LIVE FIXTURE DOES NOT SUPPLY VALIDATION SEED ==="
if grep -nE 'validationGenerationSeed|seed:' \
  scripts/validate-adaptive-detail-mixed-content-live.ts; then
  echo "STOP: candidate unseeded fixture supplies generation seed."
  exit 2
fi

echo "LIVE_FIXTURE_VALIDATION_SEED=ABSENT"

echo
echo "=== VERIFY SEEDED FIXTURE IS DISTINCT ==="
grep -nE 'validationGenerationSeed|seed:' \
  scripts/validate-adaptive-detail-mixed-content-seeded-live.ts

echo "SEEDED_FIXTURE_SEPARATION=CONFIRMED"

echo
echo "=== VERIFY CANDIDATE FIXTURE CALLS EXISTING OLLAMACHAT SEAM ==="
grep -nE 'ollamaChat\(' \
  scripts/validate-adaptive-detail-mixed-content-live.ts

echo "EXISTING_OLLAMACHAT_SEAM=CONFIRMED"

echo
echo "=== VERIFY ACCEPTANCE CRITERIA ARE INDEPENDENTLY DEFINED ==="
grep -nE \
  'supportSourceReferences|selectedContextSegments|parent|child|expected|invalid|accept' \
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh \
  2>/dev/null || true

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=UNSEEDED_SEMANTIC_VARIANCE_CHARACTERIZATION

CANDIDATE_FIXTURE=
  scripts/validate-adaptive-detail-mixed-content-live.ts

CANDIDATE_RUNNER_REFERENCE=
  scripts/run-adaptive-detail-mixed-content-live-validation.sh

FIXTURE_CLASSIFICATION=
  The existing mixed-content live fixture is suitable as the initial bounded
  unseeded characterization fixture because:

  - it already exercises the established ollamaChat semantic-generation seam;
  - it does not supply validationGenerationSeed;
  - it has historical ordinary-unseeded behavior evidence;
  - it has independently established semantic acceptance criteria;
  - it previously exposed the documented intermittent support-provenance
    failure that motivated the broader Generation Stability successor corridor.

RUNNER_CLASSIFICATION=
  The existing live runner is useful as behavioral and environment reference,
  but Corridor 2 requires a new bounded observation runner rather than blindly
  reusing any runner whose purpose was corridor closure or one-shot validation.

  The bounded runner may invoke the existing live fixture ten times and record
  observations.

  It must not modify ollamaChat.ts, matilda-chat-workflow.ts, prompt content,
  generation options, retry behavior, or semantic validation.

EXPECTED_ACCEPTANCE_BOUNDARY=
  Each run must remain subject to the already established structured response
  contract and the mixed-content fixture's semantic support/selection criteria.

  Natural-language wording differences are not failures by themselves.

  A malformed/invalid structured response or a fixture-specific semantic
  support/identity violation is an acceptance-boundary failure.

OBSERVATION_RUNNER_REQUIREMENTS=
  1. Execute exactly 10 sequential identical unseeded fixture invocations.
  2. Supply no validationGenerationSeed.
  3. Preserve the exact fixture message and context on every run.
  4. Capture each run as a separate artifact.
  5. Record success versus fail-closed.
  6. Record fixture-semantic pass versus fail.
  7. Record structured fields needed for comparison.
  8. Compute an exact-output fingerprint only after successful output capture.
  9. Do not retry a failed run.
  10. Stop after the bounded ten-run sample.
  11. Preserve any failing artifact unchanged for classification.
  12. Do not infer a production-policy recommendation from the runner itself.

FIXTURE_AND_RUNNER_BOUNDARY=CLASSIFIED
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

NEXT_ACTION=IMPLEMENT_BOUNDED_UNSEEDED_VARIANCE_OBSERVATION_RUNNER
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-unseeded-variance-characterization-fixture-and-runner\.sh$' ||
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

git add scripts/classify-unseeded-variance-characterization-fixture-and-runner.sh
git diff --cached --check
git commit -m "Classify unseeded variance fixture and runner"
git push
