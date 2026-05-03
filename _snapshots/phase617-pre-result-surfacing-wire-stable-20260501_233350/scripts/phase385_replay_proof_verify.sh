#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 385 — Replay proof verification"

bash scripts/phase384_replay_proof_gate.sh

TAG="v382.0-replay-verification-proof-suite-golden"

if git tag --list | grep -q "$TAG"; then
  echo "Golden checkpoint present: $TAG"
else
  echo "Golden checkpoint missing"
  exit 1
fi

echo "Phase 385 — Replay proof verification complete"
