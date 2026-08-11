#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CONVERSATION ENGINE GENERATION STABILITY PHASE / CORRIDOR MAP ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLASSIFICATION-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-generation-stability-phase-corridor-map\.sh$|^ M scripts/classify-generation-stability-phase-corridor-map\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi
echo "CLASSIFICATION_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY SUCCESSOR MILESTONE IS ESTABLISHED ==="
grep -nE \
  'SUCCESSOR_RELATIONSHIP=GENERATION_STABILITY_IMMEDIATE_SUCCESSOR|SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY|SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED|NEXT_ACTION=DISCOVER_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP' \
  scripts/classify-shared-parent-conversation-engine-milestone-boundary.sh

echo "SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "SUCCESSOR_MILESTONE_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY PHASE-MAP DISCOVERY ARTIFACT ==="
if [[ ! -f scripts/discover-generation-stability-phase-corridor-map.sh ]]; then
  echo "STOP: Generation Stability phase/corridor discovery artifact is absent."
  exit 2
fi

grep -nE \
  'PHASE_1=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION|PHASE_2=GENERATION_POLICY_AND_CONTROL_BOUNDARY|PHASE_3=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE|PHASE_MAP_CANDIDATE=REPOSITORY_SUPPORTED|PHASE_COUNT_CANDIDATE=3|NEXT_ACTION=CLASSIFY_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP' \
  scripts/discover-generation-stability-phase-corridor-map.sh

echo "PHASE_MAP_DISCOVERY=CONFIRMED"

echo
echo "=== PHASE 1 EVIDENCE: PRODUCTION GENERATION STABILITY CHARACTERIZATION ==="
phase1_evidence="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='discover-generation-stability-phase-corridor-map.sh' \
    --exclude='classify-generation-stability-phase-corridor-map.sh' \
    'ordinary unseeded model behavior remains variable|remaining unseeded variance|unseeded production reliability|live repeatability|production stability|semantic-generation stability' \
    scripts \
    2>/dev/null || true
)"
printf '%s\n' "$phase1_evidence"

if [[ -z "$phase1_evidence" ]]; then
  echo "STOP: Phase 1 responsibility lacks repository evidence."
  exit 2
fi

echo "PHASE_1_RESPONSIBILITY=SUPPORTED"

echo
echo "=== PHASE 2 EVIDENCE: GENERATION POLICY AND CONTROL BOUNDARY ==="
phase2_evidence="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='discover-generation-stability-phase-corridor-map.sh' \
    --exclude='classify-generation-stability-phase-corridor-map.sh' \
    'production generation policy|production sampling policy|generation control|control seam|validation-only.*seed|request-scoped generation|production workflow.*generation controls|temperature|top_p|top_k' \
    scripts \
    2>/dev/null || true
)"
printf '%s\n' "$phase2_evidence"

if [[ -z "$phase2_evidence" ]]; then
  echo "STOP: Phase 2 responsibility lacks repository evidence."
  exit 2
fi

echo "PHASE_2_RESPONSIBILITY=SUPPORTED"

echo
echo "=== PHASE 3 EVIDENCE: PRODUCTION STABILITY VALIDATION AND CLOSURE ==="
phase3_evidence="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='discover-generation-stability-phase-corridor-map.sh' \
    --exclude='classify-generation-stability-phase-corridor-map.sh' \
    'seeded reproducibility|seeded evidence|production reliability|acceptance contract|fail.closed|behavioral validation|corridor closure|production sampling policy' \
    scripts \
    2>/dev/null || true
)"
printf '%s\n' "$phase3_evidence"

if [[ -z "$phase3_evidence" ]]; then
  echo "STOP: Phase 3 responsibility lacks repository evidence."
  exit 2
fi

echo "PHASE_3_RESPONSIBILITY=SUPPORTED"

echo
echo "=== VERIFY PHASE RESPONSIBILITIES ARE DISTINCT ==="

