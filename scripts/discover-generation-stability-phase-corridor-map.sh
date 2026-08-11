#!/usr/bin/env bash
set -euo pipefail

echo "=== DISCOVER GENERATION STABILITY PHASE / CORRIDOR MAP ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY DISCOVERY-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/discover-generation-stability-phase-corridor-map\.sh$|^ M scripts/discover-generation-stability-phase-corridor-map\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "DISCOVERY_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY ESTABLISHED SUCCESSOR MILESTONE ==="
grep -nE \
  'SUCCESSOR_RELATIONSHIP=GENERATION_STABILITY_IMMEDIATE_SUCCESSOR|SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY|SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED|NEXT_ACTION=DISCOVER_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP' \
  scripts/classify-shared-parent-conversation-engine-milestone-boundary.sh

echo "SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "SUCCESSOR_MILESTONE_BOUNDARY=CONFIRMED"

echo
echo "=== PHASE 1 EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='discover-generation-stability-phase-corridor-map.sh' \
  'ordinary unseeded model behavior remains variable|remaining unseeded variance|unseeded production reliability|live repeatability|production stability|semantic-generation stability' \
  scripts \
  2>/dev/null || true

echo
echo "=== PHASE 2 EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='discover-generation-stability-phase-corridor-map.sh' \
  'production generation policy|production sampling policy|generation control|control seam|validation-only.*seed|request-scoped generation|temperature|top_p|top_k' \
  scripts \
  2>/dev/null || true

echo
echo "=== PHASE 3 EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='discover-generation-stability-phase-corridor-map.sh' \
  'seeded reproducibility|seeded evidence|production reliability|acceptance contract|fail.closed|behavioral validation|corridor closure' \
  scripts \
  2>/dev/null || true

echo
echo "=== DISCOVERED CANDIDATE MAP ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY

MILESTONE_PURPOSE=
Establish whether ordinary production semantic generation is sufficiently
stable and reliable, determine whether production generation-policy controls
are necessary and safe, and validate the resulting production behavior without
treating validation-only seeded reproducibility as proof of normal production
reliability.

PHASE_1=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

PHASE_1_PURPOSE=
Characterize actual ordinary production generation behavior before authorizing
any generation-policy intervention.

PHASE_1_CORRIDORS=
  1. Current Production Generation Behavior Reconciliation
  2. Unseeded Semantic Variance Characterization
  3. Structured-Response Reliability Characterization
  4. Semantic-Meaning Stability Characterization
  5. Production Stability Acceptance Boundary

PHASE_2=GENERATION_POLICY_AND_CONTROL_BOUNDARY

PHASE_2_PURPOSE=
Determine whether generation controls are required and define the smallest safe
production control boundary without fragmenting Matilda semantic ownership.

PHASE_2_CORRIDORS=
  1. Current Production Sampling Policy Inventory
  2. Ollama Generation-Control Surface
  3. Validation-Only vs Production Control Boundary
  4. Request-Scoped vs Shared Policy Boundary
  5. Generation-Control Authorization and Semantic-Preservation Contract

PHASE_3=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE

PHASE_3_PURPOSE=
Validate the resulting production state against ordinary unseeded behavior and
close the milestone using production-appropriate evidence.

PHASE_3_CORRIDORS=
  1. Production Stability Validation Contract
  2. Repeated Unseeded Behavioral Validation
  3. Fail-Closed Contract Preservation
  4. Single Ollama Invocation Preservation
  5. Production Regression Validation
  6. Generation Stability Closure Classification

PHASE_ORDERING=
  Phase 1 must occur first.

  Phase 2 occurs only after Phase 1 establishes whether production-policy
  intervention is justified.

  Phase 2 may conclude that no production implementation is required.

  Phase 3 validates whichever production state Phase 1 and Phase 2 establish.

SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED
MAP

echo
echo "=== DISCOVERY RESULT ==="
echo "PHASE_MAP_CANDIDATE=REPOSITORY_SUPPORTED"
echo "PHASE_COUNT_CANDIDATE=3"
echo "PHASE_1=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION"
echo "PHASE_2=GENERATION_POLICY_AND_CONTROL_BOUNDARY"
echo "PHASE_3=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE"
echo "CORRIDOR_MAP_CANDIDATE=REPOSITORY_SUPPORTED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_TIME=NO"
echo "NEXT_ACTION=CLASSIFY_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP"

echo
echo "=== VERIFY DISCOVERY-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/discover-generation-stability-phase-corridor-map\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside discovery scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "DISCOVERY_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/discover-generation-stability-phase-corridor-map.sh
git diff --cached --check
git commit -m "Discover Generation Stability phase corridor map"
git push
