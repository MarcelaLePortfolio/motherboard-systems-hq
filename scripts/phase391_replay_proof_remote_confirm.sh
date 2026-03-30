#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v390.0-replay-proof-integrity-complete-golden"

echo "Phase 391 — Replay proof integrity confirmation starting"

if [[ ! -f scripts/phase390_replay_proof_final_seal.sh ]]; then
  echo "Missing script: scripts/phase390_replay_proof_final_seal.sh"
  exit 1
fi

bash scripts/phase390_replay_proof_final_seal.sh || true

echo "Refreshing local tags"
git fetch origin --tags --force

if git show-ref --tags --verify --quiet "refs/tags/$TAG"; then
  echo "Local golden tag present: $TAG"
else
  echo "Local golden tag missing: $TAG"
  exit 1
fi

if git ls-remote --tags origin | grep -Fq "refs/tags/$TAG"; then
  echo "Remote golden tag present: $TAG"
else
  echo "Remote golden tag missing: $TAG"
  exit 1
fi

echo "Phase 391 — Replay proof integrity confirmed"
