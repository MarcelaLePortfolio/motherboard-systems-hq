#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 388 — Replay proof surface audit starting"

REQUIRED_FILES=(
  "src/governance_investigation/verification/replay_pathological_fixtures.ts"
  "src/governance_investigation/verification/check-pathological-fixtures.ts"
  "src/governance_investigation/verification/run-pathological-fixture-proof.ts"
  "src/governance_investigation/verification/check-pathological-fixture-reproducibility.ts"
  "src/governance_investigation/verification/run-replay-pathological-proof-suite.ts"
  "src/governance_investigation/verification/check-pathological-fixture-diagnostic-stability.ts"
  "src/governance_investigation/verification/run-replay-diagnostic-stability-proof.ts"
  "src/governance_investigation/verification/run-replay-verification-proof-suite.ts"
  "scripts/phase382_replay_proof_seal.sh"
  "scripts/phase383_replay_proof_execution.sh"
  "scripts/phase384_replay_proof_gate.sh"
  "scripts/phase385_replay_proof_verify.sh"
  "scripts/phase386_replay_chain_seal.sh"
  "scripts/phase387_replay_chain_run.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required proof surface file: $file"
    exit 1
  fi
done

EXECUTABLE_SCRIPTS=(
  "scripts/phase382_replay_proof_seal.sh"
  "scripts/phase383_replay_proof_execution.sh"
  "scripts/phase384_replay_proof_gate.sh"
  "scripts/phase385_replay_proof_verify.sh"
  "scripts/phase386_replay_chain_seal.sh"
  "scripts/phase387_replay_chain_run.sh"
)

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
  if [[ ! -x "$script" ]]; then
    echo "Script is not executable: $script"
    exit 1
  fi
done

echo "Phase 388 — Replay proof surface audit complete"
