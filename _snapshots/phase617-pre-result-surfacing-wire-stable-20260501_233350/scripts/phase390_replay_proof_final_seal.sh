#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 390 — Replay proof final seal starting"

bash scripts/phase389_replay_proof_integrity_gate.sh

TAG="v390.0-replay-proof-integrity-complete-golden"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Golden tag already exists: $TAG"
else
  git tag -a "$TAG" -m "Phase 390 replay proof integrity complete"
  echo "Created golden tag: $TAG"
fi

git push origin "$TAG"

echo "Phase 390 — Replay proof final seal complete"
