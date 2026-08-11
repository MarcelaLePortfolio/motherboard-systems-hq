#!/usr/bin/env bash
set -euo pipefail

echo "=== DEFINE BOUNDED UNSEEDED VARIANCE CHARACTERIZATION CONTRACT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY EXPECTED CORRIDOR-1 CHECKPOINT ==="
if [[ "$(git rev-parse --short=8 HEAD)" != "7e5dc44f" ]]; then
  echo "STOP: HEAD no longer matches Corridor 1 classification checkpoint 7e5dc44f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/define-bounded-unseeded-variance-characterization-contract\.sh$|^ M scripts/define-bounded-unseeded-variance-characterization-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_CORRIDOR_1_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CORRIDOR-1 CLASSIFICATION ==="
grep -nE \
  'CORRIDOR_1_RESULT=RECONCILED|NEXT_CORRIDOR=UNSEEDED_SEMANTIC_VARIANCE_CHARACTERIZATION|NEXT_ACTION=DEFINE_BOUNDED_UNSEEDED_VARIANCE_CHARACTERIZATION_CONTRACT' \
  scripts/classify-current-production-generation-behavior.sh

echo "CORRIDOR_1_CLASSIFICATION=CONFIRMED"

echo
echo "=== VERIFY EXISTING LIVE / SEEDED DIAGNOSTIC SURFACES ==="
grep -nE \
  'validationGenerationSeed|seed: context\.validationGenerationSeed' \
  scripts/utils/ollamaChat.ts

find scripts -maxdepth 1 -type f | sort | grep -E \
  'adaptive-detail.*live|seeded-reproducibility|support.*live|structured-evidence.*live|reasoning-composition-live' \
  || true

echo
echo "=== VERIFY PRIOR UNSEEDED EVIDENCE ==="
grep -nE \
  'Multiple unseeded runs produced that intended behavior|One documented unseeded run instead authored an invalid|Seeded evidence does not prove unseeded production reliability' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh

echo "PRIOR_UNSEEDED_EVIDENCE=CONFIRMED"

echo
echo "=== BOUNDED CHARACTERIZATION CONTRACT ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=UNSEEDED_SEMANTIC_VARIANCE_CHARACTERIZATION

QUESTION=
  Across repeated identical ordinary unseeded semantic-generation invocations,
  what variation is observed, and which variation remains inside versus crosses
  established deterministic and semantic acceptance boundaries?

MEASUREMENT_UNIT=
  One complete ollamaChat invocation using one fixed input/context fixture and
  ordinary production-equivalent unseeded generation behavior.

SEED_POLICY=
  validationGenerationSeed must remain absent.

  Seeded runs may be referenced as historical diagnostic evidence but must not
  be mixed into the unseeded sample.

GENERATION_POLICY=
  Do not introduce temperature.
  Do not introduce top_p.
  Do not introduce top_k.
  Do not introduce retries.
  Do not add a second Ollama invocation.
  Do not alter prompts to improve the measured result.

FIXTURE_POLICY=
  Use one repository-supported fixture whose expected structural and semantic
  acceptance conditions are already independently defined.

  The exact user message and supplied context must remain identical across the
  repeated unseeded sample.

SAMPLE_BOUNDARY=
  Initial bounded characterization sample: 10 identical unseeded invocations.

  Ten runs are sufficient for an initial bounded characterization but are not
  automatically sufficient to establish long-run production reliability.

OBSERVATIONS_PER_RUN=
  1. Invocation completed or failed closed.
  2. Structured JSON contract accepted or rejected.
  3. reply present and non-empty.
  4. durableInterpretation present and non-empty.
  5. explanationStatus accepted.
  6. supportSourceReferences structurally valid.
  7. investigationLifecycle structurally valid or null.
  8. selectedContextSegments structurally valid.
  9. Fixture-specific semantic acceptance result.
  10. Exact-output fingerprint for comparison only.

VARIANCE_CLASSES=
  A. Surface variation:
     Natural-language wording differs while all established structural and
     semantic acceptance conditions remain satisfied.

  B. Structured semantic variation:
     Typed semantic fields differ while each result remains independently valid
     under the established contract.

  C. Acceptance-boundary failure:
     A run fails closed or violates the independently established semantic
     acceptance criteria.

  D. Exact repeat:
     The observable structured result is identical to another run.

PRIMARY_CHARACTERIZATION_OUTPUT=
  - total runs
  - accepted runs
  - fail-closed runs
  - fixture-semantic-pass runs
  - fixture-semantic-fail runs
  - unique exact-output fingerprints
  - observed variance classes
  - concrete differing fields
  - whether any acceptance-boundary failure occurred

NON_GOALS=
  - proving statistical production reliability from ten runs
  - choosing a production seed
  - tuning temperature/top_p/top_k
  - changing the structured response contract
  - changing Matilda semantic authority
  - changing Response Composition
  - changing semantic history behavior
  - implementing generation policy

DECISION_BOUNDARY=
  If all runs remain within established acceptance boundaries, record the
  observed degree and type of unseeded variance without inferring that no
  generation-policy work will ever be needed.

  If one or more runs cross an established acceptance boundary, preserve the
  failing artifact and classify the failure before considering any generation
  control.

  Do not authorize production intervention from raw variance alone.

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_ACTION=CLASSIFY_UNSEEDED_VARIANCE_CHARACTERIZATION_FIXTURE_AND_RUNNER
MAP

echo
echo "=== VERIFY CONTRACT-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/define-bounded-unseeded-variance-characterization-contract\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside contract-definition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CONTRACT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/define-bounded-unseeded-variance-characterization-contract.sh
git diff --cached --check
git commit -m "Define bounded unseeded variance characterization contract"
git push