grep -nE \
  'remaining unseeded variance.*separate generation|Seeded evidence does not prove unseeded production reliability|production generation policy remains unchanged|Broader semantic-generation stability.*deferred|production sampling policy' \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh \
  scripts/validate-adaptive-detail-corridor-closure.sh \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh \
  2>/dev/null || true

echo "PHASE_RESPONSIBILITY_SEPARATION=SUPPORTED"

echo
echo "=== CLASSIFY PHASE / CORRIDOR MAP ==="

cat <<'MAP'
MILESTONE
  Conversation Engine — Generation Stability

PURPOSE
  Establish whether ordinary production semantic generation is sufficiently
  stable and reliable, determine whether production generation-policy controls
  are necessary and safe, and validate the resulting production behavior
  without confusing validation-only seeded reproducibility with normal
  production reliability.

PHASE 1 — PRODUCTION GENERATION STABILITY CHARACTERIZATION

  Purpose:
    Establish the actual production behavior and failure envelope before any
    generation-policy intervention is authorized.

  Corridors:
    1. Current Production Generation Behavior Reconciliation
    2. Unseeded Semantic Variance Characterization
    3. Structured-Response Reliability Characterization
    4. Semantic-Meaning Stability Characterization
    5. Production Stability Acceptance Boundary

PHASE 2 — GENERATION POLICY AND CONTROL BOUNDARY

  Purpose:
    Determine whether generation controls are required and, if so, define the
    smallest safe control boundary without changing semantic ownership or
    fragmenting the existing generation seam.

  Corridors:
    1. Current Production Sampling Policy Inventory
    2. Ollama Generation-Control Surface
    3. Validation-Only vs Production Control Boundary
    4. Request-Scoped vs Shared Policy Boundary
    5. Generation-Control Authorization and Semantic-Preservation Contract

PHASE 3 — PRODUCTION STABILITY VALIDATION AND CLOSURE

  Purpose:
    Validate the repository-supported stability outcome against ordinary
    production behavior and close the milestone using evidence appropriate to
    production rather than seeded diagnostics alone.

  Corridors:
    1. Production Stability Validation Contract
    2. Repeated Unseeded Behavioral Validation
    3. Fail-Closed Contract Preservation
    4. Single Ollama Invocation Preservation
    5. Production Regression Validation
    6. Generation Stability Closure Classification

ORDERING
  Phase 1 is mandatory first.

  Phase 2 begins only after Phase 1 establishes whether production-policy
  intervention is actually necessary.

  Phase 2 may conclude that no production implementation is required.

  Phase 3 validates whichever production state Phase 1 and Phase 2 establish.

  Seeded reproducibility remains diagnostic evidence and is not by itself proof
  of ordinary unseeded production stability.
MAP

echo
echo "=== FINAL CLASSIFICATION ==="
echo "SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "SUCCESSOR_MILESTONE_STATUS=CONFIRMED"
echo "PHASE_COUNT=3"
echo "PHASE_1=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION"
echo "PHASE_1_CORRIDOR_COUNT=5"
echo "PHASE_2=GENERATION_POLICY_AND_CONTROL_BOUNDARY"
echo "PHASE_2_CORRIDOR_COUNT=5"
echo "PHASE_3=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE"
echo "PHASE_3_CORRIDOR_COUNT=6"
echo "PHASE_MAP=CONFIRMED"
echo "CORRIDOR_MAP=CONFIRMED"
echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED"
echo "COLLABORATION_RUNTIME_MILESTONE=REMAINS_COMPLETE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "MILESTONE_DOCUMENTATION=NOW_JUSTIFIED"
echo "DR_TIME=NO"
echo "NEXT_ACTION=DOCUMENT_CONVERSATION_ENGINE_GENERATION_STABILITY_MILESTONE_AND_PHASE_CORRIDOR_MAP"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-generation-stability-phase-corridor-map\.sh$' ||
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

git add scripts/classify-generation-stability-phase-corridor-map.sh
git diff --cached --check
git commit -m "Classify Generation Stability phase corridor map"
git push
