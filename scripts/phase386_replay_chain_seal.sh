#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 386 — Replay chain seal"

bash scripts/phase385_replay_proof_verify.sh

TAG="v386.0-replay-chain-integrity-golden"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists: $TAG"
else
  git tag -a "$TAG" -m "Phase 386 replay chain integrity golden checkpoint"
  echo "Created tag: $TAG"
fi

git push origin "$TAG"

echo "Phase 386 — Replay chain seal complete"
